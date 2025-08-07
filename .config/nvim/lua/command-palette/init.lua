local Input = require("nui.input")
local Menu = require("nui.menu")
local event = require("nui.utils.autocmd").event

local M = {}
M.is_open = false
M.input = nil
M.menu = nil

local function get_files()
  local files = {}
  -- Try fd first, fallback to find
  local cmd = "fd --type f --hidden --follow --exclude .git . 2>/dev/null || find . -type f -not -path '*/\\.git/*' 2>/dev/null"
  local handle = io.popen(cmd)
  if handle then
    for line in handle:lines() do
      table.insert(files, line)
    end
    handle:close()
  end
  return files
end

local function get_symbols(bufnr)
  local symbols = {}
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  
  -- Pattern definitions for different languages
  local patterns = {
    -- Lua
    { pattern = "function%s+([%w_%.:%[%]]+)", kind = "Function" },
    { pattern = "local%s+function%s+([%w_]+)", kind = "Function" },
    { pattern = "([%w_]+)%s*=%s*function", kind = "Function" },
    { pattern = "local%s+([%w_]+)%s*=", kind = "Variable" },
    
    -- JavaScript/TypeScript
    { pattern = "const%s+([%w_]+)", kind = "Constant" },
    { pattern = "let%s+([%w_]+)", kind = "Variable" },
    { pattern = "var%s+([%w_]+)", kind = "Variable" },
    { pattern = "class%s+([%w_]+)", kind = "Class" },
    { pattern = "interface%s+([%w_]+)", kind = "Interface" },
    { pattern = "type%s+([%w_]+)", kind = "Type" },
    { pattern = "export%s+function%s+([%w_]+)", kind = "Function" },
    { pattern = "export%s+const%s+([%w_]+)", kind = "Export" },
    
    -- Python
    { pattern = "def%s+([%w_]+)", kind = "Function" },
    { pattern = "class%s+([%w_]+)", kind = "Class" },
    
    -- Go
    { pattern = "func%s+([%w_]+)", kind = "Function" },
    { pattern = "type%s+([%w_]+)%s+struct", kind = "Struct" },
    { pattern = "type%s+([%w_]+)%s+interface", kind = "Interface" },
    
    -- Generic fallbacks
    { pattern = "^%s*([%w_]+)%s*=", kind = "Variable" },
    { pattern = "^%s*([%w_]+)%s*:", kind = "Property" },
  }
  
  for i, line in ipairs(lines) do
    -- Skip empty lines and comments
    if line:match("^%s*$") or line:match("^%s*//") or line:match("^%s*#") or line:match("^%s*%-%-") then
      goto continue
    end
    
    for _, p in ipairs(patterns) do
      local match = line:match(p.pattern)
      if match and match ~= "" and #match > 1 then
        table.insert(symbols, {
          name = match,
          kind = p.kind,
          line = i,
          col = 1,
          bufnr = bufnr
        })
        break -- Only match first pattern per line
      end
    end
    ::continue::
  end
  
  return symbols
end

local function get_commands()
  local commands = {
    { name = "write", desc = "Save current file" },
    { name = "quit", desc = "Quit" },
    { name = "wq", desc = "Save and quit" },
    { name = "Telescope find_files", desc = "Find files" },
    { name = "Telescope live_grep", desc = "Live grep" },
    { name = "Telescope buffers", desc = "Find buffers" },
  }
  return commands
end

local function fuzzy_filter(items, query)
  if query == "" or query == nil then
    return items
  end
  
  local filtered = {}
  local query_lower = query:lower()
  
  for _, item in ipairs(items) do
    local text = type(item) == "string" and item or item.name or ""
    if text:lower():find(query_lower, 1, true) then
      table.insert(filtered, item)
    end
  end
  
  return filtered
end

function M.open()
  -- If already open, close it
  if M.is_open then
    if M.menu then
      M.menu:unmount()
      M.menu = nil
    end
    if M.input then
      M.input:unmount()
      M.input = nil
    end
    M.is_open = false
    return
  end
  
  -- Capture the current buffer BEFORE opening the palette
  local original_bufnr = vim.api.nvim_get_current_buf()
  
  local all_files = get_files()
  local current_items = {}
  local current_mode = "files"
  local current_menu = nil
  local selected_index = 1
  
  -- Input component - position higher up so the whole palette is centered
  local input = Input({
    position = {
      row = "35%", -- Higher than center
      col = "50%",
    },
    size = {
      width = 70,
      height = 1,
    },
    border = {
      style = "rounded",
      text = {
        top = "Command Palette",
        top_align = "center",
      },
    },
  }, {
    prompt = "> ",
    default_value = "",
  })
  
  local function close_all()
    if current_menu then
      current_menu:unmount()
      current_menu = nil
    end
    if input then
      input:unmount()
    end
    M.is_open = false
    M.input = nil
    M.menu = nil
  end
  
  local function update_results(query)
    local items = {}
    local title = "Files"
    
    if query:sub(1, 1) == "@" then
      current_mode = "symbols"
      title = "Symbols"
      local search_query = query:sub(2)
      local symbols = get_symbols(original_bufnr)
      items = fuzzy_filter(symbols, search_query)
    elseif query:sub(1, 1) == ">" then
      current_mode = "commands"
      title = "Commands"
      local search_query = query:sub(2)
      local commands = get_commands()
      items = fuzzy_filter(commands, search_query)
    else
      current_mode = "files"
      title = "Files"
      items = fuzzy_filter(all_files, query)
    end
    
    -- Limit results for performance
    local limited_items = {}
    for i = 1, math.min(50, #items) do
      table.insert(limited_items, items[i])
    end
    current_items = limited_items
    selected_index = 1  -- Reset selection when results update
    
    -- Close existing menu
    if current_menu then
      current_menu:unmount()
    end
    
    -- Create new menu with results
    if #limited_items > 0 then
      local menu_items = {}
      for i, item in ipairs(limited_items) do
        local text
        if type(item) == "string" then
          text = item
        elseif item.name and item.desc then
          text = string.format("%s - %s", item.name, item.desc)
        elseif item.name and item.kind then
          text = string.format("[%s] %s", item.kind, item.name)
        else
          text = item.name or tostring(item)
        end
        table.insert(menu_items, Menu.item(text, { data = item }))
      end
      
      -- Calculate center position for menu to be below input
      local editor_width = vim.o.columns
      local editor_height = vim.o.lines
      local menu_width = 70
      local menu_height = math.min(#menu_items + 2, 15)
      
      current_menu = Menu({
        position = {
          row = math.floor(editor_height * 0.35) + 2, -- Closer to the input
          col = math.floor((editor_width - menu_width) / 2),
        },
        relative = "editor",
        size = {
          width = menu_width,
          height = menu_height
        },
        border = {
          style = "rounded",
          text = {
            top = title,
            top_align = "center",
          },
        },
      }, {
        lines = menu_items,
        keymap = {
          close = { "<Esc>" },
          submit = { "<CR>" },
        },
        on_submit = function(item)
          close_all()
          if current_mode == "files" then
            vim.cmd("edit " .. vim.fn.fnameescape(item.data))
          elseif current_mode == "symbols" then
            -- Navigate to symbol location
            vim.api.nvim_win_set_cursor(0, {item.data.line, item.data.col - 1})
            vim.cmd("normal! zz")  -- Center the line in the window
          elseif current_mode == "commands" then
            vim.cmd(item.data.name)
          end
        end,
      })
      
      current_menu:mount()
      M.menu = current_menu
    end
  end
  
  -- Store references and set state
  M.input = input
  M.is_open = true
  
  -- Mount input
  input:mount()
  
  -- Initialize with all files
  update_results("")
  
  -- Ensure input is focused
  vim.schedule(function()
    vim.api.nvim_set_current_win(input.winid)
    vim.cmd("startinsert")
  end)
  
  -- Handle text changes for live filtering
  input:on(event.TextChangedI, function()
    local lines = vim.api.nvim_buf_get_lines(input.bufnr, 0, -1, false)
    local query = lines[1] or ""
    -- Remove the prompt from the query
    query = query:gsub("^> ", "")
    update_results(query)
  end)
  
  -- Handle navigation with arrow keys while keeping input focused
  input:map("i", "<Down>", function()
    if current_menu and #current_items > 0 then
      selected_index = math.min(selected_index + 1, #current_items)
      -- Temporarily switch to menu to move cursor, then back to input
      local current_win = vim.api.nvim_get_current_win()
      vim.api.nvim_set_current_win(current_menu.winid)
      vim.api.nvim_win_set_cursor(current_menu.winid, {selected_index, 0})
      vim.api.nvim_set_current_win(current_win)
    end
  end, { nowait = true })
  
  input:map("i", "<Up>", function()
    if current_menu and #current_items > 0 then
      selected_index = math.max(selected_index - 1, 1)
      -- Temporarily switch to menu to move cursor, then back to input
      local current_win = vim.api.nvim_get_current_win()
      vim.api.nvim_set_current_win(current_menu.winid)
      vim.api.nvim_win_set_cursor(current_menu.winid, {selected_index, 0})
      vim.api.nvim_set_current_win(current_win)
    end
  end, { nowait = true })
  
  -- Handle escape to close everything
  input:map("n", "<Esc>", close_all, { nowait = true })
  input:map("i", "<Esc>", close_all, { nowait = true })
  
  -- Handle enter in input (select currently highlighted result)
  input:map("i", "<CR>", function()
    if #current_items > 0 and selected_index <= #current_items then
      close_all()
      local item = current_items[selected_index]
      if current_mode == "files" then
        vim.cmd("edit " .. vim.fn.fnameescape(item))
      elseif current_mode == "symbols" then
        -- Navigate to symbol location
        vim.api.nvim_win_set_cursor(0, {item.line, item.col - 1})
        vim.cmd("normal! zz")  -- Center the line in the window
      elseif current_mode == "commands" then
        vim.cmd(item.name)
      end
    end
  end, { nowait = true })
end

return M
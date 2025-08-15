--- @since 25.2.7

return {
    entry = function()
        -- Helper function to escape shell arguments
        local function shell_escape(str)
            if not str then return "''" end
            return "'" .. string.gsub(str, "'", "'\\''") .. "'"
        end
        
        -- Create a minimal log file for debugging if needed
        local log_file = io.open("/tmp/yazi-autojump-debug.log", "w")
        if log_file then
            log_file:write("Autojump plugin started\n")
            log_file:close()
        end
        
        -- Get input from user
        local input = ya.input({
            title = "Autojump to:",
            position = { "top-center", y = 3, w = 40 },
            realtime = true,
        })
        
        -- Process input events
        while true do
            local value, event = input:recv()
            
            -- Break if no value (error) or user cancelled (event = 2)
            if not value or event == 2 then
                break
            end
            
            -- User confirmed input (event = 1)
            if event == 1 then
                -- Try to find directory with autojump
                if value ~= "" then
                    -- Run autojump command
                    local handle = io.popen("autojump " .. shell_escape(value) .. " 2>/dev/null")
                    if not handle then
                        ya.notify({
                            title = "Autojump",
                            content = "Failed to run autojump command",
                            level = "error",
                            timeout = 5,
                        })
                        break
                    end
                    
                    -- Read result
                    local result = handle:read("*a")
                    handle:close()
                    
                    -- Trim whitespace
                    result = result:gsub("^%s*(.-)%s*$", "%1")
                    
                    -- Check if directory exists
                    local is_dir = os.execute("test -d " .. shell_escape(result) .. " 2>/dev/null")
                    
                    -- Try to change directory if result is valid
                    if result ~= "" and is_dir then
                        ya.notify({
                            title = "Autojump",
                            content = "Jumping to: " .. result,
                            level = "info",
                            timeout = 3,
                        })
                        
                        -- Create the URL with file:// prefix
                        local url = "file://" .. result
                        
                        -- Change directory using the same format as the mount plugin
                        ya.manager_emit("cd", { url })
                    else
                        ya.notify({
                            title = "Autojump",
                            content = "No valid directory found for: " .. value,
                            level = "warn",
                            timeout = 5,
                        })
                    end
                end
                break
            end
        end
    end
} 
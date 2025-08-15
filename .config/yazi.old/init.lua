require("full-border"):setup({
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
})

require("yatline"):setup({
	show_background = true,

	style_a = {
		fg = "#FFC799", -- Vesper orange accent for icons/highlights
		bg_mode = {
			normal = "#101010", -- Vesper background
			select = "#101010", -- Vesper background
			un_set = "#101010", -- Vesper background
		},
	},
	style_b = { bg = "#101010", fg = "#7E7E7E" }, -- Muted text from Vesper (titleBar.activeForeground)
	style_c = { bg = "#101010", fg = "#505050" }, -- More muted text from Vesper (editorLineNumber.foreground)

	status_line = {
		left = {
			section_a = {
				-- Empty to avoid using accent color
			},
			section_b = {
				{ type = "string", custom = false, name = "hovered_size" },
			},
			section_c = {
				{ type = "string", custom = false, name = "hovered_path" },
				{ type = "coloreds", custom = false, name = "count" },
			},
		},
		right = {
			section_a = {
				-- Empty to avoid using accent color
			},
			section_b = {
				{ type = "string", custom = false, name = "cursor_position" },
			},
			section_c = {},
		},
	},
})

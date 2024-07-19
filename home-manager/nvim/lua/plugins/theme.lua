return {
	-- Configure LazyVim to load gruvbox
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "catppuccin-macchiato",
		},
	},
	{
		"catppuccin",
		opts = {
			flavour = "auto", -- latte, frappe, macchiato, mocha
			background = { -- :h background
				light = "latte",
				dark = "macchiato",
			},
		},
	},
	{
		"f-person/auto-dark-mode.nvim",
		lazy = false,
		config = function()
			local auto_dark_mode = require("auto-dark-mode")
			auto_dark_mode.setup({
				update_interval = 1000,
				set_dark_mode = function()
					-- vim.cmd("set background=dark")
					vim.cmd("colorscheme catppuccin-macchiato")
				end,
				set_light_mode = function()
					-- vim.cmd("set background=light")
					vim.cmd("colorscheme catppuccin-latte")
				end,
			})
			auto_dark_mode.init()
		end,
	},
}

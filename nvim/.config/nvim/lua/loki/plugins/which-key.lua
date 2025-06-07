return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 500
	end,
	opts = {
		-- Keymap configuration
		defaults = {
			["<leader>a"] = { name = "+AI" }, -- Group for AI-related commands
		},
	},
	config = function(_, opts)
		local wk = require("which-key")
		wk.setup(opts)

		-- Register ChatGPT keymaps
		wk.register({
			a = {
				i = { ":ChatGPT<CR>", "Open ChatGPT" },
				e = { ":ChatGPTEditWithInstructions<CR>", "Edit with Instructions" },
				c = { ":ChatGPTActAs<CR>", "Act As" },
			},
		}, { prefix = "<leader>" })
	end,
}

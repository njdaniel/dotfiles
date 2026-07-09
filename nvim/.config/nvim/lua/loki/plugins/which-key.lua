return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 500
	end,
	opts = {
		spec = {
			{ "<leader>a", group = "AI" },
			{ "<leader>ai", "<cmd>CopilotChatToggle<CR>", desc = "Toggle Copilot Chat" },
		},
	},
}

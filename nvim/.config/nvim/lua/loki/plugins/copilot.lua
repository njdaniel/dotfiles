return {
	"github/copilot.vim",
	config = function()
		-- Disable default <Tab> mapping to avoid conflicts
		vim.g.copilot_no_tab_map = true

		-- Map <C-L> to accept Copilot suggestions
		vim.api.nvim_set_keymap("i", "<C-L>", 'copilot#Accept("<CR>")', { expr = true, silent = true })

		-- Optional: Enable/disable Copilot for specific file types
		vim.g.copilot_filetypes = {
			["*"] = true, -- Enable for all file types
			-- markdown = false, -- Disable for markdown
			-- text = false, -- Disable for plain text files
		}
	end,
	event = "InsertEnter", -- Lazy load Copilot on insert mode
}

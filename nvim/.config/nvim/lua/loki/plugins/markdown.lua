return {
	-- Markdown Preview Plugin
	{
		"iamcco/markdown-preview.nvim",
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
		ft = "markdown", -- Load only for Markdown files
		config = function()
			-- Keybindings for Markdown
			vim.api.nvim_set_keymap("n", "<leader>mp", ":MarkdownPreview<CR>", { noremap = true, silent = true })
			vim.api.nvim_set_keymap("n", "<leader>ms", ":MarkdownPreviewStop<CR>", { noremap = true, silent = true })
		end,
	},

	-- Enhanced Markdown Syntax Plugin
	{
		"plasticboy/vim-markdown",
		ft = "markdown",
		config = function()
			vim.g.vim_markdown_folding_disabled = 1 -- Disable folding if you don't like it
			vim.g.vim_markdown_conceal = 2 -- Conceal formatting symbols

			-- Markdown-specific settings
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function()
					vim.opt_local.wrap = true -- Enable word wrap
					vim.opt_local.spell = true -- Enable spell checking
					vim.opt_local.autoindent = true -- Enable auto-indentation
				end,
			})
		end,
	},
}

return {
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000, -- Ensures it's loaded early
		config = function()
			-- Set the colorscheme after loading the plugin
			vim.cmd([[colorscheme gruvbox]])
		end,
	},
}

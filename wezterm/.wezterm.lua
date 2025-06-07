local wezterm = require("wezterm")

return {
	-- Set font
	font = wezterm.font("JetBrains Mono"),
	font_size = 12.0,

	-- Set color scheme
	-- color_scheme = "Gruvbox Dark",
	color_scheme = "Gruvbox Dark (Gogh)",
	-- color_scheme = "Monokai Pro",
	-- color_scheme = "Nord",
	-- color_scheme = "Ayu Dark",
	-- color_scheme = "Catppuccin Mocha",
	-- color_scheme = "Dracula",

	-- Window settings
	enable_tab_bar = false,
	window_background_opacity = 0.9,
	window_decorations = "RESIZE",
}

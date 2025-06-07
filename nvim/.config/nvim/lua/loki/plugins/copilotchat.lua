return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "github/copilot.vim" }, -- Alternatively, use "zbirenbaum/copilot.lua"
      { "nvim-lua/plenary.nvim" }, -- Required for various functionalities
    },
    build = "make tiktoken", -- Only necessary on macOS or Linux
    opts = {
      -- Optional configuration settings
    },
    -- Optional: Define commands to lazy-load the plugin
    cmd = { "CopilotChat", "CopilotChatToggle" },
  },
}


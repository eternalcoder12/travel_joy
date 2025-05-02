return {
  {
    "akinsho/flutter-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    ft = "dart",
    opts = {
      ui = {
        border = "rounded",
        notification_style = "native",
      },
      decorations = {
        statusline = {
          app_version = true,
          device = true,
        },
      },
      flutter = {
        path = "flutter",
      },
      debugger = {
        enabled = true,
        run_via_dap = true,
      },
      dev_log = {
        enabled = true,
        open_cmd = "tabedit",
      },
    },
  },
  {
    "dart-lang/dart-vim-plugin", 
    ft = "dart",
  }
} 
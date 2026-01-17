return {
  -- Beautiful markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown", "md" },
    opts = {
      heading = {
        enabled = true,
        sign = true,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        backgrounds = {
          "RenderMarkdownH1Bg",
          "RenderMarkdownH2Bg",
          "RenderMarkdownH3Bg",
          "RenderMarkdownH4Bg",
          "RenderMarkdownH5Bg",
          "RenderMarkdownH6Bg",
        },
        foregrounds = {
          "RenderMarkdownH1",
          "RenderMarkdownH2",
          "RenderMarkdownH3",
          "RenderMarkdownH4",
          "RenderMarkdownH5",
          "RenderMarkdownH6",
        },
      },
      code = {
        enabled = true,
        sign = true,
        style = "full",
        position = "left",
        language_pad = 1,
        disable_background = { "diff" },
        width = "full",
        left_pad = 2,
        right_pad = 2,
        min_width = 45,
        border = "thin",
        above = "▄",
        below = "▀",
        highlight = "RenderMarkdownCode",
        highlight_inline = "RenderMarkdownCodeInline",
      },
      bullet = {
        enabled = true,
        icons = { "●", "○", "◆", "◇" },
        left_pad = 0,
        right_pad = 1,
        highlight = "RenderMarkdownBullet",
      },
      checkbox = {
        enabled = true,
        unchecked = {
          icon = "󰄱 ",
          highlight = "RenderMarkdownUnchecked",
        },
        checked = {
          icon = "󰱒 ",
          highlight = "RenderMarkdownChecked",
        },
        custom = {
          todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
        },
      },
      quote = {
        enabled = true,
        icon = "▋",
        repeat_linebreak = true,
        highlight = "RenderMarkdownQuote",
      },
      pipe_table = {
        enabled = true,
        preset = "round",
        style = "full",
        cell = "padded",
        min_width = 0,
        border = {
          "╭", "─", "╮", "│",
          "╰", "─", "╯", "│",
          "├", "─", "┤", "┬",
          "┴", "┼",
        },
        alignment_indicator = "━",
        head = "RenderMarkdownTableHead",
        row = "RenderMarkdownTableRow",
        filler = "RenderMarkdownTableFill",
      },
      callout = {
        note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
        tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
        important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
        warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
        caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
      },
      link = {
        enabled = true,
        image = "󰥶 ",
        email = "󰀓 ",
        hyperlink = "󰌹 ",
        highlight = "RenderMarkdownLink",
        custom = {
          web = { pattern = "^http[s]?://", icon = "󰖟 ", highlight = "RenderMarkdownLink" },
        },
      },
      sign = {
        enabled = true,
        highlight = "RenderMarkdownSign",
      },
      win_options = {
        conceallevel = { rendered = 2 },
        concealcursor = { rendered = "nc" },
      },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)

      -- Custom highlights for catppuccin mocha compatibility
      local colors = require("catppuccin.palettes").get_palette("mocha")
      vim.api.nvim_set_hl(0, "RenderMarkdownH1", { fg = colors.red, bold = true })
      vim.api.nvim_set_hl(0, "RenderMarkdownH2", { fg = colors.peach, bold = true })
      vim.api.nvim_set_hl(0, "RenderMarkdownH3", { fg = colors.yellow, bold = true })
      vim.api.nvim_set_hl(0, "RenderMarkdownH4", { fg = colors.green, bold = true })
      vim.api.nvim_set_hl(0, "RenderMarkdownH5", { fg = colors.sapphire, bold = true })
      vim.api.nvim_set_hl(0, "RenderMarkdownH6", { fg = colors.lavender, bold = true })
      vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { bg = colors.surface0 })
      vim.api.nvim_set_hl(0, "RenderMarkdownH2Bg", { bg = colors.surface0 })
      vim.api.nvim_set_hl(0, "RenderMarkdownH3Bg", { bg = colors.surface0 })
      vim.api.nvim_set_hl(0, "RenderMarkdownH4Bg", { bg = colors.surface0 })
      vim.api.nvim_set_hl(0, "RenderMarkdownH5Bg", { bg = colors.surface0 })
      vim.api.nvim_set_hl(0, "RenderMarkdownH6Bg", { bg = colors.surface0 })
      vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = colors.mantle })
      vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { bg = colors.surface0 })
      vim.api.nvim_set_hl(0, "RenderMarkdownBullet", { fg = colors.mauve })
      vim.api.nvim_set_hl(0, "RenderMarkdownQuote", { fg = colors.surface2 })
      vim.api.nvim_set_hl(0, "RenderMarkdownLink", { fg = colors.blue, underline = true })
      vim.api.nvim_set_hl(0, "RenderMarkdownChecked", { fg = colors.green })
      vim.api.nvim_set_hl(0, "RenderMarkdownUnchecked", { fg = colors.overlay1 })
      vim.api.nvim_set_hl(0, "RenderMarkdownTodo", { fg = colors.yellow })
      vim.api.nvim_set_hl(0, "RenderMarkdownTableHead", { fg = colors.blue, bold = true })
      vim.api.nvim_set_hl(0, "RenderMarkdownTableRow", { fg = colors.text })
      vim.api.nvim_set_hl(0, "RenderMarkdownInfo", { fg = colors.blue })
      vim.api.nvim_set_hl(0, "RenderMarkdownSuccess", { fg = colors.green })
      vim.api.nvim_set_hl(0, "RenderMarkdownHint", { fg = colors.teal })
      vim.api.nvim_set_hl(0, "RenderMarkdownWarn", { fg = colors.yellow })
      vim.api.nvim_set_hl(0, "RenderMarkdownError", { fg = colors.red })
    end,
  },

  -- Rainbow delimiters for better bracket visibility
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")

      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        priority = {
          [""] = 110,
          lua = 210,
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }

      -- Catppuccin mocha colors for rainbow delimiters
      local colors = require("catppuccin.palettes").get_palette("mocha")
      vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { fg = colors.red })
      vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = colors.yellow })
      vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { fg = colors.blue })
      vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", { fg = colors.peach })
      vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", { fg = colors.green })
      vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = colors.mauve })
      vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { fg = colors.teal })
    end,
  },

  -- Todo comments highlighting
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = true,
      sign_priority = 8,
      keywords = {
        FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
      highlight = {
        multiline = true,
        before = "",
        keyword = "wide",
        after = "fg",
        pattern = [[.*<(KEYWORDS)\s*:]],
        comments_only = true,
      },
    },
  },

  -- Color highlighter (shows color codes visually)
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      filetypes = {
        "*",
        css = { css = true, css_fn = true },
        html = { css = true },
      },
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = false,
        RRGGBBAA = true,
        AARRGGBB = true,
        rgb_fn = true,
        hsl_fn = true,
        css = false,
        css_fn = false,
        mode = "background",
        tailwind = false,
        virtualtext = "■",
      },
    },
  },
}

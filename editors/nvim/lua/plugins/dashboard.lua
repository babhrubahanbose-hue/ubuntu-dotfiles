return {
  -- Dashboard/Start screen
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      -- Custom header with ASCII art (space theme)
      dashboard.section.header.val = {
        [[                                                    ]],
        [[                                                    ]],
        [[        ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗]],
        [[        ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║]],
        [[        ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║]],
        [[        ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
        [[        ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║]],
        [[        ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
        [[                                                    ]],
        [[              ✦  . 　　　　   　.　　. 　 ✦           ]],
        [[           　. 　　　    ✦　　 　　　　　　　       　 ]],
        [[        　  ˚  　  　　    *　　　　　　　　　.　　.   ]],
        [[           .　　　　  　　    .　　　ﾟ　  .　　　　　  ]],
        [[             　　　 ,　　　　　　.　　　　　　    　   ]],
        [[                                                    ]],
      }

      dashboard.section.header.opts.hl = "AlphaHeader"

      -- Menu items
      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
        dashboard.button("e", "  New file", ":ene <BAR> startinsert<CR>"),
        dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
        dashboard.button("g", "  Find text", ":Telescope live_grep<CR>"),
        dashboard.button("c", "  Configuration", ":e $MYVIMRC<CR>"),
        dashboard.button("l", "󰒲  Lazy", ":Lazy<CR>"),
        dashboard.button("q", "  Quit", ":qa<CR>"),
      }

      dashboard.section.buttons.opts.hl = "AlphaButtons"

      -- Footer
      local function footer()
        local stats = require("lazy").stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        return "⚡ Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms"
      end

      dashboard.section.footer.val = footer()
      dashboard.section.footer.opts.hl = "AlphaFooter"

      -- Layout
      dashboard.config.layout = {
        { type = "padding", val = 2 },
        dashboard.section.header,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
        { type = "padding", val = 1 },
        dashboard.section.footer,
      }

      -- Highlight groups
      vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#89b4fa" })
      vim.api.nvim_set_hl(0, "AlphaButtons", { fg = "#cdd6f4" })
      vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#6c7086" })

      alpha.setup(dashboard.config)

      -- Update footer after lazy loads
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          dashboard.section.footer.val = footer()
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },
}

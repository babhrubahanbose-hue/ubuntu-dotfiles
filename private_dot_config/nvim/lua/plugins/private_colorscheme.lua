return {
  -- Gruvbox for specific filetypes (Python, C, C++, JS, HTML, CSS, Haskell)
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      terminal_colors = true,
      undercurl = true,
      underline = true,
      bold = true,
      italic = {
        strings = false,
        emphasis = true,
        comments = true,
        operators = false,
        folds = true,
      },
      strikethrough = true,
      invert_selection = false,
      invert_signs = false,
      invert_tabline = false,
      invert_intend_guides = false,
      inverse = true,
      contrast = "hard", -- "hard", "soft" or empty string
      palette_overrides = {},
      overrides = {
        -- Match VS Code Gruvbox customizations
        ["@function"] = { fg = "#fabd2f", bold = true },
        ["@function.call"] = { fg = "#fe8019" },
        ["@function.builtin"] = { fg = "#fe8019" },
        ["@method"] = { fg = "#d3869b", bold = true, italic = true },
        ["@method.call"] = { fg = "#b16286" },
        ["@type"] = { fg = "#b8bb26", bold = true, italic = true },
        ["@type.definition"] = { fg = "#b8bb26", bold = true, italic = true },
        ["@type.builtin"] = { fg = "#8ec07c" },
        ["@constructor"] = { fg = "#8ec07c" },
        ["@variable"] = { fg = "#98710f" },
        ["@variable.builtin"] = { fg = "#458588", italic = true },
        ["@parameter"] = { fg = "#3d2ffa", italic = true },
        ["@constant"] = { fg = "#d65d0e", bold = true },
        ["@constant.builtin"] = { fg = "#d65d0e", bold = true },
        ["@property"] = { fg = "#458588" },
        ["@field"] = { fg = "#458588" },
        ["@comment"] = { fg = "#928374", bold = true, italic = true },
        ["@string"] = { fg = "#8408a0", bold = true },
        ["@number"] = { fg = "#d3869b" },
        ["@keyword"] = { fg = "#fb4934", bold = true },
        ["@keyword.function"] = { fg = "#fb4934", bold = true },
        ["@keyword.return"] = { fg = "#fb4934", bold = true },
        ["@conditional"] = { fg = "#fb4934", bold = true },
        ["@repeat"] = { fg = "#fb4934", bold = true },
        ["@include"] = { fg = "#fb4934", bold = true },
        ["@exception"] = { fg = "#fb4934", bold = true },
        -- LSP semantic tokens
        ["@lsp.type.function"] = { fg = "#fe8019" },
        ["@lsp.typemod.function.declaration"] = { fg = "#fabd2f", bold = true },
        ["@lsp.typemod.function.definition"] = { fg = "#fabd2f", bold = true },
        ["@lsp.type.method"] = { fg = "#b16286" },
        ["@lsp.typemod.method.declaration"] = { fg = "#d3869b", bold = true, italic = true },
        ["@lsp.type.class"] = { fg = "#8ec07c" },
        ["@lsp.typemod.class.declaration"] = { fg = "#b8bb26", bold = true, italic = true },
        ["@lsp.type.variable"] = { fg = "#98710f" },
        ["@lsp.typemod.variable.declaration"] = { fg = "#d79921", bold = true },
        ["@lsp.type.parameter"] = { fg = "#3d2ffa", italic = true },
      },
      dim_inactive = false,
      transparent_mode = true,
    },
    config = function(_, opts)
      require("gruvbox").setup(opts)
    end,
  },

  -- Catppuccin for all other filetypes (default)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      term_colors = true,
      styles = {
        comments = { "italic", "bold" },
        conditionals = { "bold" },
        loops = { "bold" },
        functions = { "bold" },
        keywords = { "bold" },
        strings = { "bold" },
        variables = {},
        numbers = {},
        booleans = { "bold" },
        properties = {},
        types = { "italic", "bold" },
        operators = {},
      },
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        telescope = true,
        treesitter = true,
        which_key = true,
        indent_blankline = { enabled = true },
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        semantic_tokens = true,
        rainbow_delimiters = true,
        render_markdown = true,
        markdown = true,
      },
      custom_highlights = function(colors)
        -- =====================================================
        -- GRUVBOX-INSPIRED COLORS (matching VS Code config)
        -- =====================================================
        local gruvbox = {
          -- Functions
          func_decl = "#fabd2f",      -- Yellow (bold)
          func_call = "#fe8019",      -- Orange

          -- Classes
          class_decl = "#b8bb26",     -- Green (italic bold)
          class_ref = "#8ec07c",      -- Aqua

          -- Methods
          method_decl = "#d3869b",    -- Pink (italic bold)
          method_call = "#b16286",    -- Purple

          -- Variables
          var_decl = "#d79921",       -- Gold (bold)
          var_ref = "#98710f",        -- Darker gold

          -- Instance variables
          instance_decl = "#83a598",  -- Blue (italic)
          instance_ref = "#458588",   -- Darker blue

          -- Parameters
          parameter = "#3d2ffa",      -- Bright blue (italic)

          -- Numbers
          number = "#d3869b",         -- Pink

          -- Strings
          string = "#8408a0",         -- Purple (bold)

          -- Keywords
          keyword = "#fb4934",        -- Red (bold)

          -- Constants
          constant = "#d65d0e",       -- Orange (bold)

          -- Comments
          comment = "#928374",        -- Gray (italic bold)
        }

        return {
          -- ============================================
          -- FUNCTIONS
          -- ============================================
          -- Function definition/declaration (bold, yellow)
          ["@function"] = { fg = gruvbox.func_decl, bold = true },
          ["@lsp.type.function"] = { fg = gruvbox.func_call },
          ["@lsp.typemod.function.declaration"] = { fg = gruvbox.func_decl, bold = true },
          ["@lsp.typemod.function.definition"] = { fg = gruvbox.func_decl, bold = true },
          -- Function calls (orange)
          ["@function.call"] = { fg = gruvbox.func_call },
          ["@lsp.typemod.function.defaultLibrary"] = { fg = gruvbox.func_call },
          ["@function.builtin"] = { fg = gruvbox.func_call },

          -- ============================================
          -- METHODS
          -- ============================================
          -- Method definition (italic bold, pink)
          ["@method"] = { fg = gruvbox.method_decl, italic = true, bold = true },
          ["@lsp.type.method"] = { fg = gruvbox.method_call },
          ["@lsp.typemod.method.declaration"] = { fg = gruvbox.method_decl, italic = true, bold = true },
          ["@lsp.typemod.method.definition"] = { fg = gruvbox.method_decl, italic = true, bold = true },
          -- Method calls (purple)
          ["@method.call"] = { fg = gruvbox.method_call },
          ["@lsp.typemod.method.defaultLibrary"] = { fg = gruvbox.method_call },

          -- ============================================
          -- CLASSES / TYPES
          -- ============================================
          -- Class/Type definition (italic bold, green)
          ["@type"] = { fg = gruvbox.class_decl, italic = true, bold = true },
          ["@type.definition"] = { fg = gruvbox.class_decl, italic = true, bold = true },
          ["@lsp.type.class"] = { fg = gruvbox.class_ref },
          ["@lsp.typemod.class.declaration"] = { fg = gruvbox.class_decl, italic = true, bold = true },
          ["@lsp.typemod.class.definition"] = { fg = gruvbox.class_decl, italic = true, bold = true },
          -- Class/Type references (aqua)
          ["@type.builtin"] = { fg = gruvbox.class_ref },
          ["@lsp.typemod.class.defaultLibrary"] = { fg = gruvbox.class_ref },
          ["@constructor"] = { fg = gruvbox.class_ref },

          -- ============================================
          -- VARIABLES
          -- ============================================
          -- Variable definition (bold, gold)
          ["@variable"] = { fg = gruvbox.var_ref },
          ["@lsp.type.variable"] = { fg = gruvbox.var_ref },
          ["@lsp.typemod.variable.declaration"] = { fg = gruvbox.var_decl, bold = true },
          ["@lsp.typemod.variable.definition"] = { fg = gruvbox.var_decl, bold = true },
          -- Variable references (darker gold)
          ["@lsp.typemod.variable.readonly"] = { fg = gruvbox.var_decl },
          ["@variable.builtin"] = { fg = gruvbox.instance_ref, italic = true },

          -- ============================================
          -- INSTANCE VARIABLES
          -- ============================================
          ["@variable.member"] = { fg = gruvbox.instance_ref },
          ["@lsp.typemod.variable.instance"] = { fg = gruvbox.instance_ref },
          ["@lsp.typemod.variable.instance.declaration"] = { fg = gruvbox.instance_decl, italic = true },

          -- ============================================
          -- PARAMETERS
          -- ============================================
          ["@parameter"] = { fg = gruvbox.parameter, italic = true },
          ["@lsp.type.parameter"] = { fg = gruvbox.parameter, italic = true },

          -- ============================================
          -- CONSTANTS
          -- ============================================
          ["@constant"] = { fg = gruvbox.constant, bold = true },
          ["@constant.builtin"] = { fg = gruvbox.constant, bold = true },
          ["@lsp.type.enumMember"] = { fg = gruvbox.constant, bold = true },
          ["@lsp.typemod.variable.static"] = { fg = gruvbox.constant, bold = true },

          -- ============================================
          -- PROPERTIES / FIELDS
          -- ============================================
          ["@property"] = { fg = gruvbox.instance_ref },
          ["@field"] = { fg = gruvbox.instance_ref },
          ["@lsp.type.property"] = { fg = gruvbox.instance_ref },

          -- ============================================
          -- COMMENTS (italic bold, gray)
          -- ============================================
          ["@comment"] = { fg = gruvbox.comment, italic = true, bold = true },
          ["Comment"] = { fg = gruvbox.comment, italic = true, bold = true },

          -- ============================================
          -- STRINGS (bold, purple)
          -- ============================================
          ["@string"] = { fg = gruvbox.string, bold = true },
          ["String"] = { fg = gruvbox.string, bold = true },
          ["@string.escape"] = { fg = gruvbox.method_decl },
          ["@string.special"] = { fg = gruvbox.method_decl },

          -- ============================================
          -- NUMBERS (pink)
          -- ============================================
          ["@number"] = { fg = gruvbox.number },
          ["@number.float"] = { fg = gruvbox.number },
          ["Number"] = { fg = gruvbox.number },
          ["Float"] = { fg = gruvbox.number },

          -- ============================================
          -- KEYWORDS (bold, red)
          -- ============================================
          ["@keyword"] = { fg = gruvbox.keyword, bold = true },
          ["@keyword.function"] = { fg = gruvbox.keyword, bold = true },
          ["@keyword.return"] = { fg = gruvbox.keyword, bold = true },
          ["@keyword.operator"] = { fg = gruvbox.keyword, bold = true },
          ["@conditional"] = { fg = gruvbox.keyword, bold = true },
          ["@repeat"] = { fg = gruvbox.keyword, bold = true },
          ["@include"] = { fg = gruvbox.keyword, bold = true },
          ["@exception"] = { fg = gruvbox.keyword, bold = true },
          ["Keyword"] = { fg = gruvbox.keyword, bold = true },

          -- ============================================
          -- OPERATORS & PUNCTUATION
          -- ============================================
          ["@operator"] = { fg = gruvbox.class_ref },
          ["@punctuation.bracket"] = { fg = colors.overlay2 },
          ["@punctuation.delimiter"] = { fg = colors.overlay2 },
          ["@punctuation.special"] = { fg = gruvbox.class_ref },

          -- ============================================
          -- NAMESPACES / MODULES
          -- ============================================
          ["@namespace"] = { fg = gruvbox.class_ref },
          ["@lsp.type.namespace"] = { fg = gruvbox.class_ref },
        }
      end,
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      -- Colorscheme is set by autocmds.lua based on filetype
    end,
  },
}

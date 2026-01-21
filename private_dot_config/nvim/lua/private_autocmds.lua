local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- ============================================
-- COLORSCHEME SWITCHING BY FILETYPE
-- ============================================
-- Gruvbox for: Python, C, C++, JavaScript, HTML, CSS, Haskell
-- Catppuccin for: Everything else
-- ============================================

local colorscheme_group = augroup("ColorschemeSwitch", { clear = true })

-- Filetypes that should use Gruvbox
local gruvbox_filetypes = {
  python = true,
  c = true,
  cpp = true,
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
  html = true,
  css = true,
  scss = true,
  haskell = true,
}

-- Track current colorscheme to avoid unnecessary switches
local current_colorscheme = "catppuccin"

local function set_colorscheme_for_filetype()
  local ft = vim.bo.filetype
  local target_scheme = gruvbox_filetypes[ft] and "gruvbox" or "catppuccin"

  if current_colorscheme ~= target_scheme then
    vim.cmd.colorscheme(target_scheme)
    current_colorscheme = target_scheme
  end
end

-- Switch colorscheme when entering a buffer
autocmd({ "BufEnter", "FileType" }, {
  group = colorscheme_group,
  callback = set_colorscheme_for_filetype,
  desc = "Switch colorscheme based on filetype",
})

-- Set initial colorscheme
vim.cmd.colorscheme("catppuccin")

-- General settings group
local general = augroup("General", { clear = true })

-- Highlight on yank
autocmd("TextYankPost", {
  group = general,
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
  desc = "Highlight yanked text",
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  group = general,
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
  desc = "Remove trailing whitespace",
})

-- Return to last edit position when opening files
autocmd("BufReadPost", {
  group = general,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = "Return to last edit position",
})

-- Auto resize panes when resizing nvim window
autocmd("VimResized", {
  group = general,
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
  desc = "Auto resize panes",
})

-- Python specific settings
local python = augroup("Python", { clear = true })

autocmd("FileType", {
  group = python,
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 88 -- Black's default line length
    vim.opt_local.colorcolumn = "88"
  end,
  desc = "Python specific settings",
})

-- Terminal settings
local terminal = augroup("Terminal", { clear = true })

autocmd("TermOpen", {
  group = terminal,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.cmd("startinsert")
  end,
  desc = "Terminal buffer settings",
})

-- Create parent directories on save if they don't exist
autocmd("BufWritePre", {
  group = general,
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = (vim.uv or vim.loop).fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
  desc = "Create parent directories",
})

-- Markdown settings
local markdown = augroup("Markdown", { clear = true })

autocmd("FileType", {
  group = markdown,
  pattern = "markdown",
  callback = function()
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = "nc"
  end,
  desc = "Markdown rendering settings",
})

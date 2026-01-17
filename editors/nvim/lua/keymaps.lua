local map = vim.keymap.set

-- NOTE: Ctrl+z is NOT mapped here as it's your tmux leader

-- ============================================
-- GENERAL MAPPINGS
-- ============================================
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Better movement
map("n", "j", "gj", { desc = "Move down (wrapped lines)" })
map("n", "k", "gk", { desc = "Move up (wrapped lines)" })

-- Keep cursor centered
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centered" })
map("n", "n", "nzzzv", { desc = "Next search centered" })
map("n", "N", "Nzzzv", { desc = "Prev search centered" })

-- Better indenting
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Move lines up/down
map("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
map("i", "<A-j>", "<Esc><cmd>m .+1<CR>==gi", { desc = "Move line down" })
map("i", "<A-k>", "<Esc><cmd>m .-2<CR>==gi", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- ============================================
-- LEADER KEY MAPPINGS (Space as leader)
-- ============================================

-- File operations
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>W", "<cmd>wa<CR>", { desc = "Save all files" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa<CR>", { desc = "Quit all" })

-- ============================================
-- FIND / TELESCOPE (leader + f)
-- ============================================
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "Recent files" })
map("n", "<leader>fw", "<cmd>Telescope grep_string<CR>", { desc = "Grep word under cursor" })
map("n", "<leader>fc", "<cmd>Telescope commands<CR>", { desc = "Commands" })
map("n", "<leader>fk", "<cmd>Telescope keymaps<CR>", { desc = "Keymaps" })
map("n", "<leader>fr", "<cmd>Telescope resume<CR>", { desc = "Resume last search" })
map("n", "<leader>fs", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "Search in buffer" })
map("n", "<leader>fm", "<cmd>Telescope marks<CR>", { desc = "Marks" })
map("n", "<leader>fR", "<cmd>Telescope registers<CR>", { desc = "Registers" })

-- ============================================
-- LSP MAPPINGS (leader + l)
-- ============================================
map("n", "<leader>ld", "<cmd>Telescope lsp_definitions<CR>", { desc = "Go to definition" })
map("n", "<leader>lr", "<cmd>Telescope lsp_references<CR>", { desc = "References" })
map("n", "<leader>li", "<cmd>Telescope lsp_implementations<CR>", { desc = "Implementations" })
map("n", "<leader>lt", "<cmd>Telescope lsp_type_definitions<CR>", { desc = "Type definitions" })
map("n", "<leader>ls", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Document symbols" })
map("n", "<leader>lw", "<cmd>Telescope lsp_workspace_symbols<CR>", { desc = "Workspace symbols" })
map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>ln", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format file" })
map("n", "<leader>lh", vim.lsp.buf.hover, { desc = "Hover documentation" })
map("n", "<leader>lD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "<leader>lk", vim.lsp.buf.signature_help, { desc = "Signature help" })
map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", { desc = "Go to definition" })
map("n", "gr", "<cmd>Telescope lsp_references<CR>", { desc = "References" })
map("n", "gi", "<cmd>Telescope lsp_implementations<CR>", { desc = "Implementations" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })

-- ============================================
-- BUFFER MAPPINGS (leader + b)
-- ============================================
map("n", "<leader>bb", "<cmd>Telescope buffers<CR>", { desc = "List buffers" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bD", "<cmd>%bdelete|edit#|bdelete#<CR>", { desc = "Delete all buffers except current" })
map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })

-- ============================================
-- WINDOW MAPPINGS (leader + w prefix for splits)
-- ============================================
map("n", "<leader>wv", "<cmd>vsplit<CR>", { desc = "Vertical split" })
map("n", "<leader>ws", "<cmd>split<CR>", { desc = "Horizontal split" })
map("n", "<leader>wc", "<cmd>close<CR>", { desc = "Close window" })
map("n", "<leader>wo", "<cmd>only<CR>", { desc = "Close other windows" })
map("n", "<leader>w=", "<C-w>=", { desc = "Equal window sizes" })

-- Window navigation (also available without leader)
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to below window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to above window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize windows
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- ============================================
-- GIT MAPPINGS (leader + g)
-- ============================================
map("n", "<leader>gg", "<cmd>Telescope git_status<CR>", { desc = "Git status" })
map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", { desc = "Git commits" })
map("n", "<leader>gb", "<cmd>Telescope git_branches<CR>", { desc = "Git branches" })
map("n", "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>", { desc = "Stage hunk" })
map("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
map("n", "<leader>gS", "<cmd>Gitsigns stage_buffer<CR>", { desc = "Stage buffer" })
map("n", "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<CR>", { desc = "Undo stage hunk" })
map("n", "<leader>gR", "<cmd>Gitsigns reset_buffer<CR>", { desc = "Reset buffer" })
map("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })
map("n", "<leader>gB", "<cmd>Gitsigns blame_line<CR>", { desc = "Blame line" })
map("n", "<leader>gd", "<cmd>Gitsigns diffthis<CR>", { desc = "Diff this" })

-- ============================================
-- TERMINAL MAPPINGS (leader + t)
-- ============================================
map("n", "<leader>tt", "<cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })
map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", { desc = "Terminal horizontal" })
map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<CR>", { desc = "Terminal vertical" })
map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", { desc = "Terminal float" })
map("n", "<C-\\>", "<cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })

-- Terminal mode mappings
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Move to left window" })
map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Move to below window" })
map("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Move to above window" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Move to right window" })
map("t", "<C-\\>", "<cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })

-- ============================================
-- CODE/DIAGNOSTICS MAPPINGS (leader + c / x)
-- ============================================
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>cl", "<cmd>LspInfo<CR>", { desc = "LSP info" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- ============================================
-- FOLDING MAPPINGS
-- ============================================
map("n", "za", "za", { desc = "Toggle fold" })
map("n", "zA", "zA", { desc = "Toggle all folds under cursor" })
map("n", "zo", "zo", { desc = "Open fold" })
map("n", "zO", "zO", { desc = "Open all folds under cursor" })
map("n", "zc", "zc", { desc = "Close fold" })
map("n", "zC", "zC", { desc = "Close all folds under cursor" })
map("n", "zR", function() require("ufo").openAllFolds() end, { desc = "Open all folds" })
map("n", "zM", function() require("ufo").closeAllFolds() end, { desc = "Close all folds" })
map("n", "zr", function() require("ufo").openFoldsExceptKinds() end, { desc = "Open folds except kinds" })
map("n", "zm", function() require("ufo").closeFoldsWith() end, { desc = "Close folds with level" })
map("n", "<leader>z", "za", { desc = "Toggle fold" })

-- ============================================
-- SEARCH MAPPINGS (leader + s)
-- ============================================
map("n", "<leader>sr", "<cmd>Telescope resume<CR>", { desc = "Resume last search" })
map("n", "<leader>sw", "<cmd>Telescope grep_string<CR>", { desc = "Search word under cursor" })
map("n", "<leader>sg", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
map("n", "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "Search in buffer" })
map("n", "<leader>sh", "<cmd>Telescope search_history<CR>", { desc = "Search history" })
map("n", "<leader>sc", "<cmd>Telescope command_history<CR>", { desc = "Command history" })

-- ============================================
-- FILE EXPLORER
-- ============================================
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
map("n", "<leader>E", "<cmd>NvimTreeFocus<CR>", { desc = "Focus file explorer" })

-- ============================================
-- MISC MAPPINGS
-- ============================================
-- Quick access
map("n", "<leader>,", "<cmd>Telescope buffers<CR>", { desc = "Switch buffer" })
map("n", "<leader><space>", "<cmd>Telescope find_files<CR>", { desc = "Find files" })

-- Yank to system clipboard explicitly
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
map("n", "<leader>Y", '"+Y', { desc = "Yank line to clipboard" })

-- Paste from system clipboard
map({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from clipboard" })
map({ "n", "v" }, "<leader>P", '"+P', { desc = "Paste before from clipboard" })

-- Delete without yanking
map({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yank" })

-- Select all
map("n", "<leader>a", "ggVG", { desc = "Select all" })

-- Quick fix list navigation
map("n", "<leader>cn", "<cmd>cnext<CR>", { desc = "Next quickfix" })
map("n", "<leader>cp", "<cmd>cprev<CR>", { desc = "Previous quickfix" })
map("n", "<leader>co", "<cmd>copen<CR>", { desc = "Open quickfix" })
map("n", "<leader>cc", "<cmd>cclose<CR>", { desc = "Close quickfix" })

-- Diagnostics list
map("n", "<leader>xx", "<cmd>TroubleToggle<CR>", { desc = "Toggle Trouble" })
map("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<CR>", { desc = "Workspace diagnostics" })
map("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<CR>", { desc = "Document diagnostics" })
map("n", "<leader>xq", "<cmd>TroubleToggle quickfix<CR>", { desc = "Quickfix list" })
map("n", "<leader>xl", "<cmd>TroubleToggle loclist<CR>", { desc = "Location list" })

-- ============================================
-- MARKDOWN MAPPINGS (leader + m)
-- ============================================
map("n", "<leader>mt", "<cmd>RenderMarkdown toggle<CR>", { desc = "Toggle markdown rendering" })
map("n", "<leader>me", "<cmd>RenderMarkdown enable<CR>", { desc = "Enable markdown rendering" })
map("n", "<leader>md", "<cmd>RenderMarkdown disable<CR>", { desc = "Disable markdown rendering" })

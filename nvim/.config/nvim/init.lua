-- LSP/picker selections must be set before LazyVim extras are evaluated.
vim.g.lazyvim_php_lsp = "intelephense"
vim.g.lazyvim_picker = "snacks"

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

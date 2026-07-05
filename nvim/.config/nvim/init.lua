-- LSP/picker selections must be set before LazyVim extras are evaluated.
vim.g.lazyvim_php_lsp = "intelephense"
vim.g.lazyvim_picker = "snacks"

-- AI completion backend: "minuet" (local Ollama FIM, default) or "copilot"
-- (GitHub Copilot). See lua/plugins/ai-completion.lua and lua/plugins/copilot.lua.
vim.g.ai_provider = "minuet"

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

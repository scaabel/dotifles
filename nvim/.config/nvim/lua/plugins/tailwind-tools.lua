-- Inline color swatches for Tailwind classes, plus :TailwindSort /
-- :TailwindConcealToggle. Pairs with the lazyvim.plugins.extras.lang.tailwind
-- extra already enabled in extras.lua (LSP/completion for class names).
return {
  "luckasRanarison/tailwind-tools.nvim",
  name = "tailwind-tools",
  build = ":UpdateRemotePlugins",
  dependencies = { "nvim-treesitter/nvim-treesitter", "neovim/nvim-lspconfig" },
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    document_color = { enabled = true, kind = "inline" },
  },
}

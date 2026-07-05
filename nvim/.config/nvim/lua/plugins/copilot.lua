-- GitHub Copilot as an alternative to the local minuet-ai engine
-- (lua/plugins/ai-completion.lua). Flip vim.g.ai_provider in init.lua between
-- "minuet" (default) and "copilot" to switch — no other changes needed.
--
-- Ghost-text suggestions only, same UX as blink-edit.nvim's inline predictions.
-- Run :Copilot auth once after enabling to sign in.
return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  enabled = function()
    return vim.g.ai_provider == "copilot"
  end,
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,
      keymap = {
        accept = "<Tab>",
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
    },
    panel = { enabled = false },
  },
}

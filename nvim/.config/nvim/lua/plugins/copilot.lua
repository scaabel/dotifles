-- GitHub Copilot as an alternative to the local minuet-ai engine
-- (lua/plugins/ai-completion.lua). Flip vim.g.ai_provider in init.lua between
-- "minuet" (default) and "copilot" to switch — no other changes needed.
--
-- Suggestions surface two ways: inline ghost text (accepted with <S-Tab>, wired
-- through blink.cmp below) and entries in the blink.cmp menu via blink-copilot.
-- blink.cmp itself stays enabled regardless of provider.
-- Run :Copilot auth once after enabling to sign in.
return {
  {
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
          -- accept handled by blink.cmp's <S-Tab> so the two plugins never
          -- race for the same key
          accept = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      panel = { enabled = false },
    },
  },

  -- Copilot in the blink.cmp menu + <S-Tab> to accept ghost text.
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = {
      {
        "fang2hou/blink-copilot",
        enabled = function()
          return vim.g.ai_provider == "copilot"
        end,
      },
    },
    opts = function(_, opts)
      if vim.g.ai_provider ~= "copilot" then
        return
      end
      opts.sources = opts.sources or {}
      opts.sources.default = opts.sources.default or {}
      table.insert(opts.sources.default, "copilot")
      opts.sources.providers = vim.tbl_deep_extend("force", opts.sources.providers or {}, {
        copilot = {
          name = "copilot",
          module = "blink-copilot",
          async = true,
          score_offset = 100,
        },
      })
      opts.keymap = opts.keymap or {}
      opts.keymap["<S-Tab>"] = {
        function()
          local ok, suggestion = pcall(require, "copilot.suggestion")
          if ok and suggestion.is_visible() then
            suggestion.accept()
            return true
          end
        end,
        "snippet_backward",
        "fallback",
      }
    end,
  },
}

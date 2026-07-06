-- Set vim.g.ai_provider = "copilot" in init.lua to swap this out for GitHub
-- Copilot (lua/plugins/copilot.lua) instead of the local minuet engine.
return {
  -- Local FIM completion engine (Ollama + qwen2.5-coder), surfaced via blink.cmp.
  {
    "milanglacier/minuet-ai.nvim",
    event = "InsertEnter",
    enabled = function()
      return vim.g.ai_provider == "minuet"
    end,
    opts = {
      provider = "openai_fim_compatible",
      n_completions = 1,
      context_window = 512,
      request_timeout = 3,
      throttle = 400,
      debounce = 100,
      provider_options = {
        openai_fim_compatible = {
          api_key = "TERM",
          name = "Ollama",
          end_point = "http://localhost:11434/v1/completions",
          model = "qwen2.5-coder:1.5b-base",
          optional = { max_tokens = 128, top_p = 0.9 },
        },
      },
    },
    config = function(_, opts)
      require("minuet").setup(opts)
    end,
  },

  -- Register minuet as a blink.cmp source (appended to the default source list).
  -- blink.cmp itself stays enabled for every provider — only the minuet source
  -- is conditional, so LSP/snippets/buffer completion keeps working when the
  -- provider is "copilot".
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      if vim.g.ai_provider ~= "minuet" then
        return
      end
      opts.sources = opts.sources or {}
      opts.sources.default = opts.sources.default or {}
      table.insert(opts.sources.default, "minuet")
      opts.sources.providers = vim.tbl_deep_extend("force", opts.sources.providers or {}, {
        minuet = {
          name = "minuet",
          module = "minuet.blink",
          async = true,
          timeout_ms = 3000,
          score_offset = 50,
        },
      })
      opts.completion = vim.tbl_deep_extend("force", opts.completion or {}, {
        trigger = { prefetch_on_insert = false },
      })
    end,
  },

  -- Local next-edit ("sweep") prediction as inline ghost text.
  {
    "BlinkResearchLabs/blink-edit.nvim",
    event = "InsertEnter",
    enabled = function()
      return vim.g.ai_provider == "minuet"
    end,
    opts = {
      llm = {
        backend = "ollama",
        provider = "sweep",
        url = "http://localhost:11434",
        model = "sweepai/sweep-next-edit",
      },
    },
    config = function(_, opts)
      require("blink-edit").setup(opts)
    end,
  },
}

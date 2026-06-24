return {
  -- Local FIM completion engine (Ollama + qwen2.5-coder), surfaced via blink.cmp.
  {
    "milanglacier/minuet-ai.nvim",
    event = "InsertEnter",
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

  -- Register minuet as a blink.cmp source (extends the default source list).
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        default = { "minuet" },
        providers = {
          minuet = {
            name = "minuet",
            module = "minuet.blink",
            async = true,
            timeout_ms = 3000,
            score_offset = 50,
          },
        },
      },
      completion = { trigger = { prefetch_on_insert = false } },
    },
  },

  -- Local next-edit ("sweep") prediction as inline ghost text.
  {
    "BlinkResearchLabs/blink-edit.nvim",
    event = "InsertEnter",
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

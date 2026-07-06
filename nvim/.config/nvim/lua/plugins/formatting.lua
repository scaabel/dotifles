-- Disable format-on-save for large files (consistent with the large-file inlay hint
-- threshold in typescript.lua). Manual formatting via `<leader>cf` always works;
-- toggle per-buffer with `<leader>uF`.
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function(args)
    local lines = vim.api.nvim_buf_line_count(args.buf)
    local bytes = vim.fn.getfsize(vim.api.nvim_buf_get_name(args.buf))
    if lines > 700 or (bytes > 0 and bytes > 100 * 1024) then
      vim.b[args.buf].autoformat = false
    end
  end,
})

return {
  -- ensure the biome binary is installed
  { "mason-org/mason.nvim", opts = { ensure_installed = { "biome" } } },

  -- register biome as the formatter for the filetypes it supports.
  -- conform's built-in biome formatter uses a project biome.json{,c} when
  -- present, else biome defaults; command resolves local node_modules first.
  {
    "stevearc/conform.nvim",
    optional = true,
    ---@param opts conform.setupOpts
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      local fts = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "json",
        "jsonc",
      }
      for _, ft in ipairs(fts) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        table.insert(opts.formatters_by_ft[ft], 1, "biome") -- biome first
      end

      -- Without a project biome.json{,c}, biome's defaults inject semicolons,
      -- trailing commas, and buffer-derived indentation — enforce house style
      -- instead. Projects with their own biome config keep full control.
      opts.formatters = opts.formatters or {}
      opts.formatters.biome = {
        args = function(self, ctx)
          local args = { "format", "--stdin-file-path", "$FILENAME" }
          if not self:cwd(ctx) then
            vim.list_extend(args, {
              "--semicolons=as-needed",
              "--trailing-commas=none",
              "--indent-style=space",
              "--indent-width=2",
              "--javascript-formatter-quote-style=single",
            })
          end
          return args
        end,
      }
    end,
  },
}

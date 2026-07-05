-- Trim down LazyVim's default lualine: single-letter mode, no clock, and an
-- attached-LSP indicator so you can see when the client has actually loaded.
return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    -- NORMAL -> N, INSERT -> I, VISUAL -> V, etc.
    opts.sections.lualine_a = {
      {
        "mode",
        fmt = function(str)
          return str:sub(1, 1)
        end,
      },
    }

    -- Name(s) of the LSP client(s) attached to the current buffer, blank
    -- until one actually attaches.
    table.insert(opts.sections.lualine_x, 1, {
      function()
        local names = {}
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
          table.insert(names, client.name)
        end
        return " " .. table.concat(names, ", ")
      end,
      cond = function()
        return #vim.lsp.get_clients({ bufnr = 0 }) > 0
      end,
      color = function()
        return { fg = Snacks.util.color("Special") }
      end,
    })

    -- Drop the clock.
    opts.sections.lualine_z = {}

    return opts
  end,
}

-- Disable inlay hints on large TS/JS files for performance (ports the pre-LazyVim
-- typescript-tools optimization onto vtsls).
-- Uses Snacks.util.lsp.on to run AFTER LazyVim's inlay-hint enable handler.
vim.schedule(function()
  require("snacks").util.lsp.on({ method = "textDocument/inlayHint" }, function(buf)
    local ft = vim.bo[buf].filetype
    if ft ~= "typescript" and ft ~= "typescriptreact" and ft ~= "javascript" and ft ~= "javascriptreact" then
      return
    end
    local lines = vim.api.nvim_buf_line_count(buf)
    local bytes = vim.fn.getfsize(vim.api.nvim_buf_get_name(buf))
    if lines > 700 or (bytes > 0 and bytes > 100 * 1024) then
      vim.lsp.inlay_hint.enable(false, { bufnr = buf })
      vim.notify("Large TS/JS file: inlay hints disabled", vim.log.levels.INFO)
    end
  end)
end)

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          settings = {
            typescript = {
              tsserver = { maxTsServerMemory = 4096 },
              preferences = { importModuleSpecifier = "non-relative" },
            },
          },
        },
      },
    },
  },
}

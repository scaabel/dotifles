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
  -- LazyVim's autoformat already handles formatter detection from mason packages
  -- (prettierd, ruff, php-cs-fixer, stylua). No extra config needed.
}

-- Persist the last-selected colorscheme across sessions (replaces the old theme-picker).
local state_file = vim.fn.stdpath("state") .. "/last_colorscheme"

local function read_saved()
  local f = io.open(state_file, "r")
  if not f then
    return nil
  end
  local name = f:read("*l")
  f:close()
  if name and #name > 0 then
    return name
  end
  return nil
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function(ev)
    local f = io.open(state_file, "w")
    if f then
      f:write(ev.match or vim.g.colors_name or "")
      f:close()
    end
  end,
})

return {
  { "EdenEast/nightfox.nvim", lazy = true },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = read_saved() or "catppuccin",
    },
  },
}

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- ============================================================================
-- console.log helpers
-- ============================================================================

-- Insert a labelled console.log for a given identifier on the line below the
-- cursor, matching the indentation of the current line. Produces:
--   console.log(`logging ${x} >>`, { x })
local function console_log(name)
  if not name or name == "" then
    return
  end
  local indent = vim.api.nvim_get_current_line():match("^%s*") or ""
  local line = string.format("%sconsole.log(`logging ${%s} >>`, { %s })", indent, name, name)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row, row, false, { line })
  vim.api.nvim_win_set_cursor(0, { row + 1, #line })
end

-- Normal mode: log the <cword> under the cursor.
map("n", "<leader>cl", function()
  console_log(vim.fn.expand("<cword>"))
end, { desc = "Console log word under cursor" })

-- Visual mode: log the current selection (handles dotted/member expressions).
map("x", "<leader>cl", function()
  -- Reselect the last visual range and yank it into register z without
  -- clobbering the unnamed register.
  local save = vim.fn.getreg("z")
  vim.cmd('noautocmd normal! gv"zy')
  local sel = vim.fn.getreg("z"):gsub("\n", "")
  vim.fn.setreg("z", save)
  console_log(sel)
end, { desc = "Console log selection" })

-- Comment out every console.* line in the buffer.
map("n", "<leader>cL", function()
  vim.cmd([[silent! %s/^\(\s*\)\(console\.\)/\1\/\/ \2/]])
  vim.cmd("nohlsearch")
end, { desc = "Comment all console logs" })

-- Delete every console.* line in the buffer.
map("n", "<leader>cD", function()
  vim.cmd([[silent! g/^\s*\/\?\/\?\s*console\./d]])
  vim.cmd("nohlsearch")
end, { desc = "Delete all console logs" })

-- ============================================================================
-- clipboard / yank QOL
-- ============================================================================

-- Yank relative path / absolute path / filename of the current buffer.
map("n", "<leader>yp", function()
  local p = vim.fn.expand("%:.")
  vim.fn.setreg("+", p)
  vim.notify("Yanked path: " .. p)
end, { desc = "Yank relative file path" })

map("n", "<leader>yP", function()
  local p = vim.fn.expand("%:p")
  vim.fn.setreg("+", p)
  vim.notify("Yanked path: " .. p)
end, { desc = "Yank absolute file path" })

map("n", "<leader>yn", function()
  local n = vim.fn.expand("%:t")
  vim.fn.setreg("+", n)
  vim.notify("Yanked name: " .. n)
end, { desc = "Yank file name" })

-- Yank "path:line" (e.g. src/foo.ts:42) — handy for PRs, Slack, stack traces.
map("n", "<leader>yl", function()
  local s = vim.fn.expand("%:.") .. ":" .. vim.fn.line(".")
  vim.fn.setreg("+", s)
  vim.notify("Yanked: " .. s)
end, { desc = "Yank path:line" })

-- Yank the whole buffer to the system clipboard.
map("n", "<leader>ya", 'gg"+yG`.', { desc = "Yank whole buffer to clipboard" })

-- Paste over a selection without clobbering the unnamed register.
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking selection" })

-- Delete to the black-hole register (no clobber).
map({ "n", "x" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

-- ============================================================================
-- move / duplicate lines
-- ============================================================================

-- Move the current line / selection up and down (re-indents as it moves).
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
map("x", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("x", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Duplicate the current line / selection (keeps it selected when visual).
map("n", "<A-S-j>", "<cmd>t.<cr>", { desc = "Duplicate line below" })
map("n", "<A-S-k>", "<cmd>t.<cr>k", { desc = "Duplicate line above" })
map("x", "<A-S-j>", ":t'><cr>gv", { desc = "Duplicate selection below" })

-- ============================================================================
-- editing QOL
-- ============================================================================

-- Keep the cursor centered while jumping through search results / half-pages.
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev search result (centered)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Join lines without moving the cursor to the join point.
map("n", "J", "mzJ`z", { desc = "Join lines (keep cursor)" })

-- Stay in visual mode after indenting.
map("x", "<", "<gv", { desc = "Indent left (keep selection)" })
map("x", ">", ">gv", { desc = "Indent right (keep selection)" })

-- Clear search highlight on <Esc> in normal mode.
map("n", "<Esc>", "<cmd>nohlsearch<cr><Esc>", { desc = "Clear search highlight" })

-- ============================================================================
-- search & replace
-- ============================================================================

-- Pre-fill a whole-file substitute for the word under the cursor, leaving the
-- cursor between the slashes ready to type the replacement (not executed):
--   :%s/\<hello\>/█/g
map("n", "<leader>S", [[:%s/\<<C-r><C-w>\>//g<Left><Left>]], { desc = "Replace word under cursor (file)" })

-- Same, but seeded with the visual selection instead of <cword>.
map("x", "<leader>S", function()
  local save = vim.fn.getreg("z")
  vim.cmd('noautocmd normal! gv"zy')
  local sel = vim.fn.getreg("z"):gsub("\n", "")
  vim.fn.setreg("z", save)
  -- Escape regex specials so the selection is matched literally.
  local pat = vim.fn.escape(sel, [[/\.*$^~[]]])
  vim.api.nvim_feedkeys(":%s/" .. pat .. "//g" .. string.rep(vim.api.nvim_replace_termcodes("<Left>", true, false, true), 2), "n", false)
end, { desc = "Replace selection (file)" })

-- cgn rename: change the word under the cursor, then press `n` then `.` to
-- apply the same change to each following occurrence (confirm each one).
map("n", "<leader>rn", function()
  local w = vim.fn.expand("<cword>")
  if w == "" then
    return
  end
  vim.fn.setreg("/", "\\<" .. w .. "\\>")
  vim.opt.hlsearch = true
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("cgn", true, false, true), "n", false)
end, { desc = "Rename word under cursor (n. to repeat)" })

-- Same, seeded with the visual selection (matched literally via \V).
map("x", "<leader>rn", function()
  local save = vim.fn.getreg("z")
  vim.cmd('noautocmd normal! gv"zy')
  local sel = vim.fn.getreg("z"):gsub("\n", "")
  vim.fn.setreg("z", save)
  vim.fn.setreg("/", "\\V" .. vim.fn.escape(sel, "\\"))
  vim.opt.hlsearch = true
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("cgn", true, false, true), "n", false)
end, { desc = "Rename selection (n. to repeat)" })

-- ============================================================================
-- toggles
-- ============================================================================

-- Toggle the word under the cursor between a paired opposite, cursor stays put.
local toggle_words = {
  ["true"] = "false",
  ["false"] = "true",
  ["const"] = "let",
  ["let"] = "const",
  ["yes"] = "no",
  ["no"] = "yes",
  ["on"] = "off",
  ["off"] = "on",
  ["enable"] = "disable",
  ["disable"] = "enable",
  ["null"] = "undefined",
  ["undefined"] = "null",
  ["min"] = "max",
  ["max"] = "min",
  ["and"] = "or",
  ["or"] = "and",
}

map("n", "<leader>~", function()
  local w = vim.fn.expand("<cword>")
  local repl = toggle_words[w:lower()]
  if not repl then
    vim.notify("No toggle for: " .. w, vim.log.levels.WARN)
    return
  end
  local keys = vim.api.nvim_replace_termcodes('"_ciw' .. repl .. "<Esc>", true, false, true)
  vim.api.nvim_feedkeys(keys, "n", false)
end, { desc = "Toggle word under cursor" })

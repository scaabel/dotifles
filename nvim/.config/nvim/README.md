# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## QOL keymaps

Defined in `lua/config/keymaps.lua` (leader is `<space>`).

**console.log helpers**

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>cl` | n | Log word under cursor: `` console.log(`logging ${x} >>`, { x }) `` |
| `<leader>cl` | x | Log the visual selection |
| `<leader>cL` | n | Comment out every `console.*` line |
| `<leader>cD` | n | Delete every `console.*` line |

**clipboard / yank**

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>yp` / `<leader>yP` | n | Yank relative / absolute file path to clipboard |
| `<leader>yn` | n | Yank file name |
| `<leader>yl` | n | Yank `path:line` (e.g. `src/foo.ts:42`) |
| `<leader>ya` | n | Yank whole buffer to clipboard |
| `<leader>p` | x | Paste over selection without clobbering the register |
| `<leader>d` | n/x | Delete to black-hole register |

**move / duplicate lines**

| Key | Mode | Action |
| --- | --- | --- |
| `<A-j>` / `<A-k>` | n/i/x | Move line or selection down / up |
| `<A-S-j>` / `<A-S-k>` | n/x | Duplicate line or selection |

**editing**

| Key | Mode | Action |
| --- | --- | --- |
| `n` / `N` | n | Next / prev search result, centered |
| `<C-d>` / `<C-u>` | n | Half-page scroll, centered |
| `J` | n | Join lines, keep cursor position |
| `<` / `>` | x | Indent, keep selection |
| `<Esc>` | n | Clear search highlight |

**search & replace**

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>S` | n | Pre-fill `:%s/\<word\>//g`, cursor ready for the replacement |
| `<leader>S` | x | Same, seeded with the visual selection (matched literally) |
| `<leader>rn` | n/x | Change word/selection, then `n` `.` to repeat per occurrence (cgn) |

**toggles**

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>~` | n | Toggle word under cursor: `true`↔`false`, `const`↔`let`, `null`↔`undefined`, `and`↔`or`, `min`↔`max`, on/off, yes/no, enable/disable |

## Snippets

VSCode-style snippets in `snippets/`, loaded by blink.cmp (see
`lua/plugins/snippets.lua`). All triggers start with `;` so they never collide
with normal typing — type the prefix and accept from the completion menu.

`javascript.json` (js/ts/jsx/tsx): `;clg` labelled log, `;cl`, `;clt`, `;cle`,
`;clw`, `;dbg`, `;af`/`;aaf` arrow fns, `;fn`/`;afn`, `;ec`/`;ed` exports,
`;imp`/`;impd`/`;impa` imports, `;try`, `;aw` await.

`react.json` (jsx/tsx): `;us` useState, `;ue`/`;uec` useEffect, `;um` useMemo,
`;ucb` useCallback, `;ur` useRef, `;rfc` typed component, `;props` props interface.

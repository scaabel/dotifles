return {
  -- Load personal VSCode-style snippets from <config>/snippets (alongside the
  -- friendly-snippets that ship with LazyVim). This is the blink.cmp default
  -- search path, set explicitly so it keeps working if the default changes.
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        providers = {
          snippets = {
            opts = {
              search_paths = { vim.fn.stdpath("config") .. "/snippets" },
            },
          },
        },
      },
    },
  },
}

-- Peek definitions/references/implementations in a floating window without
-- leaving the current buffer. Complements LazyVim's default gd/gr (which jump).
return {
  "rmagatti/goto-preview",
  event = "VeryLazy",
  opts = {
    default_mappings = false,
    post_open_hook = function(_, win)
      -- Close the floating preview with a single <Esc>, same as other floats.
      vim.keymap.set("n", "<Esc>", function()
        require("goto-preview").close_all_win()
      end, { buffer = vim.api.nvim_win_get_buf(win) })
    end,
  },
  keys = {
    {
      "gpd",
      function()
        require("goto-preview").goto_preview_definition()
      end,
      desc = "Preview definition",
    },
    {
      "gpt",
      function()
        require("goto-preview").goto_preview_type_definition()
      end,
      desc = "Preview type definition",
    },
    {
      "gpi",
      function()
        require("goto-preview").goto_preview_implementation()
      end,
      desc = "Preview implementation",
    },
    {
      "gpr",
      function()
        require("goto-preview").goto_preview_references()
      end,
      desc = "Preview references",
    },
    {
      "gP",
      function()
        require("goto-preview").close_all_win()
      end,
      desc = "Close all preview windows",
    },
  },
}

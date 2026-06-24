return {
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { "haydenmeade/neotest-jest" },
    opts = {
      adapters = {
        ["neotest-jest"] = {
          jestCommand = "npm test --",
          jestConfigFile = "jest.config.ts",
          env = { CI = true },
          cwd = function()
            return vim.fn.getcwd()
          end,
        },
      },
    },
  },
}

# root-climber.nvim

```
vim.api.nvim_create_user_command(
  "Jest",
  function()
    require("root-climber").fzf_run(
      "*.jest.config.js",
      function(config)
        vim.api.nvim_command("TestFile --config " .. config)
      end
    )
  end,
  {nargs = 0}
)
```

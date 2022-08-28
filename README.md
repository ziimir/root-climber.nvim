root-climber.nvim
=================

Makes a list of files matching the mask from the call point to the project root

Problem
-------

Working in monorepo you sometimes might have this situation

```
your-awesome-project/
  packages/
    ui/
      jest.config.js
    entities/
      packages.jest.config.js
  services/
    cool-service/
      jest.config.js
    not-so-cool-service/
      jest.config.js
  jest.config.js
```

Each package or service has its own config file,
and to run the tests (using [vim-test](https://github.com/vim-test/vim-test) for example) you must specify a certain config

This plugin searches for all files matching the mask up to the root of your project,
so you can select and run another command with the path to that file as an argument

Setup
-----

Instal `root-climber.nvim` with your favorite package manager

```lua
require('packer').startup(function(use)
  use 'ziimir/root-climber.nvim'
end)
```

Now you need to specify a command that will find files by some mask, and run other command with the selected file

```lua
vim.api.nvim_create_user_command(
  "Jest",
  function()
    require("root-climber").fzf_run(
      "*.jest.config.js",
      function(path)
        vim.api.nvim_command("TestFile --config " .. path)
      end
    )
  end,
  {nargs = 0}
)
```

API
---

Module exposes `run` and `fzf_run` (requires [fzf.vim](https://github.com/junegunn/fzf.vim)) functions,
they take a file mask to search for, and a callback that will be called when you select an element from the found results

By default, if result contains only one element, then the callback will be called immediately

That can be overwritten by `root_climber#always_confirm` variable

```lua
require('packer').startup(function(use)
  use ({
    'ziimir/root-climber.nvim',
     config = function()
       vim.g["root_climber#always_confirm"] = 1
     end
  }),
end)
```

TODO
----

- add vim doc
- add [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) support

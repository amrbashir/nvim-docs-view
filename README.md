# nvim-docs-view

A neovim plugin to display lsp hover documentation in a side panel.
> Inspired by the VSCode extension [Docs View](https://marketplace.visualstudio.com/items?itemName=bierner.docs-view).

## Installation

Using [vim-plug](https://github.com/junegunn/vim-plug)

```viml
Plug 'amrbashir/nvim-docs-view'

lua << EOF
  require("docs-view").setup {
    position = "right",
    width = 300,
  }
EOF
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "amrbashir/nvim-docs-view",
  config = function()
    require("docs-view").setup {
      position = "right",
      width = 300,
    }
  end
}
```

## Usage

Use `:DocsViewShow` to open the docs view side panel

## LICENSE

[MIT](./LICENSE) License © 2021 [Amr Bashir](https://github.com/amrbashir)

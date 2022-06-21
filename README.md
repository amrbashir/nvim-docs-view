# nvim-docs-view

A neovim plugin to display lsp hover documentation in a side panel.
> Inspired by the VSCode extension [Docs View](https://marketplace.visualstudio.com/items?itemName=bierner.docs-view).

![doc-view-example](https://user-images.githubusercontent.com/59481467/174691505-91ea7451-0550-425c-ad10-e6668e2fb7aa.gif)

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "amrbashir/nvim-docs-view",
  opt = true,
  cmd = { "DocsViewToggle" },
  config = function()
    require("docs-view").setup {
      position = "right",
      width = 60,
    }
  end
}
```

Using [vim-plug](https://github.com/junegunn/vim-plug)

```viml
Plug 'amrbashir/nvim-docs-view', { 'on': 'DocsViewToggle'}

lua << EOF
  require("docs-view").setup {
    position = "right",
    width = 60,
  }
EOF
```

## Usage

Use `:DocsViewToggle` to open/close the docs view side panel

## LICENSE

[MIT](./LICENSE) License.

if exists('g:loaded_docs_view')
  finish
endif
let g:loaded_docs_view = 1

command! -nargs=0 DocsViewShow lua require("docs-view").show()


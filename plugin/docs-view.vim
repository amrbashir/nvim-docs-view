if exists('g:loaded_docs_view')
  finish
endif
let g:loaded_docs_view = 1

command! DocsViewShow lua require("docs-view").show()


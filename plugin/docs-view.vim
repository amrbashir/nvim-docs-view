if exists('g:loaded_docs_view')
  finish
endif
let g:loaded_docs_view = 1

command! DocsViewOpen lua require("docs-view").open()


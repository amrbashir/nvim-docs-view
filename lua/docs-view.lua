local buf, win, start_win
local api = vim.api
local lsp = vim.lsp

local function show()
  if win and api.nvim_win_is_valid(win) then return end

  start_win = api.nvim_get_current_win()

  api.nvim_command("botright vnew")

  win = api.nvim_get_current_win()
  buf = api.nvim_get_current_buf()

  api.nvim_buf_set_name(buf, "Docs View")
  api.nvim_buf_set_option(buf, "buftype", "nofile")
  api.nvim_buf_set_option(buf, "swapfile", false)
  api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  api.nvim_buf_set_option(buf, "filetype", "nvim-docs-view")

  api.nvim_set_current_win(start_win)

  api.nvim_create_autocmd(
    { "CursorHold" },
    { pattern = "*", callback = function()
        local l,c = unpack(api.nvim_win_get_cursor(0))
        lsp.buf_request(0, "textDocument/hover", { 
            textDocument = { uri = "file://"..api.nvim_buf_get_name(0) },
            position = { line = l - 1, character = c }
        }, function(err, result, ctx, config)
            if not (result and result.contents) then return end

            local md_lines = lsp.util.convert_input_to_markdown_lines(result.contents)
            md_lines = lsp.util.trim_empty_lines(md_lines)
            if vim.tbl_isempty(md_lines) then return end
         
            api.nvim_buf_set_option(buf, "modifiable", true)
            lsp.util.stylize_markdown(buf, md_lines)
            api.nvim_buf_set_option(buf, "modifiable", false)
          end
        )
      end
    }
  )
end

return {
  show = show,
}

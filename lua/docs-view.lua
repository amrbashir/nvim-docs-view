local M = {}

local config = {
  position = "right",
  width = 300,
}

M.setup = function(conf)
  config.position = conf.position
  config.width = conf.width
end

local buf, win, start_win
M.show = function()
  if win and vim.api.nvim_win_is_valid(win) then return end

  start_win = vim.api.nvim_get_current_win()

  vim.api.nvim_command("bot"..config.position.." vnew")

  win = vim.api.nvim_get_current_win()
  buf = vim.api.nvim_get_current_buf()

  vim.api.nvim_win_set_width(win, config.position)

  vim.api.nvim_buf_set_name(buf, "Docs View")
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "filetype", "nvim-docs-view")

  vim.api.nvim_set_current_win(start_win)

  vim.api.nvim_create_autocmd(
    { "CursorHold" },
    { pattern = "*", callback = function()
        local l,c = unpack(vim.api.nvim_win_get_cursor(0))
        vim.lsp.buf_request(0, "textDocument/hover", { 
            textDocument = { uri = "file://"..vim.api.nvim_buf_get_name(0) },
            position = { line = l - 1, character = c }
        }, function(err, result, ctx, config)
            if not (result and result.contents) then return end

            local md_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
            md_lines = vim.lsp.util.trim_empty_lines(md_lines)
            if vim.tbl_isempty(md_lines) then return end
         
            vim.api.nvim_buf_set_option(buf, "modifiable", true)
            vim.lsp.util.stylize_markdown(buf, md_lines)
            vim.api.nvim_buf_set_option(buf, "modifiable", false)
          end
        )
      end
    }
  )
end

return M

local M = {}
local config = {
  position = "right",
  width = vim.api.nvim_get_option("columns") / 3
}

M.setup = function(conf)
  if conf.position then
    config.position = conf.position
  end

  if conf.width then
    config.width = conf.width
  end
end

local buf, win, prev_win
M.toggle = function()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
    win = nil
    buf = nil
    prev_win = nil
  else
    prev_win = vim.api.nvim_get_current_win()

    if config.position == "left" then
      vim.api.nvim_command("topleft vnew")
    else
      vim.api.nvim_command("botright vnew")
    end

    win = vim.api.nvim_get_current_win()
    buf = vim.api.nvim_get_current_buf()

    vim.api.nvim_win_set_width(win, math.ceil(config.width))

    vim.api.nvim_buf_set_name(buf, "Docs View")
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(buf, "swapfile", false)
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(buf, "filetype", "nvim-docs-view")

    vim.api.nvim_set_current_win(prev_win)

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
end

return M

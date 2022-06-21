local M = {}
local cfg = {}
local buf, win, prev_win, autocmd

local function toggle()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, false)
    vim.api.nvim_del_autocmd(autocmd)
    buf, win, prev_win, autocmd = nil, nil, nil, nil
  else
    local height = cfg["height"]
    local width = cfg["width"]

    prev_win = vim.api.nvim_get_current_win()

    if cfg.position == "bottom" then
      vim.api.nvim_command("bel new")
      width = vim.api.nvim_win_get_width(prev_win)
    elseif cfg.position == "left" then
      vim.api.nvim_command("topleft vnew")
      height = vim.api.nvim_win_get_height(prev_win)
    else
      vim.api.nvim_command("botright vnew")
      height = vim.api.nvim_win_get_height(prev_win)
    end

    win = vim.api.nvim_get_current_win()
    buf = vim.api.nvim_get_current_buf()

    vim.api.nvim_win_set_height(win, math.ceil(height))
    vim.api.nvim_win_set_width(win, math.ceil(width))

    vim.api.nvim_buf_set_name(buf, "Docs View")
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(buf, "swapfile", false)
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(buf, "filetype", "nvim-docs-view")
    vim.api.nvim_buf_set_option(buf, "buflisted", false)

    vim.api.nvim_set_current_win(prev_win)

    autocmd = vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      pattern = "*",
      callback = function()
        if win and vim.api.nvim_win_is_valid(win) then
          local l, c = unpack(vim.api.nvim_win_get_cursor(0))
          vim.lsp.buf_request(0, "textDocument/hover", {
            textDocument = { uri = "file://" .. vim.api.nvim_buf_get_name(0) },
            position = { line = l - 1, character = c },
          }, function(err, result, ctx, config)
            if win and vim.api.nvim_win_is_valid(win) and result and result.contents then
              local md_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
              md_lines = vim.lsp.util.trim_empty_lines(md_lines)
              if vim.tbl_isempty(md_lines) then
                return
              end

              vim.api.nvim_buf_set_option(buf, "modifiable", true)
              vim.lsp.util.stylize_markdown(buf, md_lines)
              vim.api.nvim_buf_set_option(buf, "modifiable", false)
            end
          end)
        else
          vim.api.nvim_del_autocmd(autocmd)
          buf, win, prev_win, autocmd = nil, nil, nil, nil
        end
      end,
    })
  end
end

M.setup = function(user_cfg)
  local default_cfg = {
    position = "right",
    height = 10,
    width = 60,
  }

  cfg = vim.tbl_extend("force", default_cfg, user_cfg)

  vim.api.nvim_create_user_command("DocsViewToggle", toggle, { nargs = 0 })
end

return M

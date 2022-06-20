local M = {}
local default_cfg = {
  position = "right",
  height = 10,
  width = 60,
}
local buf, win, prev_win, autocmd

local function toggle()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, false)
    vim.api.nvim_del_autocmd(autocmd)
    buf, win, prev_win, autocmd = nil, nil, nil, nil
  else
    prev_win = vim.api.nvim_get_current_win()

    if default_cfg.position == "bottom" then
      vim.api.nvim_command("bel new")
      default_cfg["width"] = vim.api.nvim_win_get_width(prev_win)
    elseif default_cfg.position == "left" then
      vim.api.nvim_command("topleft vnew")
      default_cfg["height"] = vim.api.nvim_win_get_height(prev_win)
    else
      vim.api.nvim_command("botright vnew")
      default_cfg["height"] = vim.api.nvim_win_get_height(prev_win)
    end

    win = vim.api.nvim_get_current_win()
    buf = vim.api.nvim_get_current_buf()

    vim.api.nvim_win_set_height(win, math.ceil(default_cfg.height))
    vim.api.nvim_win_set_width(win, math.ceil(default_cfg.width))

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
  for key, _ in pairs(default_cfg) do
    if user_cfg[key] then
      default_cfg[key] = user_cfg[key]
    end
  end

  vim.api.nvim_create_user_command("DocsViewToggle", toggle, { nargs = 0 })
end

return M

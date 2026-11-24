local config = require("rails-schema.config")
local M = { buf = nil, win = nil }

local function close()
  if M.win and vim.api.nvim_win_is_valid(M.win) then
    vim.api.nvim_win_close(M.win, true)
  end
  M.win, M.buf = nil, nil
end

function M.toggle(lines)
  if M.win and vim.api.nvim_win_is_valid(M.win) then
    close()
    return
  end

  local opts = config.options
  local width = math.max(40, math.floor(vim.o.columns * opts.width))
  local height = math.max(8, math.floor(vim.o.lines * opts.height))
  local row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1)
  local col = math.max(0, math.floor((vim.o.columns - width) / 2))

  M.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, lines)
  vim.bo[M.buf].buftype = "nofile"
  vim.bo[M.buf].bufhidden = "wipe"
  vim.bo[M.buf].swapfile = false
  vim.bo[M.buf].filetype = "rails-schema"

  M.win = vim.api.nvim_open_win(M.buf, true, {
    relative = "editor",
    width = width,
    height = math.min(height, #lines + 1),
    row = row,
    col = col,
    style = "minimal",
    border = opts.border,
    title = opts.title,
    title_pos = opts.title_pos,
  })

  vim.wo[M.win].wrap = false
  vim.wo[M.win].cursorline = true
  vim.keymap.set("n", "q", close, { buffer = M.buf, silent = true, desc = "Close schema window" })
  vim.keymap.set("n", "<Esc>", close, { buffer = M.buf, silent = true, desc = "Close schema window" })
end

return M

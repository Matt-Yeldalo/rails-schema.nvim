local M = {}

M.defaults = {
  border = "rounded",
  width = 0.55,
  height = 0.65,
  title = " Rails Schema ",
  title_pos = "center",
  show_indexes = true,
  show_foreign_keys = true,
  rails_command = "bin/rails",
  environment = "development",
}

M.options = vim.deepcopy(M.defaults)

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
end

return M

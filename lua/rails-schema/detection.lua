local M = {}

local function normalize(path)
  return vim.fs.normalize(path)
end

function M.find_root(path)
  path = path or vim.api.nvim_buf_get_name(0)
  if path == "" then
    path = vim.fn.getcwd()
  end

  local start = vim.fn.isdirectory(path) == 1 and path or vim.fs.dirname(path)
  local found = vim.fs.find({ "config/application.rb" }, {
    path = start,
    upward = true,
    type = "file",
  })

  return found[1] and vim.fs.dirname(vim.fs.dirname(found[1])) or nil
end

function M.model_name(path, root)
  path = normalize(path or vim.api.nvim_buf_get_name(0))
  root = normalize(root)

  local relative = vim.fs.relpath(path, root)
  if not relative or not relative:match("^app/models/.+%.rb$") then
    return nil, "Current file is not under app/models"
  end

  -- Return the relative model path (e.g. admin/api_client). Rails performs
  -- the actual camelization so application-specific acronyms are respected.
  return relative:gsub("^app/models/", ""):gsub("%.rb$", "")
end

function M.resolve_table(root, model_path, opts)
  opts = opts or {}
  local rails = opts.rails_command or "bin/rails"
  local env = opts.environment or "development"
  local script = string.format(
    'model = %q.camelize.safe_constantize; abort("Model not found") unless model; puts model.table_name',
    model_path
  )

  local args = { rails, "runner", "-e", env, script }
  local escaped = {}
  for _, arg in ipairs(args) do
    table.insert(escaped, vim.fn.shellescape(arg))
  end
  local command = "cd " .. vim.fn.shellescape(root) .. " && " .. table.concat(escaped, " ")
  local output = vim.fn.system(command)

  if vim.v.shell_error ~= 0 then
    return nil, vim.trim(output)
  end

  local table_name = vim.trim(output)
  if table_name == "" then
    return nil, "Rails returned an empty table name"
  end

  return table_name
end

return M

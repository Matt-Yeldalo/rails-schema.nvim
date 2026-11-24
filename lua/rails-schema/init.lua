local config = require("rails-schema.config")
local detection = require("rails-schema.detection")
local parser = require("rails-schema.parser")
local renderer = require("rails-schema.renderer")
local window = require("rails-schema.window")

local M = {}

function M.setup(opts)
  config.setup(opts)
  vim.api.nvim_create_user_command("RailsSchema", function()
    M.toggle()
  end, { desc = "Toggle schema for the current Rails model" })
end

function M.toggle()
  local root = detection.find_root()
  if not root then
    vim.notify("rails-schema.nvim: Could not find Rails project root", vim.log.levels.WARN)
    return
  end

  local model, model_err = detection.model_name(vim.api.nvim_buf_get_name(0), root)
  if not model then
    vim.notify("rails-schema.nvim: " .. model_err, vim.log.levels.WARN)
    return
  end

  local table_name, table_err = detection.resolve_table(root, model, config.options)
  if not table_name then
    vim.notify("rails-schema.nvim: Could not resolve table for " .. model .. ": " .. table_err, vim.log.levels.ERROR)
    return
  end

  local schema_path = root .. "/db/schema.rb"
  local schema, parse_err = parser.parse(schema_path, table_name)
  if not schema then
    vim.notify("rails-schema.nvim: " .. parse_err, vim.log.levels.ERROR)
    return
  end

  window.toggle(renderer.render(schema, config.options))
end

return M

local M = {}

local function split_options(source)
  local result = {}
  for key, value in source:gmatch('([%w_]+):%s*([^,]+)') do
    result[key] = vim.trim(value):gsub("^['\"]", ""):gsub("['\"]$", "")
  end
  return result
end

local function unquote(value)
  return value and value:gsub('^"', ""):gsub('"$', ""):gsub("^'", ""):gsub("'", "") or nil
end

function M.parse(schema_path, target_table)
  local lines = vim.fn.readfile(schema_path)
  if vim.v.shell_error ~= 0 then
    return nil, "Could not read " .. schema_path
  end

  local schema = {
    name = target_table,
    columns = {},
    indexes = {},
    foreign_keys = {},
  }

  local in_table = false
  local found_table = false

  for _, line in ipairs(lines) do
    if not in_table then
      local table_name = line:match('create_table%s+["\']([^"\']+)["\']')
      if table_name == target_table then
        in_table = true
        found_table = true
      end
    else
      if line:match("^%s*end%s*$") then
        in_table = false
      else
        local column_type, column_name, options = line:match('^%s*t%.([%w_]+)%s+["\']([^"\']+)["\']%s*,?%s*(.*)$')
        if column_type and column_name then
          local parsed_options = split_options(options or "")
          table.insert(schema.columns, {
            name = column_name,
            type = column_type,
            null = parsed_options.null,
            default = parsed_options.default,
            limit = parsed_options.limit,
            precision = parsed_options.precision,
            scale = parsed_options.scale,
          })
        end
      end
    end

    local index_table, index_columns, index_options = line:match('add_index%s+["\']([^"\']+)["\']%s*,%s*%[([^%]]+)%]%s*,?%s*(.*)')
    if not index_table then
      local single_table, single_column, single_options = line:match('add_index%s+["\']([^"\']+)["\']%s*,%s*["\']([^"\']+)["\']%s*,?%s*(.*)')
      index_table, index_columns, index_options = single_table, single_column, single_options
    end

    if index_table == target_table then
      local columns = {}
      for column in (index_columns or ""):gmatch('["\']([^"\']+)["\']') do
        table.insert(columns, column)
      end
      if #columns == 0 and index_columns and not index_columns:find('["\']') then
        table.insert(columns, index_columns)
      end
      local parsed_options = split_options(index_options or "")
      table.insert(schema.indexes, {
        columns = columns,
        name = unquote(parsed_options.name),
        unique = parsed_options.unique == "true",
      })
    end

    local fk_table, fk_to, fk_options = line:match('add_foreign_key%s+["\']([^"\']+)["\']%s*,%s*["\']([^"\']+)["\']%s*,?%s*(.*)')
    if fk_table == target_table then
      local parsed_options = split_options(fk_options or "")
      table.insert(schema.foreign_keys, {
        to_table = fk_to,
        column = unquote(parsed_options.column),
        primary_key = unquote(parsed_options.primary_key),
        name = unquote(parsed_options.name),
      })
    end
  end

  if not found_table then
    return nil, string.format("Table '%s' was not found in schema.rb", target_table)
  end

  return schema
end

return M

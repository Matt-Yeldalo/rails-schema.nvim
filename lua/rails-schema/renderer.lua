local M = {}

local function section(lines, heading)
  if #lines > 0 then
    table.insert(lines, "")
    table.insert(lines, heading)
    table.insert(lines, string.rep("─", #heading))
  end
end

function M.render(schema, opts)
  opts = opts or {}
  local lines = {
    "Table: " .. schema.name,
    string.format("%d columns", #schema.columns),
    "",
    "COLUMNS",
    "────────────────────────────────────────────────────────",
    string.format("%-30s %-14s %s", "NAME", "TYPE", "CONSTRAINTS"),
  }

  for _, column in ipairs(schema.columns) do
    local details = {}
    if column.null == "false" then table.insert(details, "NOT NULL") end
    if column.default then table.insert(details, "default=" .. column.default) end
    if column.limit then table.insert(details, "limit=" .. column.limit) end
    table.insert(lines, string.format("%-30s %-14s %s", column.name, column.type, table.concat(details, ", ")))
  end

  if opts.show_indexes then
    section(lines, "INDEXES")
    if #schema.indexes == 0 then
      table.insert(lines, "  (none)")
    else
      for _, index in ipairs(schema.indexes) do
        local label = table.concat(index.columns, ", ")
        if index.unique then label = label .. " [unique]" end
        if index.name then label = label .. "  ·  " .. index.name end
        table.insert(lines, "  " .. label)
      end
    end
  end

  if opts.show_foreign_keys then
    section(lines, "FOREIGN KEYS")
    if #schema.foreign_keys == 0 then
      table.insert(lines, "  (none)")
    else
      for _, fk in ipairs(schema.foreign_keys) do
        local label = (fk.column or "(default column)") .. " → " .. fk.to_table
        if fk.primary_key then label = label .. "." .. fk.primary_key end
        table.insert(lines, "  " .. label)
      end
    end
  end

  return lines
end

return M

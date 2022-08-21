local utils = require('root-climber.utils')

local M = {}

P = function(v)
  print(vim.inspect(v))
  return v
end

local function _climb(re_pattern, path)
  local cwd = vim.fn.getcwd()

  local ls_output = io.popen("ls -a " .. path):read"*all"
  local files = {}
  for file in ls_output:gmatch("[^\n]+") do
    if file:match("[^.]") then
      table.insert(files, file)
    end
  end

  local result = {}
  for _, file in ipairs(files) do
    if file:match(re_pattern) then
      table.insert(result, path .. "/" .. file)
    end
  end

  if cwd == path then
    return result;
  end

  local path_table = utils.split_path(path)
  table.remove(path_table, #path_table)
  local up_path = '/' .. table.concat(path_table, '/')

  local recursion_result = _climb(re_pattern, up_path)

  return utils.concat_tables(recursion_result, result)
end

M.climb = function(pattern)
  local re_pattern = pattern:gsub("%*", "(%%w+)"):gsub("%.", "%%.")
  local current_file_path = vim.fn.expand('%:p:h')

  return _climb(re_pattern, current_file_path)
end

local format_path = function(absolute_path)
  local cwd = vim.fn.getcwd()
  local slash_len = 1
  return string.sub(absolute_path, string.len(cwd) + 1 + slash_len, string.len(absolute_path))
end

M.run = function(pattern)
  local results = M.climb(pattern)

  local inputlist_options = {'Select:'}

  for i, v in ipairs(results) do
    table.insert(inputlist_options, i .. ". " .. format_path(v))
  end

  local option = vim.fn.inputlist(inputlist_options)

  if (option < 1 or option > #results) then
    return nil
  end

  return results[option]
end

return M

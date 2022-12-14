local utils = require('root-climber.utils')

local M = {}

P = function(v)
  print(vim.inspect(v))
  return v
end

local echo_failure = function()
  vim.api.nvim_echo({{"Nothing found", "WarningMsg"}}, false, {})
end

local function _climb(pattern, path)
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
    if file:match(pattern) then
      table.insert(result, path .. "/" .. file)
    end
  end

  if cwd == path then
    return result;
  end

  local path_table = utils.split_path(path)
  table.remove(path_table, #path_table)
  local up_path = '/' .. table.concat(path_table, '/')

  local recursion_result = _climb(pattern, up_path)

  return utils.concat_tables(recursion_result, result)
end

M.climb = function(pattern)
  local current_file_path = vim.fn.expand('%:p:h')

  local results = _climb(utils.match_file_mask(pattern), current_file_path)

  if (#results == 0) then
    echo_failure()
    return nil
  end

  return results
end

local format_path = function(absolute_path)
  local cwd = vim.fn.getcwd()
  local slash_len = 1
  return string.sub(absolute_path, string.len(cwd) + 1 + slash_len, string.len(absolute_path))
end

local skip_confirm = function(results)
  if vim.g["root_climber#always_confirm"] == 0 and #results == 1 then
    return true
  end

  return false
end

M.run = function(pattern, callback)
  local results = M.climb(pattern)

  if (results == nil) then
    return nil
  end

  if skip_confirm(results) then
    return callback(results[1])
  end

  local inputlist_options = {'Select:'}

  for i, v in ipairs(results) do
    table.insert(inputlist_options, i .. ". " .. format_path(v))
  end

  local option = vim.fn.inputlist(inputlist_options)

  if (option < 1 or option > #results) then
    return nil
  end

  callback(results[option])
end

M.fzf_run = function(pattern, callback)
  local fzf_run = vim.fn["fzf#run"]
  local fzf_wrap = vim.fn["fzf#wrap"]
  local sinkfunc = function(path)
    local cwd = vim.fn.getcwd()
    local absolute_path = cwd .. "/" .. path
    return callback(absolute_path)
  end

  local results = M.climb(pattern)

  if (results == nil) then
    return nil
  end

  if skip_confirm(results) then
    return callback(results[1])
  end

  local formatted_results = {}

  for _, v in ipairs(results) do
    table.insert(formatted_results, format_path(v))
  end

  local wrapped = fzf_wrap({
    source = formatted_results,
    options = {},
    sink = sinkfunc
  })

  fzf_run(wrapped)
end

return M

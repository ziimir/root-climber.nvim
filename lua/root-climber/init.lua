local M = {}

P = function(v)
  print(vim.inspect(v))
  return v
end

local split = function(str, pat)
  local t = {}
  local fpat = "(.-)" .. pat
  local last_end = 1
  local s, e, cap = str:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(t, cap)
    end
    last_end = e+1
    s, e, cap = str:find(fpat, last_end)
  end

  if last_end <= #str then
    cap = str:sub(last_end)
    table.insert(t, cap)
  end

  return t
end

local split_path = function(path)
   return split(path,'[\\/]+')
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

  local path_table = split_path(path)
  table.remove(path_table, #path_table)
  local up_path = '/' .. table.concat(path_table, '/')

  local recursion_result = _climb(re_pattern, up_path)

  for _, v in ipairs(result) do
    table.insert(recursion_result, v)
  end

  return recursion_result
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

  print("you choose " .. results[option])

  return results[option]
end

return M

local M = {}

P = function(v)
  print(vim.inspect(v))
  return v
end

M.find = function(pattern)
  local rePattern = pattern:gsub("%*", "(%%w+)"):gsub("%.", "%%.")

  local currentFilePath = vim.fn.expand('%:p:h')
  local lsOutput = io.popen("ls -a "..currentFilePath):read"*all"

  local files = {}
  for file in lsOutput:gmatch("[^\n]+") do
    if file:match("[^.]") then
      table.insert(files, file)
    end
  end

  local result = {}
  for _, file in ipairs(files) do
    if file:match(rePattern) then
      table.insert(result, currentFilePath .. "/" .. file)
    end
  end

  return result
end

local formatPath = function(absolutePath)
  local cmd = vim.fn.getcwd()
  return string.sub(absolutePath, string.len(cmd) + 2, string.len(absolutePath))
end

M.climb = function(pattern)
  local results = M.find(pattern)

  local inputlistOptions = {'Select:'}

  for i, v in ipairs(results) do
    table.insert(inputlistOptions, i .. ". " .. formatPath(v))
  end

  local option = vim.fn.inputlist(inputlistOptions)

  print("you choose " .. results[option])

  return results[option]
end

return M

--local pattern = "*.test.ts"

--local re = pattern:gsub("%*", "(%%w+)"):gsub("%.", "%%.")

--print(re)

--if string.match("some3e.test.ts", re) then
--print('yes') else
--print('no')
--end

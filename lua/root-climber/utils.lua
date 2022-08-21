local M = {}

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

M.split_path = function(path)
   return split(path,'[\\/]+')
end

M.concat_tables = function(t1, t2)
  local result_table = {}

  for _, v in ipairs(t1) do
    table.insert(result_table, v)
  end

  for _, v in ipairs(t2) do
    table.insert(result_table, v)
  end

  return result_table
end

return M

-- read content of the file
local f = assert(io.open("C:\\Stz\\m\\daten\\lua\\DxccCount\\db7bn.adi"))
local t = f:read("*all")
f:close()

local result = {header = {}, data = {n=0}}

-- read fields
function fields(text, comment)
  local result = {}
  local s, e, field, length = string.find(text, "<([%w_]+):(%d+)>")
  if comment then
    local c = string.sub(text, 1, s)
    if not string.find(c, "^%s*$") then
      result.comment = c
    end
  end
  while s do
    result[field] = string.sub(t, e + 1, e + length)
    s, e, field, length = string.find(t, "<([%w_]+):(%d+)>", e + length + 1)
  end
  return result
end

-- read header fields
local s, e = string.find(t, "<eoh>")
if s then
  result.header = fields(string.sub(t, 1, s - 1), true)
end

-- read qso fields
local old = e + 1
s, e = string.find(t, "<eor>", old)
while s do
  table.insert(result.data, fields(string.sub(t, old, s - 1)))
  print(table.getn(result.data))
  old = e + 1
  s, e = string.find(t, "<eor>", old)
end
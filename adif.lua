adif = {}

-- read adif fields
-- t - the input string
-- ts - the first index of the substring to read
-- te - the last index of the substring to read
-- comment - set to true if you want to get first lines as comment field
local function fields(t, ts, te, comment)
  local result = {}
  local s, e, field, length = string.find(t, "<([%w_]+):(%d+)>", ts)
  if comment then
    local c = string.sub(t, ts, math.min(s - 1, te))
    if not string.find(c, "^%s*$") then
      result.comment = c
    end
  end
  while s and e < te do
    result[field] = string.sub(t, e + 1, math.min(e + length, te))
    s, e, field, length = string.find(t, "<([%w_]+):(%d+)>", e + length + 1)
  end
  return result
end

-- write adif fields
-- f - the output file handle
-- t - the table with the fields to write into f
-- comment - set to true if you want to write comment field as first lines
local function text(f, t, comment)
  if comment then
    f:write(t.comment, "\n")
    t.comment = nil
  end
  for k,v in pairs(t) do
    f:write("<", k, ":", string.len(v), ">", v, "\n")
  end
end

function adif:read(filename)
  -- read content of the file
  local f = assert(io.open(filename))
  local t = f:read("*all")
  f:close()
  
  -- create result object
  local result = {header = {}, data = {n=0}}
  self.__index = self
  setmetatable(result, self)
  
  -- read header fields
  local s, e = string.find(t, "<eoh>")
  if s then
    result.header = fields(t, 1, s - 1, true)
  end

  -- read qso fields
  local old = e + 1
  s, e = string.find(t, "<eor>", old)
  while s do
    table.insert(result.data, fields(t, old, s - 1))
    old = e + 1
    s, e = string.find(t, "<eor>", old)
  end
  
  return result
end

function adif:write(filename)
  -- open file
  local f = assert(io.open(filename, "w"))
  
  -- write header
  text(f, self.header, true)
  f:write("<eoh>\n\n")
  
  -- write qsos
  for _, qso in ipairs(self.data) do
    text(f, qso)
    f:write("<eor>\n\n")
  end
  
  -- close file
  f:close()
end
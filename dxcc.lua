dxcc = {}

function dxcc:new(filename)
  filename = filename or "COUNTRY2.DAT"
  -- create result object
  local result = {}
  self.__index = self
  setmetatable(result, self)
  -- read data from file
  local prefs = {n=0}
  for s in io.lines(filename) do
    -- ignore comment lines
    if not s:find("^%s*%/%/") then
      if s:find("^%s*#.*#%s*$") then
        -- parse country prefixes line
        s:gsub("([^#%s]+)", function(c) table.insert(prefs, c:upper()) end)
      else
        -- parse contry information line
        local vals = {}
        s:gsub("([^%s]+)", function(c) table.insert(vals, c) end)
        local cnty = {
          prefix = vals[1],
          prefixs = prefs,
          name = vals[2]:gsub("-", " "),
          itu = vals[3],
          waz = vals[4],
          timeZone = vals[5],
          latN = vals[6],
          longE = vals[7],
          adifNr = vals[8],
        }
        -- keep country information for every prefix
        for _,pref in ipairs(prefs) do
          result[pref] = cnty
        end
        -- reset list of prefixs
        prefs = {n=0}
      end
    end
  end
  return result
end

function dxcc:get(call)
  call = call:upper()
  while call:len() > 0 do
    local result = self[call]
    if result then
      return result
    else
      call = call:sub(1,-2)
    end
  end
  return nil
end

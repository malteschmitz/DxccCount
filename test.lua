require("adif")
require("dxcc")

local a = adif:read("input.adi")
local d = dxcc:new()
local c = a.data[1471].call
local i = d:get(c)
print(c, i.name .. " (" .. i.prefix .. ")")
a:write("output.adi")

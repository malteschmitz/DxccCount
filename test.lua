require "adif"

local a = adif:read("input.adi")
print(a.data[1471].call)
a:write("output.adi")
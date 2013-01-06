require "adif"
require "dxcc"
require "luacom"

local function isconfirmed(qso)
  return (qso.qslrdate and qso.qslrdate:len() > 0)
         or (qso.qsl_rcvd and qso.qsl_rcvd:upper() == 'Y')
end

local function datetime(date, time)
  local result = string.format("%s-%s-%s", date:sub(1,4), date:sub(5,6), date:sub(7,8))
  if time then
    result = result .. string.format("T%s:%s", time:sub(1,2), time:sub(3,4))
  end
  return result
end

local function add(t, ...)
  local n = arg.n
  for i = 1,n-2 do
    if not t[arg[i]] then
      t[arg[i]] = {}
    end
    t = t[arg[i]]
  end
  if not t[arg[n-1]] then
    t[arg[n-1]] = arg[n]
  end
end

local function contains(t, k)
  for _, v in ipairs(t) do
    if v == k then
      return true
    end
  end
  return false
end

local count = {}
local d = dxcc:new()

-- create useful order of common bands and modes
local bands = {"160m", "80m", "40m", "30m", "20m", "17m", "15m",
               "12m", "10m", "6m", "2m", "70cm", "23cm", "13cm",
               "9cm", "6cm", "3cm"}
local modes = {"CW", "SSB", "LSB", "USB", "FM", "AM", "SSTV",
               "PSK31", "RTTY"}
-- iterate over all qsos
for _, qso in ipairs(adif:read(arg[1]).data) do
  local i = d:get(qso.call)
  if not i then
    io.stderr:write("no dxcc information for ", qso.call, " found\n")
  else
    local band = qso.band:lower()
    local mode = qso.mode:upper()
    if not contains(bands, band) then
      table.insert(bands, band)
    end
    if not contains(modes, mode) then
      table.insert(modes, mode)
    end
    add(count, band, mode, i.prefix, isconfirmed(qso), {qso = qso, dxcc = i})
  end
end
-- export result to excel sheet
-- excel color index
-- light red = 38 = #FF99CC
-- light yellow = 36 = #FFFF99
-- light green = 35 = #CCFFCC
excel = luacom.CreateObject("Excel.Application")
excel.Visible = true
wb = excel.Workbooks:Add()
ws = wb.Worksheets(1)
ws.Cells(1,1).Value2 = 'Band'
ws.Rows(1).Font.Bold = true;
ws.Cells(2,1).Value2 = 'Mode'
ws.Rows(2).Font.Bold = true;
for y = 1, table.getn(d.prefixes) do
  local c = d:get(d.prefixes[y])
  ws.Cells(y+2,1).Value2 = c.name .. " (" .. c.prefix .. ")"
end
local x = 2
for _, b in ipairs(bands) do
  local t = count[b]
  if t then
    for _, m in ipairs(modes) do
      local t = t[m]
      if t then
        ws.Cells(1,x).Value2 = b
        ws.Cells(2,x).Value2 = m
        for y = 1, table.getn(d.prefixes) do
          local c = d:get(d.prefixes[y])
          local t = t[c.prefix]
          local cell = ws.Cells(y+2, x)
          if t then
            if t[true] then
              local qso = t[true].qso
              cell.Value2 = "C"
              cell.Interior.ColorIndex = 35
              cell.Interior.Pattern = 1
              cell:AddComment()
              cell.Comment:Text(c.name .. " (" .. c.prefix .. ") confirmed\nQSO qith " .. qso.call .. "\non " .. datetime(qso.qso_date, qso.time_on) .."\nQSL received on " .. datetime(qso.qslrdate))
              cell.Comment.Shape:ScaleWidth(2, 0, 0);
            else -- if t[false] then
              local qso = t[false].qso
              cell.Value2 = "W"
              cell.Interior.ColorIndex = 36
              cell.Interior.Pattern = 1
              cell:AddComment()
              cell.Comment:Text(c.name .. " (" .. c.prefix .. ") worked\nQSO qith " .. qso.call .. "\non " .. datetime(qso.qso_date, qso.time_on))
              cell.Comment.Shape:ScaleWidth(2, 0, 0);
            end
          -- else
          --   cell.Interior.ColorIndex = 38
          --   cell.Interior.Pattern = 1
          end
        end
        x = x + 1
      end
    end
  end
end
ws.Columns:AutoFit()

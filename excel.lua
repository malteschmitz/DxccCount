require('luacom')
excel = luacom.CreateObject("Excel.Application")
excel.Visible = true
wb = excel.Workbooks:Add()
ws = wb.Worksheets(1)

for i=1, 20 do
    ws.Cells(i,1).Value2 = i
end
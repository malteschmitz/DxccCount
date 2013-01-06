require('luacom')
excel = luacom.CreateObject("Excel.Application")
excel.Visible = true
wb = excel.Workbooks:Add()
ws = wb.Worksheets(1)

for i = 1, 56 do
    ws.Cells(i,1).Value2 = i
    ws.Cells(i,1).Interior.ColorIndex = i
    ws.Cells(i,1).Interior.Pattern = 1
end
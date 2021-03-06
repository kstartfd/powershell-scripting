Param( 
  $csvFile = "\\172.20.0.151\ps\users\users15days.csv", 
  $path = "\\172.20.0.12\User\buch\users\Сотрудники.xlsx" 
) 

If (Test-Path $path){
    Write-Host Deleting $path
    Remove-Item $path
} 

$processes = Import-Csv -Path $csvFile 

$Excel = New-Object -ComObject excel.application 

$Excel.visible = $false 

$workbook = $Excel.workbooks.add() 

#Выбираем первый лист книги
$workBook = $WorkBook.Worksheets.Item(1)

# Переименовываем лист
$workBook.Name = 'Список сотрудников'

$workBook.Rows.Item(1).Font.Bold = $true



$excel.cells.item(1,1) = “ФИО” 
$excel.cells.item(1,2) = “Почта” 
$excel.cells.item(1,3) = “Дата_создания” 

$i = 2
 
foreach($process in $processes) 
{ 

 $excel.cells.item($i,1) = $process.ФИО
 $excel.cells.item($i,2) = $process.Почта 
 $excel.cells.item($i,3) = $process.Дата_создания 
 $i++ 
} #end foreach process 

# Выравниваем для того, чтобы их содержимое корректно отображалось в ячейке
$UsedRange = $WorkBook.UsedRange
$UsedRange.EntireColumn.AutoFit() | Out-Null

$workbook.saveas($path) 

#If (Test-Path $csvFile){
 #   Write-Host Deleting $csvFile
 #   Remove-Item $csvFile
#} 


$Excel.Quit() 

Remove-Variable -Name excel 

[gc]::collect() 
[gc]::WaitForPendingFinalizers()
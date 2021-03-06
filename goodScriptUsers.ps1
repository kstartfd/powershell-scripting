Param( 
  $users_ad = "\\172.20.0.151\ps\users\allusers.csv", 
  $path = "\\172.20.0.12\User\buch\users\Сотрудники.xlsx" 
)  

$objSearcher = New-Object System.DirectoryServices.DirectorySearcher

$OU = [ADSI]"LDAP://CN=Users,DC=oma,DC=local"

$objSearcher.SearchRoot = $OU

$objSearcher.PageSize = 1000

$week = ((Get-Date).AddDays(-14)).Date




Write-host "Dormancy Period - $week Days"

If (Test-Path $users_ad){
    Write-Host Deleting $users_ad
    Remove-Item $users_ad
} 

$strFilter = "(&(objectCategory=person)(!userAccountControl:1.2.840.113556.1.4.803:=2)(displayname=*)(l=Минск))"



$objSearcher.Filter = $strFilter 
# Filters: (objectCategory=person)-поиск только учетных записей пользователей, (objectClass=user)-только УЗ, без контактов
# (!userAccountControl:1.2.840.113556.1.4.803:=2)-учетный записи, которые disable, а восклицательный знак исключает их,
# (title=*)-УЗ с заполненной графой «Должность»(title)

$users = $objSearcher.FindAll()

$userTest = "^[0-9][TtEeSs]|[test*]|[Test*]$"

$allUsers = @()
         
$allUsers = foreach ($obj in $users) {

    $displayname = $obj.Properties.Item("displayname")
    $whenCreated = $obj.Properties.Item("whenCreated")
    $mail = $obj.Properties.Item("mail")    
    
    if(($whenCreated -ge $week) -and ($displayname –notmatch $userTest)) {
        "$displayname"+' '+ "$mail" +' '+ "$whenCreated" | Select-Object  @{Label = "ФИО"; Expression = {$displayname}},
                                                            @{Label = "Почта"; Expression = {$mail}},
                                                            @{Label = "Дата_создания"; Expression = {$whenCreated}}
                                                            }

} 

$allUsers | Export-Csv -NoClobber -Encoding utf8 -Path "\\172.20.0.151\ps\users\allusers.csv" -noTypeInformation

 
If (Test-Path $path){
    Write-Host Deleting $path
    Remove-Item $path
} 

$processes = Import-Csv -Path $users_ad 

$Excel = New-Object -ComObject excel.application 

$Excel.visible = $false 

$workbook = $Excel.workbooks.add() 
Write-Host "add book"
#Выбираем первый лист книги
$workBook = $WorkBook.Worksheets.Item(1)
Write-Host "add sheet"
# Переименовываем лист
$workBook.Name = 'Список сотрудников'
Write-Host "rename"

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





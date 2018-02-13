$foldersIsExistDecl = "\\192.168.1.209\gro_decl_otch", "\\192.168.1.209\gom_decl_otch", "\\192.168.1.209\bre_decl_otch"


$copyToGrodnoDeclarants = "\\192.168.1.209\DeclarantGrodno"
$copyToGomelDeclarants = "\\192.168.1.209\DeclarantGomel"
$copyToBrestDeclarants = "\\192.168.1.209\DeclarantBrest"

$date = Get-Date -format  "dd-MM-yyyy"

Write-Host "Create folder for " $copyToGrodnoDeclarants -ForegroundColor  Green
$dirGrodno = "$copyToGrodnoDeclarants\$date"  
New-Item -type Directory -path $dirGrodno
Write-Host "Created folder " $dirGrodno -ForegroundColor  Green



Write-Host "Create folder for " $copyToGomelDeclarants  -ForegroundColor  Green
$dirGomel = "$copyToGomelDeclarants\$date"  
New-Item -type Directory -path $dirGomel
Write-Host "Created folder " $dirGomel -ForegroundColor  Green


Write-Host "Create folder for " $copyToBrestDeclarants -ForegroundColor  Green
$dirBrest = "$copyToBrestDeclarants\$date"  
New-Item -type Directory -path $dirBrest
Write-Host "Created folder " $dirBrest -ForegroundColor  Green


$sourceDecl = "\\192.168.1.209\foldersForDecl\decl"
$sourceSpec = "\\192.168.1.209\foldersForDecl\spec"


$GrodnolFromFullPath = "\\192.168.1.209\gro_decl_otch\"
Write-Host "Grodno folder from " $GrodnolFromFullPath -ForegroundColor  Green

$GomellFromFullPath = "\\192.168.1.209\gom_decl_otch\"
Write-Host "Gomel folder from " $GomellFromFullPath -ForegroundColor  Green


$BrestlFromFullPath = "\\192.168.1.209\bre_decl_otch\"
Write-Host "Brest folder from " $BrestlFromFullPath -ForegroundColor  Green


function copyDeclFolderToDeclarants($copyFrom, $copyTo) {
    Write-Host "Copy folders from and files " $copyFrom  " to " $copyTo
    Copy-Item -Path $copyFrom -destination $copyTo -Recurse -Force

}

copyDeclFolderToDeclarants ($GrodnolFromFullPath) ($dirGrodno)
copyDeclFolderToDeclarants ($GomellFromFullPath) ($dirGomel)
copyDeclFolderToDeclarants ($BrestlFromFullPath) ($dirBrest)


function checkFoldersDecl() {
 
  Param ($value, $valueDecl, $valueSpec);

  foreach ($folder in $value) {


           Get-ChildItem -Path $folder -Directory | ForEach-Object {
              
              $allFullName = $_.FullName 

              Get-ChildItem -Path $_.FullName -Directory | ForEach-Object {

                      foreach ($a in $_.FullName) {
                           
                
                          if ($a -match "sync") {
                           
                              Write-Host "Doesn't removed from - " $a  -ForegroundColor Green
                                
                           
                          } else {
                                
                              Write-Host "Remove all files and folder from - " $allFullName  -ForegroundColor Red         
                              Remove-Item $allFullName\* -Force -Recurse
                              Write-Host "Copy folders decl and spec to - " $allFullName\
                              Copy-Item -Path $valueDecl -destination $allFullName\ -Force
                              Copy-Item -Path $valueSpec -destination $allFullName\ -Recurse -Force
                         } 
                }
          }
     }
  }
}





checkFoldersDecl ($foldersIsExistDecl) ($sourceDecl) ($sourceSpec)



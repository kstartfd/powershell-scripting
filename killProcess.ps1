$user = "admin"
$password = "1231"
$secstr = New-Object -TypeName System.Security.SecureString
$password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
$credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $user, $secstr


#10.0.100.5
#10.0.100.21

$date = Get-Date -format  "dd-MM-yyyy"
$berestovicaIP = "buh2" 
$berestovicaName = "buh2"
$startTime = (Get-Date)
$defis = "-"
$1cKill = "1cv7s.exe"
$1cLCK = "1Cv7.LCK"

function copyBack($computerIpAddr, $nameOfmagazine) {
    $folderWithArch = "\\192.168.1.209\y\admin\backsForMagazine\$nameOfmagazine$defis$date.zip" 
    $filesForArchive = "\\$computerIpAddr\trans\_df\" # где искать папки для архивирования

    $process = Get-WmiObject -Class Win32_Process -ComputerName $computerIpAddr -Credential $credentials | Where-Object -FilterScript {$_.Name -like "$1cKill"} 
 
    if ($process) {

        Write-Host "Process is running" -ForegroundColor red
        ($process).Terminate()
        ($1cLCK).Terminate()
        Write-Host "Kill process..." -ForegroundColor green
        Write-Host "We killed it and Let's doing backup, Monsieur!" -ForegroundColor Magenta

        Compress-Archive -LiteralPath $filesForArchive -CompressionLevel Optimal  -Force -DestinationPath $folderWithArch

     

    } else {
        Write-Host "Process isn't running" -ForegroundColor green
        Write-Host "Let's doing backup, Monsieur!" -ForegroundColor Magenta

        Compress-Archive -LiteralPath $filesForArchive -CompressionLevel Optimal  -Force -DestinationPath $folderWithArch
    }

}


function time($block) {
   
    $endTime = (Get-Date)
    $ElapsedTime = (($endTime-$startTime).TotalSeconds)
    Write-Host "Duration: " $ElapsedTime " sec" -ForegroundColor Green
}

time (copyBack($berestovicaIP)($berestovicaName))











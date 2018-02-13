$siteFolder = "C:\inetpub\wwwroot"
$temp = "C:\temp"
$users = "Users"
$iis_iusrs = "IIS_IUSRS"
$fullControl = "FullControl"

$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Users", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
$ruleIIS = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")

$permissionUsers = (Get-Acl $temp).Access | ?{$_.IdentityReference -match $users} | Select IdentityReference, FileSystemRights

Write-Host "Check permission on Temp folder." -ForegroundColor green

if($permissionUsers -match $fullControl) {
        
        $permissionUsers | % {Write-Host "$($_.IdentityReference) have '$($_.FileSystemRights)' rights on folder $folder" -ForegroundColor green} 
      
  } else {
        Write-Host "$users Don't have any permission on $temp" -ForegroundColor green
        Write-Host "Add FullControl on $temp" -ForegroundColor green
        Write_host "Add Permission..." -ForegroundColor green
        $acl = Get-Acl $temp
        $acl.AddAccessRule($rule)
        Set-Acl -PATH $temp $acl
}


####################################


$url = "https://api.github.com/repos/TargetProcess/DevOpsTaskJunior/zipball/master"
$path = "C:\temp\TargetProcess-DevOpsTaskJunior.zip"
$sitename = "targetproccestestskorta.by"


if(Test-Path $temp) {
    Write-Host "Removing all temp files..." -ForegroundColor green
    Remove-Item -Path $temp/* -recurse -Force
    Write-Host "Download Project from Github..." 
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("User-Agent: Other");
    $webClient.DownloadFile($url,$path)
} 

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$path, [string]$temp)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($path, $temp)
}

Write-Host "Unzip downloaded archive..." -ForegroundColor green

Unzip $path $temp

Write-host "Delete downloaded zip..." $path -ForegroundColor green

Remove-item $path

$items = Get-ChildItem -Path $temp

foreach ($item in $items) {
      $name = $item.Name
      Write-Host "Rename unziped folder " $item.Name " to " $sitename -ForegroundColor green
      Rename-item $temp\$name $sitename 
}

Write-Host "Copy project folder to IIS folder..." -ForegroundColor green

if(Test-Path $siteFolder\$sitename) {
    Write-Host "Run copy, if folder exist." -ForegroundColor green
    Remove-Item -Path $siteFolder\$sitename -recurse -Force
    #New-Item $siteFolder\$sitename -type directory
    Copy-Item -Path $temp\$sitename -Destination $siteFolder\$sitename -recurse -Force
} else {
    Write-Host "Run copy, if folder not exist." -ForegroundColor green
    #New-Item $siteFolder\$sitename -type directory
    Copy-Item -Path $temp\$sitename -Destination $siteFolder\$sitename -recurse -Force
}



$permissionUsersSite = (Get-Acl $siteFolder\$sitename).Access | ?{$_.IdentityReference -match $users} | Select IdentityReference, FileSystemRights
$permissionIIS_IUSRSSite = (Get-Acl $siteFolder\$sitename).Access | ?{$_.IdentityReference -match $iis_iusrs} | Select IdentityReference, FileSystemRights

if ($permissionUsersSite -match $fullControl -and $permissionIIS_IUSRSSite -match $fullControl) {
        $permissionUsersSite | % {Write-Host "User $($_.IdentityReference) has '$($_.FileSystemRights)' rights on folder $siteFolder\$sitename"}
        $permissionIIS_IUSRSSite | % {Write-Host "User $($_.IdentityReference) has '$($_.FileSystemRights)' rights on folder $siteFolder\$sitename"}
} else {
        Write-Host "$users Doesn't have any permission on $siteFolder\$sitename" -ForegroundColor green
        Write-Host "$iis_iusrs Doesn't have any permission on $siteFolder\$sitename" -ForegroundColor green
        Write-Host "Add Full Control to Site Folder for " $users " and " $iis_iusrs -ForegroundColor green
        $acl = Get-Acl $siteFolder\$sitename
        $acl.AddAccessRule($rule)
        $acl.AddAccessRule($ruleIIS)
        Set-Acl -PATH $siteFolder\$sitename $acl
}



$ip = "127.0.0.1"
$hostName = "targetproccestestskorta.by"
$filehosts = "C:\Windows\System32\drivers\etc\hosts"
$siteFolder = Join-Path -Path 'C:\inetpub\wwwroot' -ChildPath $sitename

function add-host([string]$filename) { 
	Write-Host "Add HostName " $hostName " to hosts file." -ForegroundColor green
	$ip + "`t`t" + $hostname | Out-File -encoding ASCII -append $filename
}

add-host($filehosts)


Import-Module WebAdministration
$iisAppPoolName = "targetproccestestskorta.by"
$iisAppPoolDotNetVersion = "v4.0"
$iisAppName = "targetproccestestskorta.by"



cd IIS:\AppPools\


if (!(Test-Path $iisAppPoolName -pathType container))
{

    $appPool = New-Item $iisAppPoolName
    $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value $iisAppPoolDotNetVersion
} 


function checkSite {
   
 $sites = Get-WebSite

    $sites | ForEach-Object {
        $sitename = $_.name
        $state = $_.State
        if($state -eq "Stopped") {
            Write-Host "$sitename is stopped. Starting it..." -ForegroundColor red
            Start-Website $sitename
        }
        if($state -ne "Stopped") {
             Write-Host "$sitename is already" -ForegroundColor green
        }
       
    }
 
}



$webhook = "https://hooks.slack.com/services/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"
 
function CheckForStatus($url) {
    try {
        [net.httpWebRequest] $req = [net.webRequest]::create($url)
        $req.Method = "HEAD"
        [net.httpWebResponse] $res = $req.getResponse()
 
        if ($res.StatusCode -eq "200") {

            Write-Host "Site $url is up (Return code: $($res.StatusCode) - $([int] $res.StatusCode))" -ForegroundColor green 
            
            $body_200 = @{
                    "text" = "Ok, 200"
            }

            $params = @{
                Headers = @{'accept'='application/json'}
                Body = $body_200 | convertto-json
                Method = 'Post'
                URI = $webhook 
            }

            Invoke-RestMethod @params
        }
        else {
            Write-Host "Site $url is down" -ForegroundColor red
             $body_503 = @{
                    "text" = "Bad, 503"
            }

            $params = @{
                Headers = @{'accept'='application/json'}
                Body = $body_503 | convertto-json
                Method = 'Post'
                URI = $webhook 
            }

            Invoke-RestMethod @params
        }
    } catch {
 
        Write-Host "Site has problem" -ForegroundColor red
    
             $body_smtels = @{
                    "text" = "Site has problem."
            }

            $params = @{
                Headers = @{'accept'='application/json'}
                Body = $body_smtels | convertto-json
                Method = 'Post'
                URI = $webhook 
            }

            Invoke-RestMethod @params

    }
}



function CheckIIS {
    param($ServiceName)
        $arrService = Get-Service -Name $ServiceName
  
    if ($arrService.Status -ne "Running") {
        Start-Service $ServiceName
        Write-Host "Start " $ServiceName -ForegroundColor red
        }
    if ($arrService.Status -eq "Running") { 
        Write-Host $ServiceName "service is already started." -ForegroundColor green
    }
}
 

cd IIS:\Sites\


if (Test-Path $iisAppName -pathType container) {
    cd c:/
    CheckIIS -ServiceName "iisadmin"
    checkSite
    CheckForStatus("http://"+$iisAppName+"/")
} else {
    $iisApp = New-Item $iisAppName -bindings @{protocol="http";bindingInformation=":80:" + $iisAppName} -physicalPath $siteFolder
    $iisApp | Set-ItemProperty -Name "applicationPool" -Value $iisAppPoolName
    cd c:/
    CheckIIS -ServiceName "iisadmin"
    checkSite
    CheckForStatus("http://"+$iisAppName+"/")
}






 


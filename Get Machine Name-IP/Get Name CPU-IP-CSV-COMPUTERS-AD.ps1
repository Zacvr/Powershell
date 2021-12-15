$RemoteComputer = Read-Host "Computer Name?"
$RemoteComputer = $RemoteComputer.ToUpper()
Import-Module activedirectory
        Write-host "Gathering Enabled servers from AD (This may take some time)..."
        $Computers = ( Get-ADComputer -filter ('Name -like "*' + $RemoteComputer + '*"') -Properties OperatingSystem | Where-Object {$_.Distinguishedname -Notmatch 'ou=disabled' -and $_.Distinguishedname -Notmatch 'ou=Virtual Desktops' -and $_.Distinguishedname -Notmatch 'ou=DO NOT USE OU_Domain_Root' -and $_.Distinguishedname -Notmatch 'ou=Servers' -and $_.Distinguishedname -Notmatch 'ou=DistrictLaptops'}).name | sort


$report = @()
foreach ($Computer in $Computers){
$Computer = $Computer.ToUpper()
Try{
if (Test-Connection $Computer -count 1 -quiet){ 
    $CPU = Get-WmiObject -Class Win32_Processor -ComputerName $Computer -erroraction SilentlyContinue | Select Name 
    $CPU1 = $CPU -replace ".$" 
    $CPU = $CPU1.substring(7) 
    $IP = Test-Connection $Computer -count 1 -erroraction SilentlyContinue | Select IPV4Address
    $IP1 = $IP -replace ".$"
    $IP = $IP1.substring(14)
    $report += New-Object psobject -Property @{Name=$Computer;CPU=$CPU;IP=$IP}
    $report | export-csv -append "$PSScriptRoot\$RemoteComputer.csv"

    $Computer
    }
        else{
    Write-Host "$Computer is offline" -Fore Magenta
    }}
    catch{Write-Host "Unable to check $Computer likely RPC server unavailable" -Fore Red
    $report += New-Object psobject -Property @{Name=$Computer;CPU="";IP=$IP}
    $report | export-csv -append "$PSScriptRoot\$RemoteComputer.csv"}

}
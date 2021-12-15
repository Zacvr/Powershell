$RemoteComputer = Read-Host "Computer Name?"
$RemoteComputer = $RemoteComputer.ToUpper()
Import-Module activedirectory
        Write-host "Gathering Enabled servers from AD (This may take some time)..."
        $Computers = ( Get-ADComputer -filter ('Name -like "*' + $RemoteComputer + '*"') -Properties OperatingSystem | Where-Object {$_.Distinguishedname -Notmatch 'ou=disabled' -and $_.Distinguishedname -Notmatch 'ou=Virtual Desktops' -and $_.Distinguishedname -Notmatch 'ou=DO NOT USE OU_Domain_Root' -and $_.Distinguishedname -Notmatch 'ou=Servers' -and $_.Distinguishedname -Notmatch 'ou=DistrictLaptops'}).name | sort


foreach ($Computer in $Computers){
$Computer = $Computer.ToUpper()
Try{
if (Test-Connection $Computer -count 1 -quiet){
$Computer
    $report = @()
    $CPU = Get-WmiObject -Class Win32_Processor -ComputerName $Computer -erroraction SilentlyContinue | Select Name 
    $CPU1 = $CPU -replace ".$" 
    $CPU = $CPU1.substring(7) 
    $IP = Test-Connection $Computer -count 1 | Select IPV4Address
    $IP1 = $IP -replace ".$"
    $IP = $IP1.substring(14)
    New-Object psobject -Property @{Name=$Computer;CPU=$CPU;IP=$IP;LastLogon=""} | export-csv -append "$PSScriptRoot\$RemoteComputer.csv"
    }
    Else {Write-Host "$Computer failed to get CPU & IP. Collecting Last Logon Date" -Fore Magenta
    $report = @()
    $Logon = Get-ADComputer -identity $Computer -Properties LastLogonDate | Select LastLogonDate
    $Logon1 = $Logon -replace ".$" 
    $Logon = $Logon1.substring(16) 
    New-Object psobject -Property @{Name=$Computer;CPU="";IP="";LastLogon=$Logon} | export-csv -append "$PSScriptRoot\$RemoteComputer.csv"}
}
catch {
    Write-Host "$Computer RPC Server is Unavailiable" -ForegroundColor Red
    $Logon = Get-ADComputer -identity $Computer -Properties LastLogonDate | Select LastLogonDate
    $Logon1 = $Logon -replace ".$" 
    $Logon = $Logon1.substring(16) 
    New-Object psobject -Property @{Name=$Computer;CPU="RPC Server Error";IP="";LastLogon=$Logon} | export-csv -append "$PSScriptRoot\$RemoteComputer.csv"}
}

    

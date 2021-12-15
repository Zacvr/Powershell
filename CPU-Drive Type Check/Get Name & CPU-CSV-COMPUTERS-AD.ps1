$RemoteComputer = Read-Host "Computer Name?"
$RemoteComputer = $RemoteComputer.ToUpper()
Import-Module activedirectory
 
        Write-host "Gathering Enabled servers from AD (This may take some time)..."

        $Computers = ( Get-ADComputer -filter ('Name -like "*' + $RemoteComputer + '*"') -Properties OperatingSystem | Where-Object {$_.Distinguishedname -Notmatch 'ou=disabled' -and $_.Distinguishedname -Notmatch 'ou=Virtual Desktops' -and $_.Distinguishedname -Notmatch 'ou=DO NOT USE OU_Domain_Root' -and $_.Distinguishedname -Notmatch 'ou=Servers' -and $_.Distinguishedname -Notmatch 'ou=DistrictLaptops'}).name | sort
        
   
foreach ($Computer in $Computers){
$Computer = $Computer.ToUpper()
if (Test-Connection $Computer -count 1 -quiet){ 
    Get-WmiObject -Class Win32_Processor -ComputerName $Computer -erroraction SilentlyContinue | Select PSComputerName, Name | Export-Csv -append -Path "$PSScriptRoot\$RemoteComputer.csv" -NoTypeInformation -Encoding UTF8 -Force
    Write-Host $Computer, $ComputerProcessor 
    }

  else{
Write-Host "$Computer Not found" -Fore Red
}}
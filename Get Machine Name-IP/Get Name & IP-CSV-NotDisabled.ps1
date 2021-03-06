$RemoteComputer = Read-Host "Computer Name?"
$RemoteComputer = $RemoteComputer.ToUpper()
#Get-ADComputer -Filter ('Name -like "*' + $RemoteComputer + '*"') -Properties IPv4Address | Sort-Object Name | FT Name,IPv4Address -A | Export-CSV $PSScriptRoot\$RemoteComputer.CSV
#Get-ADComputer -Filter ('Name -like "*' + $RemoteComputer + '*"') -Properties IPv4Address | Sort-Object Name | FT Name,IPv4Address -A | Export-CSV $PSScriptRoot\$RemoteComputer.CSV
Get-ADComputer -Filter ('Name -like "*' + $RemoteComputer + '*"')  -Property * | Where-Object Distinguishedname -Notmatch 'ou=disabled' |Sort-Object Name | Select-Object Name,ipv4Address,OperatingSystem,OperatingSystemVersion | Export-CSV $PSScriptRoot\$RemoteComputer.CSV -NoTypeInformation -Encoding UTF8
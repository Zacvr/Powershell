$RemoteComputer = Read-Host "Computer Name?"
Get-ADComputer -Filter ('Name -like "*' + $RemoteComputer + '*"') -Properties IPv4Address | Sort-Object Name | FT Name,IPv4Address -A | Out-File -FilePath "\\mirage\Drivers\TechTools\ZVanRoekel\Fixes\Scripts\Get Machine Name, IP\$RemoteComputer.txt" 
Write-Host "File has been created \\mirage\Drivers\TechTools\ZVanRoekel\Fixes\Scripts\Get Machine Name, IP\$RemoteComputer.txt"
notepad "\\mirage\Drivers\TechTools\ZVanRoekel\Fixes\Scripts\Get Machine Name, IP\$RemoteComputer.txt"
$RemoteComputer = Read-Host "Computer Name?"
Get-ADComputer -Filter ('Name -like "*' + $RemoteComputer + '*"') -Properties IPv4Address | Sort-Object Name | FT Name,IPv4Address -A | Out-File -FilePath "$PSScriptRoot\\$RemoteComputer.txt" 
Write-Host "File has been created $PSScriptRoot\$RemoteComputer.txt"
notepad "$PSScriptRoot\$RemoteComputer.txt"
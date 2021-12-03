$DomainName = "chico.usd"
Do { $Choice = Read-Host "Would you like to 'Add' or 'Remove' a Local Domain Group Admin?" } While ($Choice -notmatch "Add|Remove")
$ComputerName = Read-Host "Computer name"
$UserName = Read-Host "User name"
$AdminGroup = [ADSI]"WinNT://$ComputerName/Administrators,group"
$User = [ADSI]"WinNT://$DomainName/$UserName,group"
$AdminGroup.$Choice($User.Path) 

Set-ExecutionPolicy RemoteSigned
Write-Host "Success! (Hopefully) -ZVR"
Write-Host "Press any key to exit"
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
(Get-Host).SetShouldExit(0)
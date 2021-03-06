Do { $Choice = Read-Host "Would you like to 'Add' or 'Remove' a Local Admin?" } While ($Choice -notmatch "Add|Remove")

if ($Choice -eq "Add")
{
#Define variables
$DomainName = "chico.usd"
$computers = Read-Host "Computer name"
$username = Read-Host ?Admin Login Name?
$password = Read-Host ?Password To Be Used?
$fullname = Read-Host ?Full Account Name?
$local_security_group = ?Administrators?
$description = ?Description?

Foreach ($computer in $computers) {
$users = $null
$comp = [ADSI]?WinNT://$computer?

#Check if username exists
Try {
$users = $comp.psbase.children | select -expand name
if ($users -like $username) {
Write-Host ?$username already exists on $computer?

} else {
#Create the account
$user = $comp.Create(?User?,?$username?)
$user.SetPassword(?$password?)
$user.Put(?Description?,?$description?)
$user.Put(?Fullname?,?$fullname?)
$user.SetInfo()

#Set password to never expire
#And set user cannot change password
$ADS_UF_DONT_EXPIRE_PASSWD = 0x10000
$ADS_UF_PASSWD_CANT_CHANGE = 0x40
$user.userflags = $ADS_UF_DONT_EXPIRE_PASSWD + $ADS_UF_PASSWD_CANT_CHANGE
$user.SetInfo()

#Add the account to the local admins group
$group = [ADSI]?WinNT://$computer/$local_security_group,group?
$group.add(?WinNT://$computer/$username?)

#Validate whether user account has been created or not
$users = $comp.psbase.children | select -expand name
if ($users -like $username) {
Write-Host ?$username has been created on $computer?
Write-Host "Password: $password"
} else {
Set-ExecutionPolicy RemoteSigned
Write-Host ?$username has not been created on $computer?
}
}}

Catch {
Write-Host ?Error creating $username on $($computer.path): $($Error[0].Exception.Message)?
}
}}else 
{
$DomainName = "chico.usd"
$computers = Read-Host "Computer name"
$username = Read-Host ?Admin Login Name?
$computer = [ADSI]("WinNT://$computers,computer")
$Group = $computer.PSBase.Children.Find("Administrators")
$Group.Remove("WinNT://$username")
Set-ExecutionPolicy RemoteSigned
Write-Host "Success! (Hopefully) -ZVR"
}
Set-ExecutionPolicy RemoteSigned
Write-Host "Press any key to exit"
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
(Get-Host).SetShouldExit(0)
Remove-Item "\\mirage\Drivers\TechTools\ZVanRoekel\Fixes\Scripts\Local Admin\Per Site\Results\*" -Recurse -Force
Sleep 1
#Get-localadmins
$AllPCsOrSepcific = "A"
If ($AllPCsOrSepcific -eq "A")
{$All = "Yes"
start Powershell {.\BJ.ps1}
Sleep 1
start Powershell {.\CH.ps1}
Sleep 1
start Powershell {.\CI.ps1}
Sleep 1
start Powershell {.\CJ.ps1}
Sleep 1
start Powershell {.\CS.ps1}
Sleep 1
start Powershell {.\CY.ps1}
Sleep 1
start Powershell {.\DO.ps1}
Sleep 1
start Powershell {.\EW.ps1}
Sleep 1
start Powershell {.\FV.ps1}
Sleep 1
start Powershell {.\HO.ps1}
Sleep 1
start Powershell {.\JM.ps1}
Sleep 1
start Powershell {.\LC.ps1}
Sleep 1
start Powershell {.\LCC.ps1}
Sleep 1
start Powershell {.\LV.ps1}
Sleep 1
start Powershell {.\MA.ps1}
Sleep 1
start Powershell {.\MJ.ps1}
Sleep 1
start Powershell {.\ND.ps1}
Sleep 1
start Powershell {.\OB.ps1}
Sleep 1
start Powershell {.\PA.ps1}
Sleep 1
start Powershell {.\PV.ps1}
Sleep 1
start Powershell {.\RO.ps1}
Sleep 1
start Powershell {.\SH.ps1}
Sleep 1
start Powershell {.\SV.ps1}



 }
else{
$RemoteComputer = Read-Host "Computer Name?"
$RemoteComputer = $RemoteComputer.ToUpper()}
$BadGroups = 
$NewLine = ""
 
Function Get-LocalAdmins {  
 
    Param (
        #used for looking up all servers in AD instead of a list
        [Parameter(Mandatory=$true,ParameterSetName="ADLookup",Position=0)]
        [Switch]$ADLookup
    )
 
    If ($AllPCsOrSepcific -eq "A")
    {    if($ADLookup) {
        
        #Pulls full list of enabled Servers from AD
 
        Import-Module activedirectory
 
        Write-host "Gathering Enabled servers from AD (This may take some time)..."

        $Servers = ( Get-ADComputer -filter * -Properties OperatingSystem | Where-Object {$_.Distinguishedname -Notmatch 'ou=disabled' -and $_.Distinguishedname -Notmatch 'ou=Virtual Desktops' -and $_.Distinguishedname -Notmatch 'ou=DO NOT USE OU_Domain_Root'-and $_.Distinguishedname -Notmatch 'ou=Servers' -and $_.Distinguishedname -Notmatch 'ou=DistrictLaptops'}).name | sort }

    else {}
    }
    
    Foreach ($Server in $Servers) {
   
        $LocalAdminsArray = @()
        if($ExcludedServers -contains $Server ) {}
        else{
        #if (Test-Connection $Server -count 1 -quiet) {


        Try {
            if($Server) {}
            #Pulls WMI listing of all components of the local admin group
            $Admins = Get-WmiObject -Class Win32_GroupUser -Filter "GroupComponent=""Win32_Group.Domain='$Server',Name='Administrators'""" -ComputerName $server -ErrorAction Stop
        
            $admins |% { 
            
                $CurrAccount = New-Object psobject | select Servername,LocalGroupName,GroupMember,MemberType 
                

            
                $_.partcomponent –match “.+Domain\=(.+)\,Name\=(.+)$” > $nul  
                
                $CurrAccount.GroupMember = $matches[1].trim('"') + “\” + $matches[2].trim('"')  
                
                if ($_.partcomponent -like "*Win32_UserAccount.Domain*") {
                
                    $CurrAccount.MemberType = "User"
                
                } else {
                
                    $CurrAccount.MemberType = "group"
                }
            
                $CurrAccount.Servername = $Server
            
                $CurrAccount.LocalGroupName = "$Server\Administrators"
                
                $LocalAdminsArray+=$CurrAccount
 
            
            }
            
            #Outputs listing from current server to the screen
            $LocalAdminsArray | ft
             
            $localadminsarray | Export-CSV -Append $PSScriptRoot\$RemoteComputer.CSV -notypeinformation

        } catch {
 
           $CurrAccount                = New-Object psobject | select Servername,LocalGroupName,GroupMember,MemberType
        
           $CurrAccount.Servername     = $Server
           
           $CurrAccount.LocalGroupName = "$Server\Administrators"
           
           $CurrAccount.GroupMember    = "Server could not be contacted"
           
           $CurrAccount.MemberType     = "Server could not be contacted"
             
           $CurrAccount | ft
           
           $CurrAccount | export-csv -path $PSScriptRoot\$RemoteComputer.CSV -append -notypeinformation
 
        }
        
    #}
        
            else {
 Write-Host "$Server offline. Skipping..."
 }}}
    Write-host "Please see $PSScriptRoot\$RemoteComputer.CSV for results"
 
}
If ($AllPCsOrSepcific -eq "A"){}
Else{
get-localadmins -ADLookup
}
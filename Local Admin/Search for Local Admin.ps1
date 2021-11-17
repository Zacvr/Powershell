#Get-localadmins
$RemoteComputer = Read-Host "Computer Name?"
$RemoteComputer = $RemoteComputer.ToUpper()
$NewLine = ""
 
Function Get-LocalAdmins {  
 
    Param (
        #used for looking up all servers in AD instead of a list
        [Parameter(Mandatory=$true,ParameterSetName="ADLookup",Position=0)]
        [Switch]$ADLookup,
 
        #used for lookup up servers in a specified list
        [Parameter(Mandatory=$true,ParameterSetName="ListLookup",Position=0)]
        [String[]]$Servers,
 
        #Used to pull a list of servers from a file
        [Parameter(Mandatory=$true,ParameterSetName="FileLookup",Position=0)]
        [String]$filename,
 
        #Output filename
        [Parameter(Mandatory=$false,ParameterSetName="ADLookup")]
        [Parameter(Mandatory=$false,ParameterSetName="ListLookup")]
        [Parameter(Mandatory=$false,ParameterSetName="FileLookup")]
        [String]$OutputFile = "$PSScriptRoot\$RemoteComputer.CSV",
 
        [Parameter(Mandatory=$false,ParameterSetName="ADLookup")]
        [Parameter(Mandatory=$false,ParameterSetName="ListLookup")]
        [Parameter(Mandatory=$false,ParameterSetName="FileLookup")]
        [switch]$AppendCSV
    )
 
    if(!$AppendCSV){
 
        Write-output '"Servername","LocalGroupName","GroupMember","MemberType"' | out-file -filepath -append $OutputFile
 
    }
 
 
    if($ADLookup) {
        
        #Pulls full list of enabled Servers from AD
 
        Import-Module activedirectory
 
        Write-host "Gathering Enabled servers from AD (This may take some time)..."
 
        $Servers = ( Get-ADComputer -filter ('Name -like "*' + $RemoteComputer + '*"') -Properties OperatingSystem ).name | sort 
        
    }
    
    if($filename) {
        
        #Pulls list of servers from a text file
 
        if(Test-Path $filename) {
 
            $Servers = Get-Content $filename
 
        } else {
 
            Write-Error "File $filename invalid or not found."
 
        }
 
    }
    
    Foreach ($Server in $Servers) {
 
        $LocalAdminsArray = @()
        if (Test-Connection $Server -count 3 -quiet) {


        Try {
            
            #Pulls WMI listing of all components of the local admin group
            $Admins = Get-WmiObject -Class Win32_GroupUser -Filter "GroupComponent=""Win32_Group.Domain='$Server',Name='Administrators'""" -ComputerName $server -ErrorAction Stop        
        
            $admins |% { 
            
                $CurrAccount = New-Object psobject | select Servername,LocalGroupName,GroupMember,MemberType | Where-Object {$_.Groupmember -ne 'CHICO\Domain Admins
'}
            
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
            
            $localadminsarray | Export-CSV -Append $PSScriptRoot\$RemoteComputer.CSV

        } catch {
 
           $CurrAccount                = New-Object psobject | select Servername,LocalGroupName,GroupMember,MemberType
        
           $CurrAccount.Servername     = $Server
           
           $CurrAccount.LocalGroupName = "$Server\Administrators"
           
           $CurrAccount.GroupMember    = "Server could not be contacted"
           
           $CurrAccount.MemberType     = "Server could not be contacted"
             
           $CurrAccount | ft
           
           $CurrAccount | export-csv -path $OutputFile -append -notypeinformation
 
        }
        
    }
        
            else {
 Write-Host "$Server offline. Skipping..."
 }}
    Write-host "Please see $outputfile for results"
 
}
get-localadmins -ADLookup
#get-localadmins -filename testfile.txt
#get-localadmins -servers $RemoteComputer
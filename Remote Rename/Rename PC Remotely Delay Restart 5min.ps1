#Define variables


Do {
$PCUP = "Offline"
$RemoteComputer = Read-Host "Computer name"
If (Test-Connection -BufferSize 32 -Count 1 -ComputerName $RemoteComputer -Quiet) {
        $RemoteUser1 = Get-WmiObject -Class win32_computersystem -ComputerName "$RemoteComputer" | select username
        $RemoteUser2 = $RemoteUser1 -creplace '^[^\\]*\\', ''
        $RemoteUser3 = $RemoteUser2.substring(0,$RemoteUser2.Length-1)
                If ($RemoteUser3 -eq "@{username=")
                    {$RemoteUser3 = "No User has logged in"
                    Write-Host -ForegroundColor Green "The remote machine is Online"
                    Write-Host -ForegroundColor DarkGreen "Current or Last Logged in user is: $RemoteUser3"
                    $User = "No"
                    }
                    Else {
                    Write-Host -ForegroundColor Green "The remote machine is Online"
                    Write-Host -ForegroundColor RED "WARNING: A User may be actively using this machine verify before restarting!"
                    Write-Host -ForegroundColor DarkRed "Current or Last Logged in user is: $RemoteUser3"
                    $User = "Yes"
       
                    }

$Correct = Read-Host "Is this the correct computer? (Y/N)"

If ($Correct -eq "Y") 
    {$PCUP = "Online"


Function remote_message{

    $message = "Message from $Username : Your PC will restart in 5 minutes. Please save your work!";

    Invoke-WmiMethod -Class win32_process -ComputerName $RemoteComputer -Name create -ArgumentList  "c:\windows\system32\msg.exe * $message" }



$Header = tasklist /s $RemoteComputer /FI "Username eq $RemoteUser3" /FI "Session ne 0" |Select -First 3
   
                
Do {$CheckProcesses = Read-Host "Would you like to see their open processes? (Y/N)" } While ($CheckProcesses -notmatch "Y|N")
$CheckProcesses = $CheckProcesses.substring(0,1)
If ($CheckProcesses -eq "N"){}
ElseIf ($User -eq "Yes"){
    If ($CheckProcesses -eq "Y") {
        $Header
        tasklist /s $RemoteComputer /FI "Username eq $RemoteUser3" /FI "Session ne 0" /FI "ImageName ne svchost.exe" | Select -Skip 3 |sort
        Write-Host "Showing $RemoteUser3's Proccesses"}
        }
     Elseif ($User -eq "No"){
    $Header
    tasklist /s $RemoteComputer /FI "ImageName ne svchost.exe" | Select -Skip 3 |sort
    Write-Host "Showing System Proccesses"}


} 
}
    Else {
        Set-ExecutionPolicy Restricted
        Write-Host -ForegroundColor Red "The remote machine is Down or Not connected to the internet. Please Verify & Try Again"
        Write-Host -ForegroundColor Red "The machine may not be on 'CUSD'"
		#Write-Host "Press any key to exit"
        #$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        #(Get-Host).SetShouldExit(0)
        #Exit
        }

}Until ($PCUP -eq "Online")





$NewComputerName = Read-Host "New Computer name"
$NewComputerName = "$NewComputerName".ToUpper()
Do { $Restart = Read-Host "Would you like to Restart? I for instant restart (Y/N/I)" } While ($Restart -notmatch "Y|N|I")
$Restart = $Restart.substring(0,1)
$Username = Read-Host "Your Username"
Write-Host "$RemoteComputer will be renamed $NewComputerName"
If ($Restart -eq "Y") {
    Rename-Computer -ComputerName "$RemoteComputer" -NewName "$NewComputerName" -DomainCredential Chico\$Username -Force
    #shutdown /r /t 300 /m $RemoteComputer "The IT department has initiated a remote restart on your computer.
    shutdown /r /f /t 300 /m $RemoteComputer /c "The IT department has initiated a remote restart on your computer.                                                                Your PC will restart in 5 minutes. Please save your work!" | Out-Null

    remote_message


    Write-Host -ForegroundColor Green "The Device Will Now Restart; Run this program again to see if the new machine is online!"

    Write-Host -ForegroundColor DarkRed "To abort shutdown /a /m $RemoteComputer"

        $i = 300

do {
    Write-Host $i
    Sleep 1
    $i--
} while ($i -gt 0)


Write-Host -ForegroundColor DarkGreen "$NewComputerName should now be restarting"

        $i = 45

do {
    Write-Host $i
    Sleep 1
    $i--
} while ($i -gt 0)


#Check if alive

If (Test-Connection -BufferSize 32 -Count 1 -ComputerName $NewComputerName -Quiet) {
        $RemoteUser1 = Get-WmiObject -Class win32_computersystem -ComputerName "$NewComputerName" | select username
        $RemoteUser2 = $RemoteUser1 -creplace '^[^\\]*\\', ''
        $RemoteUser3 = $RemoteUser2.substring(0,$RemoteUser2.Length-1)
                If ($RemoteUser3 -eq "@{username=")
                    {$RemoteUser3 = "No User has logged in"
                    Write-Host -ForegroundColor Green "The remote machine is Online"
                    Write-Host -ForegroundColor DarkGreen "Current or Last Logged in user is: $RemoteUser3"
                    $User = "No"
                    }
                    Else {
                    Write-Host -ForegroundColor Green "The remote machine is Online"
                    Write-Host -ForegroundColor RED "WARNING: A User may be actively using this machine verify before restarting!"
                    Write-Host -ForegroundColor DarkRed "Current or Last Logged in user is: $RemoteUser3"
                    $User = "Yes"
       
                    }



Set-ExecutionPolicy Restricted
}

}Elseif ($Restart -eq "N"){
    Rename-Computer -ComputerName "$RemoteComputer" -NewName "$NewComputerName" -DomainCredential Chico\$Username -Force
    Write-Host "$NewComputerName will need to be restarted if the user logs out" 
    Set-ExecutionPolicy Restricted
    }
Elseif ($Restart -eq "I"){
Rename-Computer -ComputerName "$RemoteComputer" -NewName "$NewComputerName" -DomainCredential Chico\$Username -Force
    #shutdown /r /t 300 /m $RemoteComputer "The IT department has initiated a remote restart on your computer.
    shutdown /r /t 1 /m $RemoteComputer
    




#Write-Host "Press Any Key"
#$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
#(Get-Host).SetShouldExit(0)
Exit}

Else {
Write-Host "Press any key to exit"
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
(Get-Host).SetShouldExit(0)
Exit}

$RemoteComputer = Read-Host "Computer name"


Do {
$PCUP = "Offline"
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

                   
$PCUP = "Online"

} Else {
        Set-ExecutionPolicy Restricted
        Write-Host -ForegroundColor Red "The remote machine is Down or Not connected to the internet. Please Verify & Try Again"
        Write-Host -ForegroundColor Red "The machine may not be on 'CUSD'"
		#Write-Host "Press any key to exit"
        #$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        #(Get-Host).SetShouldExit(0)
        #Exit
        $RemoteComputer = Read-Host "Computer name"
}
}Until ($PCUP -eq "Online")


$Reboot = Read-Host "Are you certain you want to reboot $RemoteComputer? Y/N"

Restart-Computer -ComputerName $RemoteComputer -Force
Write-Host "If no errors have popped up the machine should have restarted!"

Read-Host "Wait 5 and press anykey to see if the machine is online"



Do {$Alive = Test-Connection -BufferSize 32 -Count 1 -ComputerName $RemoteComputer -Quiet} Until ($Alive -eq "True")
    Read-Host "Wait 5 and press anykey to see if the machine is online"

    If ($Alive -eq "True") {Write-Host "Machine Is Online"}
        else {Write-Host "Machine is Offline"}

$Alive = "True"
Read-Host "Press any key to exit"
exit
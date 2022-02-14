### Import Modules ###

Import-Module ActiveDirectory


### Short Functions / One Liners ###

Function LastLogonTime {Get-ADComputer $ComputerName -Properties lastLogonTimestamp|select Name ,@{n='Last Logon';e={[datetime]::FromFileTime($_.lastLogonTimestamp)}} | out-host}

Function ComputerNameGrabber { $global:ComputerName = (Read-Host "Computer Name?").ToUpper()
				}

Function zCheckdoTempTechUsers { Get-ADGroupMember do-temp-techs | select Name }

Function zVariableCreator {notepad "$profile"}

Function zLastReboot {
	ComputerNameGrabber
	Write-Host "Last Reboot:",$(
	$(Get-EventLog -ComputerName $ComputerName -LogName System | 
    ? { $_.EventId -eq 6009 } | 
    select -first 1 | 
    % { $_.TimeGenerated;  }))
			}

Function LastRebootNoName {
	Write-Host "Last Reboot:",$(
	$(Get-EventLog -ComputerName $ComputerName -LogName System | 
    ? { $_.EventId -eq 6009 } | 
    select -first 1 | 
    % { $_.TimeGenerated; }))
			}


### Long Functions ###
Function zCheckPCIP 	{
			ComputerNameGrabber
			$ComputerName = $ComputerName.ToUpper()
			Get-ADComputer -Filter ('Name -like "*' + $ComputerName + '*"') -Properties IPv4Address | Sort-Object Name | FT Name,IPv4Address -A
		   	}




Function zIsPCOnline {
	#cls
	ComputerNameGrabber
	If (Test-Connection -BufferSize 32 -Count 1 -ComputerName $ComputerName -Quiet) {
        $RemoteUser1 = Get-WmiObject -Class win32_computersystem -ComputerName "$ComputerName" | select username
        $RemoteUser2 = $RemoteUser1 -creplace '^[^\\]*\\', ''
        $RemoteUser3 = $RemoteUser2.substring(0,$RemoteUser2.Length-1)
                If ($RemoteUser3 -eq "@{username=")
                    {$RemoteUser3 = "No User has logged in"
LastLogonTime
LastRebootNoName
                    Write-Host -ForegroundColor Green "The remote machine is Online"
                    Write-Host -ForegroundColor DarkGreen "Current or Last Logged in user is: $RemoteUser3"
                    }
                    Else {
LastLogonTime
LastRebootNoName
                    Write-Host -ForegroundColor Green "The remote machine is Online"
                    Write-Host -ForegroundColor Red "Current or Last Logged in user is: $RemoteUser3"
                    }
	}else {
LastLogonTime
LastRebootNoName
		    Write-Host -ForegroundColor Red "$ComputerName is offline or unable to be contacted"
}}	

Function zOpenPrograms {

	ComputerNameGrabber

	If (Test-Connection -BufferSize 32 -Count 1 -ComputerName $ComputerName -Quiet) {

	$RemoteUser1 = Get-WmiObject -Class win32_computersystem -ComputerName "$ComputerName" | select username
        $RemoteUser2 = $RemoteUser1 -creplace '^[^\\]*\\', ''
        $RemoteUser3 = $RemoteUser2.substring(0,$RemoteUser2.Length-1)
                If ($RemoteUser3 -eq "@{username=")
                    {$RemoteUser3 = "No User has logged in"
                    Write-Host -ForegroundColor Green "The remote machine is Online"
                    Write-Host -ForegroundColor DarkGreen "Current or Last Logged in user is: $RemoteUser3"
                    $User = "No"
                    tasklist /s $ComputerName /FI "Username eq $RemoteUser3" /FI "Session ne 0" /FI "ImageName ne svchost.exe" | Select -Skip 2 |sort
                    }
                    Else {
                    Write-Host -ForegroundColor Green "The remote machine is Online"
                    Write-Host -ForegroundColor Red "WARNING: A User may be actively using this machine verify before restarting!"
                    Write-Host -ForegroundColor Red "Current or Last Logged in user is: $RemoteUser3"
                    $User = "Yes"
                    tasklist /s $ComputerName /FI "Username eq $RemoteUser3" /FI "Session ne 0" /FI "ImageName ne svchost.exe" | Select -Skip 2 |sort
                        }
		       Do { $Kill = Read-Host "Kill/Open a Program or Exit? (K/O/E)" } While ($Kill -notmatch "K|O|E")
				$Kill = $Kill.substring(0,1)
				If ($Kill -eq "K") {
						$ProgramName = Read-Host "What is the program name to be KILLED? (Anything with the word will be closed)"
						##$ProgramName = "$ProgramName" + '*'
						$ProgramName = $ProgramName.Trim('"')
						$ProgramNameNotEmpty = tasklist /s $ComputerName /FI "Username eq $RemoteUser3" /FI "Session ne 0" /FI "ImageName eq $ProgramName*"| Measure-Object | Select Count
						$ProgramNameNotEmpty = $ProgramNameNotEmpty -replace "[^0-9]" , ''
						If ($ProgramNameNotEmpty -gt 2 ) 
						{
						Write-Host "Do you want to stop all processes that start with " -nonewline; Write-Host -F Red "'$ProgramName' " -nonewline; Write-Host "on " -nonewline; Write-Host -F Red "'$ComputerName'" -nonewline; Write-Host "??"
						get-process -Computer $ComputerName -name "$Programname*" | Stop-Process -Confirm > $null
						} 
						else {Write-Host -ForegroundColor Red "If you are seeing this you may have mistyped the program, please try again."
							}
							}
				Elseif ($Kill -eq "O") {
						Write-Host -ForegroundColor Yellow "A Few Options Are Calculator='Calc' File Explorer='explorer' Notepad='notepad' "
						$ProgramPath = Read-Host "What is the program name to be STARTED? ("C:\PATH\*.exe")(YOU MUST ADD QUOTES For \\ PATHS!)"
						#$ProgramPath = $ProgramPath.Trim('"')
						#$ProgramPath Curently working with manually adding qoutes
						$ProgramPath = "$ProgramPath"
						$ProgramPath
						$ProcessID = WMIC /node:"`"$($ComputerName)`"" process call create "$ProgramPath" | Select-String -Pattern "ProcessId"
							$ProcessID = $ProcessID -replace "[^0-9]"
							If ($ProcessID -gt '0')	{
								Write-Host -ForegroundColor Green "ProcessID: $ProcessID for $ProgramPath been created"
										}
							Else {Write-Host -ForegroundColor Red "An error has occured"}
							}
				Elseif ($Kill -eq "E"){Write-Host "Exiting Script"}
}
Else {Write-Host -ForegroundColor Red "PC seems to be offline"}
}

Function zOUCounter {
Write-Host "(Right click OU > Properties > Attribute Editor > DoubleClick DistinguishedName > Copy)"
$OU = Read-Host "What is the DistinguishedName?"
Get-ADComputer -SearchBase "$OU" -Filter * | Measure-Object
}

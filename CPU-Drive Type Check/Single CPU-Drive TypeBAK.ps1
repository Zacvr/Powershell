#$RemoteComputers = Get-Content -Path "\\mirage\Drivers\TechTools\ZVanRoekel\Fixes\Scripts\CPU & Ram Check\Computers.txt"
$RemoteComputer = Read-Host "Computer Name?"
    #Get-WmiObject -Class Win32_Processor -ComputerName $RemoteComputer | Select PSComputerName, Name | Out-File -append -FilePath "$PSScriptRoot\$RemoteComputer.txt"
    #Get-WmiObject -Class MSFT_PhysicalDisk -ComputerName $RemoteComputer -Namespace root\Microsoft\Windows\Storage | Select Friendlyname | Out-File -append -FilePath "$PSScriptRoot\$RemoteComputer.txt"



If (Test-Connection -BufferSize 32 -Count 1 -ComputerName $RemoteComputer -Quiet) { 
    $RemoteComputer.ToUpper()
    #Get-WmiObject -Class Win32_Processor -ComputerName mj-tc-001 | Select PSComputerName | foreach {$_.Name} | Out-File -append -FilePath "\\mirage\Drivers\TechTools\ZVanRoekel\Fixes\Scripts\CPU & Drive Type Check\Results.txt"
    $Processor = Get-WmiObject -Class Win32_Processor -ComputerName "$RemoteComputer" | Select Name | foreach {$_.Name}
    $Drive = Get-WmiObject -Class MSFT_PhysicalDisk -ComputerName "$RemoteComputer" -Namespace root\Microsoft\Windows\Storage | Select Friendlyname | foreach {$_.FriendlyName}
    $RAM = (Get-WmiObject -Class Win32_PhysicalMemory -ComputerName "$RemoteComputer" | Measure-Object -Property capacity -Sum).sum /1gb
    $RAM = echo "$RAM GB"  

$Newlines, $Newlines, $RemoteComputer, $Processor, $Drive, $RAM | Out-File -FilePath "$PSScriptRoot\$RemoteComputer.txt"
}
  else{$Newlines, $Newlines, $RemoteComputer, $Offline |Out-File -FilePath "$PSScriptRoot\$RemoteComputer.txt" }

Write-Host "Done"
notepad "$PSScriptRoot\$RemoteComputer.txt"

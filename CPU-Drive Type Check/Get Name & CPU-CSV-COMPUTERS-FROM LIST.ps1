$DataFile = "$PSScriptRoot\Test.csv"
#Get-ADComputer -Filter ('Name -like "*' + $RemoteComputer + '*"') -Properties IPv4Address | Sort-Object Name | FT Name,IPv4Address -A | Export-CSV $PSScriptRoot\$RemoteComputer.CSV
#Get-ADComputer -Filter ('Name -like "*' + $RemoteComputer + '*"') -Properties IPv4Address | Sort-Object Name | FT Name,IPv4Address -A | Export-CSV $PSScriptRoot\$RemoteComputer.CSV
$Computers = Get-Content "\\mirage\Drivers\TechTools\ZVanRoekel\Fixes\Scripts\Get Machine Name-IP\Winter Break Machines to Replace.txt"
    
foreach($Computer in $Computers){
if (Test-Connection $Computer -count 1 -quiet) {
    Get-WmiObject -Class Win32_Processor -ComputerName $Computer | Select PSComputerName, Name | Export-Csv -append -Path "$PSScriptRoot\Test.csv" -NoTypeInformation -Encoding UTF8 -Force
    Write-Host $Computer, $ComputerProcessor 

}
  else{Write-Host "$Server This Machine is Offline."}
}

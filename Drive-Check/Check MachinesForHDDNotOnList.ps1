#$Path = "$PSScriptRoot\Machines\AllMachines.csv"
#$Path
#if (!(Test-Path $Path))
#{
#New-Item -itemType File -Path $PSScriptRoot\Machines\AllMachines.CSV -Name ("Machines.CSV") | Out-Null
#}
#else
#{}

#This way we find only unknown machines

$CurrentListToIgnore = (import-csv "$PSScriptRoot\DrivesOfMachines.CSV").Name

Import-Module activedirectory

$host.ui.RawUI.WindowTitle = "List Of Computers"
$ComputerOU = 'OU=COMPUTERS,OU=Domain_Root,DC=chico,DC=usd'
        Write-host "Gathering Enabled servers from AD (This may take some time)..."

$Computers = (Import-CSV $PSScriptRoot\Machines\AllMachines.csv).Name | where {$CurrentListToIgnore -notcontains $_}
#$Computers = get-content $PSScriptRoot\Machines\AllMachines.csv | % {$_ -replace '"',''}



#$TotalIgnoredMachines = Get-Content $PSScriptRoot\Machines.csv | Measure-Object #| Select Count
#$TotalIgnoredMachines
#$TotalIgnoredMachines = $TotalMachines -replace "[^0-9]"
#$TotalIgnoredMachines
#$TotalIgnoredMachines = [int]$TotalMachines
$TotalIgnoredMachines = @(Import-CSV "$PSScriptRoot\DrivesOfMachines.CSV")# -Delimiter ';')
$TotalIgnoredMachines= $TotalIgnoredMachines.Count

                           
$TotalMachines = Get-Content "$PSScriptRoot\Machines\AllMachines.CSV" | Measure-Object | Select Count
$TotalMachines = $TotalMachines -replace "[^0-9]"
$TotalMachines = [int]$TotalMachines
Write-Host -F Green "There is a total of $TotalMachines in this list $TotalIgnoredMachines of those will be ignored"
$Number = $TotalIgnoredMachines
$SkippedMachines = [int]"0"



foreach ($Computer in $Computers){
$Computer = $Computer.ToUpper()
Write-Progress -Activity "Processing $Computer Number $Number; Total Skipped Machines $SkippedMachines"
Try{
$Number = $Number+1
if (Test-Connection $Computer -count 1 -quiet){
$Drive = ""

#$Number = $Number+1
#Write-host -F Cyan "$Computer is $Number out of $TotalMachines"
    $report = @()

    $Drive = Get-WmiObject -Class MSFT_PhysicalDisk -ComputerName $Computer -Namespace root\Microsoft\Windows\Storage -erroraction Stop |  select -ExpandProperty friendlyname
    if (!$Drive){Write-Host "Drive is Null"} 
    else{
        Write-Host -F Cyan "$Computer" -nonewline; Write-Host " has a " -nonewline; ;Write-Host -F Magenta "$Drive"
        New-Object psobject -Property @{Name=$Computer;Drive=$Drive} | export-csv -NoTypeInformation -append "$PSScriptRoot\DrivesOfMachines.CSV"
        }
}
    Else { $SkippedMachines = $SkippedMachines+1}
#$Number = $Number+1
#Write-host -F Magenta "$Computer is $Number out of $TotalMachines; failed to get Drive Type." # Collecting Last Logon Date"
       }

catch {
#$Number = $Number+1
#Write-host -F Red "$Computer is $Number out of $TotalMachines RPC Server is Unavailiable"
}
}


    

@echo off
start powershell Set-ExecutionPolicy RemoteSigned
:ask
@echo Would you like to use a Domain Account, Domain Group, or Create a Local Account?(Domain/Group/Local)
set INPUT=
set /P INPUT=Type input: %=%
If /I "%INPUT%"=="Domain" goto Domain 
If /I "%INPUT%"=="Local" goto Local
If /I "%INPUT%"=="Group" goto Group
goto ask
:Domain
@echo you selected a Domain Account
start powershell -noexit -file "\\mirage\Drivers\TechTools\ZVanRoekel\Fixes\Scripts\Local Admin\Local Domain Admin Via Remote.ps1"
goto exit
:Local
@echo you selected A Local Account
start powershell -noexit -file "\\mirage\Drivers\TechTools\ZVanRoekel\Fixes\Scripts\Local Admin\Create Local Admin Via Remote.ps1"
goto exit
:Group
@echo you selected A Local Account
start powershell -noexit -file "\\mirage\Drivers\TechTools\ZVanRoekel\Fixes\Scripts\Local Admin\Local Domain Group Admin Via Remote.ps1"
goto exit
:exit
exit
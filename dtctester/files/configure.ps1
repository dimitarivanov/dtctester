<#
.SYNOPSIS
Configuration script for MSDTC testing.
.DESCRIPTION
The script configures MSDTC and ODBC settings.
.PARAMETER MSDTC
Executes the MSDTC configuration.
.PARAMETER ODBC
Configures ODBC settings.
.PARAMETER RemoveODBC
Removes the ODBC settings.
#>
Param
(
  [switch]$MSDTC,
  [switch]$ODBC,
  [switch]$RemoveODBC
)

function ConfigureMSDTC()
{
  Stop-Service MSDTC
  Uninstall-Dtc -Confirm:$false
  Install-Dtc
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\MSDTC\Security' -Name LuTransactions -Value 1
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\MSDTC\Security' -Name NetworkDtcAccess -Value 1
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\MSDTC\Security' -Name NetworkDtcAccessInbound -Value 1
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\MSDTC\Security' -Name NetworkDtcAccessOutbound -Value 1
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\MSDTC\Security' -Name NetworkDtcClients -Value 1
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\MSDTC\Security' -Name NetworkDtcAccessTransactions -Value 1
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\MSDTC\Security' -Name NetworkDtcAccessAdmin -Value 1
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\MSDTC\Security' -Name NetworkDtcAccessClients -Value 1
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\MSDTC' -Name AllowOnlySecureRpcCalls -Value 1
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\MSDTC' -Name FallbackToUnsecureRPCIfNecessary -Value 0
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\MSDTC' -Name TurnOffRpcSecurity -Value 0
  Set-Service MSDTC -StartupType Automatic
  Restart-Service MSDTC -Force
}

function CreateODBC()
{
  Add-OdbcDsn -Name $env:MSDTC_SQLSERVER_HOSTNAME -DriverName "SQL Server" -Platform "32-bit" -DsnType "System" -SetPropertyValue @("Server=" + $env:MSDTC_SQLSERVER_HOSTNAME  + "," + $env:MSDTC_SQLSERVER_PORT, "Trusted_Connection=No", "Database=" + $env:MSDTC_TEST_DATABASE)    
}

function RemoveODBC()
{
  Get-OdbcDsn -Name $env:MSDTC_SQLSERVER_HOSTNAME -DriverName "SQL Server" -Platform "32-bit" -DsnType "System" | Remove-OdbcDsn    
}

if($MSDTC){
  ConfigureMSDTC
}

if($ODBC){
  CreateODBC
}

if($RemoveODBC){
  RemoveODBC
}

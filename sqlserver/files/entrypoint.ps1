<#
.SYNOPSIS
Entrypoint script for MSDTC testing.
.DESCRIPTION
The script configures ODBC and MSDTC settings.
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory=$false)]
  [string]$sa_password,

  [Parameter(Mandatory=$false)]
  [string]$attach_dbs
)
process {
  Write-Verbose "Network Configuration"
  Get-NetIPConfiguration

  Write-Verbose "DTC Configuration"
  Get-Dtc
  Get-DtcNetworkSetting

  Write-Host $env:WORKDIR

  $args = @()
  $args += ("-sa_password " + $sa_password)
  $args += ("-attach_dbs " + $attach_dbs)
  $args += ("-Verbose ")
  $cmd = ".\\new_start.ps1"

  Write-Host "$cmd $args"
  Invoke-Expression "$cmd $args"

  Write-Verbose "Creating $env:MSDTC_TEST_DATABASE database ..."
  Invoke-Sqlcmd -Query "CREATE DATABASE $env:MSDTC_TEST_DATABASE;" -Verbose
  Write-Verbose "Database $env:MSDTC_TEST_DATABASE created."

  Write-Verbose "Pinging $env:MSDTC_TESTER_HOSTNAME ..."
  Test-Connection "$env:MSDTC_TESTER_HOSTNAME" | Format-Table

  while ($true) { Start-Sleep -Seconds 3600 }
}
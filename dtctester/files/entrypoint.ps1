<#
.SYNOPSIS
Entrypoint script for MSDTC testing.
.DESCRIPTION
The script configures ODBC and MSDTC settings.
#>

[CmdletBinding()]
param(
)
process {
  $args = @()
  $args += ("-MSDTC")
  $args += ("-ODBC")
  $cmd = ".\\configure.ps1"

  Invoke-Expression "$cmd $args"

  Write-Verbose "Network Configuration"
  Get-NetIPConfiguration

  Write-Verbose "DTC Configuration"
  Get-Dtc
  Get-DtcNetworkSetting

  Write-Verbose "ODBC Configuration"
  Get-OdbcDsn

  Write-Verbose "Pinging $env:MSDTC_SQLSERVER_HOSTNAME ..."
  Test-Connection "$env:MSDTC_SQLSERVER_HOSTNAME" | Format-Table

  Write-Verbose "Running dtctester tool...`r`n"
  .\dtctester.exe $env:MSDTC_SQLSERVER_HOSTNAME $env:MSDTC_SQLSERVER_USER $env:MSDTC_SQLSERVER_PASSWORD
  Write-Host

  try {
    Write-Verbose "Running Test-Dtc cmdlet... `r`n"
    Test-Dtc -LocalComputerName $env:COMPUTERNAME -RemoteComputerName $env:MSDTC_SQLSERVER_HOSTNAME
  }
  catch [System.Exception] {
    Write-Verbose "Test-Dtc cmdlet failed... `r`n $_"
  }

  while ($true) { Start-Sleep -Seconds 3600 }
}
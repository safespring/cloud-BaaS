 <#
.SYNOPSIS
  Script to run scheduled SQL Full backup
.DESCRIPTION

.PARAMETER Verbose
Provides Verbose output which is useful for troubleshooting
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
.INPUTS
  None
.OUTPUTS
  None
.NOTES
  Version:        1.0
  Author:         Christian Petersson
  Company:        IssTech AB
  Creation Date:  2023-03-06
  Purpose/Change: Initial script development
#>

$fcm_path = "C:\Program Files\Tivoli\FlashCopyManager"
$optfile = "C:\Program Files\Tivoli\TSM\TDPSql\dsm.opt"
$sched_log = "C:\Program Files\Tivoli\TSM\TDPSql\sqlsched.log"
$sqlfull = "C:\Program Files\Tivoli\TSM\TDPSql\sqlfull.log"

$sqlinstance = (get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances
$defaultinstance = $sqlinstance | Where-Object {$_ -eq "MSSQLSERVER"}
$namedinstance = $sqlinstance | Where-Object {$_ -ne "MSSQLSERVER"}

### Import Cmdlets for protecting Microsoft SQL Server data ###
dir "$fcm_path\fmmodule*.dll" | select -expand fullname | import-module 

### Run full backup of default instance database ###

if ($defaultinstance){
    foreach ($di in $defaultinstance) {
        Backup-DpSqlComponent -Name * -Full -TsmOptFile $optfile -LogFile $sqlfull
    }
}

### Checks if named instance exists and run full backup on databases ###

if ($namedinstance){
    foreach ($ni in $namedinstance) {
        Backup-DpSqlComponent -Name * -SqlServer "$($env:COMPUTERNAME)\$($ni)" -Full -TsmOptFile $optfile -LogFile $sqlfull
    }
} 

#Requires -Version 5.1
<#
.SYNOPSIS
  Sanitized sample: scheduled Windows / Hyper-V health check with optional email summary.

.DESCRIPTION
  Example of the pattern used for weekly (and as-needed) health checks on
  Windows Server + Hyper-V hosts: collect local facts, flag exceptions,
  write a dated log, and optionally email a short summary.

  This is a SAMPLE. Organization names, host names, thresholds, and mail settings
  are fictional or parameterized. Do not run against production without
  review. No secrets are stored in this file.

.NOTES
  Author : Sean Rector (sample / sanitized)
  Intent : Documentation + automation sample for in-house infrastructure operations
  Scope  : Local host checks (disk, services, Hyper-V VM state, optional cluster)
  Non-goals: Not a monitoring platform replacement. Not a backup product integration.
#>

[CmdletBinding()]
param(
    [int]    $DiskWarnPercent   = 15,
    [int]    $DiskCritPercent   = 8,
    [string] $LogDirectory      = 'C:\ProgramData\OpsHealth\Logs',
    [string] $OrgName        = 'Lakeside Professional Group',
    [string] $SiteCode          = 'LPG-DC1',
    [string[]] $WatchServices   = @('WinRM', 'EventLog', 'LanmanServer', 'vmms'),
    [switch] $SendEmail,
    [string] $MailFrom          = 'ops-alerts@example.invalid',
    [string] $MailTo            = 'oncall@example.invalid',
    [string] $SmtpServer        = 'smtp.example.invalid'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function New-HealthItem {
    param(
        [ValidateSet('OK', 'WARN', 'CRIT', 'INFO')]
        [string] $Status,
        [string] $Check,
        [string] $Detail
    )
    [pscustomobject]@{
        Status    = $Status
        Check     = $Check
        Detail    = $Detail
        Timestamp = (Get-Date).ToString('s')
    }
}

function Get-DiskFindings {
    $items = @()
    Get-CimInstance -ClassName Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object {
        if ($_.Size -le 0) { return }
        $freePct = [math]::Round(($_.FreeSpace / $_.Size) * 100, 1)
        $freeGb  = [math]::Round($_.FreeSpace / 1GB, 1)
        $sizeGb  = [math]::Round($_.Size / 1GB, 1)
        $status  = if ($freePct -le $DiskCritPercent) { 'CRIT' }
                   elseif ($freePct -le $DiskWarnPercent) { 'WARN' }
                   else { 'OK' }
        $items += New-HealthItem -Status $status -Check "Disk $($_.DeviceID)" `
            -Detail ("{0}% free ({1} GB of {2} GB)" -f $freePct, $freeGb, $sizeGb)
    }
    $items
}

function Get-ServiceFindings {
    $items = @()
    foreach ($name in $WatchServices) {
        $svc = Get-Service -Name $name -ErrorAction SilentlyContinue
        if (-not $svc) {
            $items += New-HealthItem -Status 'INFO' -Check "Service $name" -Detail 'Not installed on this host'
            continue
        }
        $status = if ($svc.Status -eq 'Running') { 'OK' } else { 'CRIT' }
        $items += New-HealthItem -Status $status -Check "Service $name" -Detail $svc.Status
    }
    $items
}

function Get-HyperVFindings {
    $items = @()
    $vmms = Get-Service -Name vmms -ErrorAction SilentlyContinue
    if (-not $vmms) {
        $items += New-HealthItem -Status 'INFO' -Check 'Hyper-V' -Detail 'Hyper-V not installed on this host'
        return $items
    }

    try {
        $vms = Get-VM -ErrorAction Stop
    } catch {
        $items += New-HealthItem -Status 'CRIT' -Check 'Hyper-V inventory' -Detail $_.Exception.Message
        return $items
    }

    if (-not $vms) {
        $items += New-HealthItem -Status 'INFO' -Check 'Hyper-V VMs' -Detail 'No VMs registered on this host'
        return $items
    }

    foreach ($vm in $vms) {
        $status = switch ($vm.State) {
            'Running'  { 'OK' }
            'Off'      { 'INFO' }
            'Paused'   { 'WARN' }
            'Saved'    { 'WARN' }
            default    { 'CRIT' }
        }
        $detail = '{0} | Generation {1} | CPU {2} | Memory {3} MB' -f `
            $vm.State, $vm.Generation, $vm.ProcessorCount, $vm.MemoryAssigned
        $items += New-HealthItem -Status $status -Check ("VM {0}" -f $vm.Name) -Detail $detail
    }
    $items
}

function Get-ClusterFindings {
    $items = @()
    $mod = Get-Module -ListAvailable -Name FailoverClusters
    if (-not $mod) {
        $items += New-HealthItem -Status 'INFO' -Check 'Failover Cluster' -Detail 'FailoverClusters module not present'
        return $items
    }

    try {
        Import-Module FailoverClusters -ErrorAction Stop
        $cluster = Get-Cluster -ErrorAction Stop
        $items += New-HealthItem -Status 'OK' -Check 'Cluster name' -Detail $cluster.Name

        Get-ClusterNode | ForEach-Object {
            $status = if ($_.State -eq 'Up') { 'OK' } else { 'CRIT' }
            $items += New-HealthItem -Status $status -Check ("Cluster node {0}" -f $_.Name) -Detail $_.State
        }

        Get-ClusterGroup | ForEach-Object {
            $status = if ($_.State -eq 'Online') { 'OK' } elseif ($_.State -eq 'Offline') { 'INFO' } else { 'WARN' }
            $items += New-HealthItem -Status $status -Check ("Cluster group {0}" -f $_.Name) `
                -Detail ("{0} on {1}" -f $_.State, $_.OwnerNode)
        }
    } catch {
        $items += New-HealthItem -Status 'INFO' -Check 'Failover Cluster' -Detail 'Host is not a cluster member or access denied'
    }
    $items
}

# --- Run ---
New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
$stamp   = Get-Date -Format 'yyyyMMdd-HHmmss'
$hostName = $env:COMPUTERNAME

$findings = @()
$findings += New-HealthItem -Status 'INFO' -Check 'Context' -Detail ("{0} / {1} / {2}" -f $OrgName, $SiteCode, $hostName)
$findings += Get-DiskFindings
$findings += Get-ServiceFindings
$findings += Get-HyperVFindings
$findings += Get-ClusterFindings

$crit = @($findings | Where-Object Status -eq 'CRIT')
$warn = @($findings | Where-Object Status -eq 'WARN')
$exitCode = if ($crit.Count) { 2 } elseif ($warn.Count) { 1 } else { 0 }

$summary = [pscustomobject]@{
    Org       = $OrgName
    Site      = $SiteCode
    Host      = $hostName
    When      = (Get-Date).ToString('s')
    Crit      = $crit.Count
    Warn      = $warn.Count
    ExitCode  = $exitCode
}

$logPath = Join-Path $LogDirectory ("Health-{0}-{1}.json" -f $hostName, $stamp)
[pscustomobject]@{
    Summary  = $summary
    Findings = $findings
} | ConvertTo-Json -Depth 5 | Set-Content -Path $logPath -Encoding UTF8

Write-Host ("Health check {0} {1} - CRIT={2} WARN={3}  Log={4}" -f $OrgName, $hostName, $crit.Count, $warn.Count, $logPath)
$findings | Sort-Object @{Expression = { switch ($_.Status) { 'CRIT' {0} 'WARN' {1} 'OK' {2} default {3} } }}, Check |
    Format-Table Status, Check, Detail -AutoSize

if ($SendEmail) {
    $subject = '[{0}] {1} {2} health: {3} crit / {4} warn' -f $SiteCode, $OrgName, $hostName, $crit.Count, $warn.Count
    $body = $findings | Format-Table Status, Check, Detail -AutoSize | Out-String
    Send-MailMessage -From $MailFrom -To $MailTo -Subject $subject -Body $body -SmtpServer $SmtpServer
}

exit $exitCode




function Get-SystemReport {
    param (
        [switch]$System,
        [switch]$Disks,
        [switch]$Network
    )

    if (!$System -and !$Disks -and !$Network) {
        $System = $Disks = $Network = $true
    }

    if ($System) {
        Write-Host "=== System Hardware ===`n"
        Get-ComputerSystem | Format-List Model, Manufacturer, 'Total Physical Memory', 'Number Of Processors', 'SystemType'
        Write-Host "`n=== Operating System ===`n"
        Get-OperatingSystem | Format-List Caption, Version, BuildNumber
        Write-Host "`n=== Processor ===`n"
        Get-ProcessorInfo | Format-List Description, Speed, 'Number of Cores', L2Cache, L3Cache
        Write-Host "`n=== Video Card ===`n"
        Get-VideoCardInfo | Format-List Description, Manufacturer, 'Adapter RAM (MB)', 'Driver Version'
    }

    if ($Disks) {
        Write-Host "`n=== Physical Disks ===`n"
        Get-PhysicalDiskSummary
    }

    if ($Network) {
        Write-Host "`n=== Network Adapters ===`n"
        IPConfigurationReport
    }
}

Get-SystemReport @args

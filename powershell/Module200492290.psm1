function HelloWorld {
    Write-Host 'hello, world!'
}


function IPConfigurationReport {


# Get a collection of network adapter configuration objects
$adapters = Get-CimInstance Win32_NetworkAdapterConfiguration

# Filter the adapters to only include enabled adapters
$enabledAdapters = $adapters | Where-Object {$_.IPEnabled}

# Create a custom object for each enabled adapter, with the properties we want to include in the report
$reportData = foreach ($adapter in $enabledAdapters) {
    [PSCustomObject]@{
        "Adapter Description" = $adapter.Description
        "Index" = $adapter.Index
        "IP Address(es)" = $adapter.IPAddress -join ', '
        "Subnet Mask(s)" = $adapter.IPSubnet -join ', '
        "DNS Domain" = $adapter.DNSDomain
        "DNS Server(s)" = $adapter.DNSServerSearchOrder -join ', '
    }
}

# Output the report data in a formatted table
$reportData | Format-Table -AutoSize


}




Function Get-ComputerSystem {
    $system = Get-CimInstance win32_computersystem
    $props = @{
        Manufacturer=$system.Manufacturer
        Model=$system.Model
        "System Type"=$system.SystemType
        "Total Physical Memory (GB)"=[math]::Round($system.TotalPhysicalMemory/1GB, 2)
    }
    New-Object -TypeName PSObject -Property $props
}

Function Get-OperatingSystem {
    $os = Get-CimInstance win32_operatingsystem
    $props = @{
        Name=$os.Caption
        Version=$os.Version
    }
    New-Object -TypeName PSObject -Property $props
}

Function Get-ProcessorInfo {
    $processor = Get-CimInstance win32_processor
    $props = @{
        Description=$processor.Name
        Speed="$($processor.MaxClockSpeed) MHz"
        "Number of Cores"=$processor.NumberOfCores
    }
    if ($processor.L2CacheSize) {
        $props += @{L2Cache="L2 $($processor.L2CacheSize) KB"}
    }
    if ($processor.L3CacheSize) {
        $props += @{L3Cache="L3 $($processor.L3CacheSize) KB"}
    }
    New-Object -TypeName PSObject -Property $props
}

Function Get-PhysicalMemorySummary {
    $memory = Get-CimInstance win32_physicalmemory
    $props = @()
    foreach ($stick in $memory) {
        $props += @{
            Vendor=$stick.Manufacturer
            Description=$stick.Caption
            Size="$($stick.Capacity/1GB) GB"
            "Bank/Slot"="Bank $($stick.BankLabel)/Slot $($stick.MemoryType)"
        }
    }
    $table = $props | Format-Table -AutoSize | Out-String
    $total = "Total RAM Installed: $($memory.Capacity/1GB) GB"
    $result = $table, $total
    $result
}

function Get-PhysicalDiskSummary {
    $diskDrives = Get-CimInstance CIM_DiskDrive
    $diskInfo = foreach ($disk in $diskDrives) {
        $partitions = $disk | Get-CimAssociatedInstance -ResultClassName CIM_DiskPartition
        foreach ($partition in $partitions) {
            $logicalDisks = $partition | Get-CimAssociatedInstance -ResultClassName CIM_LogicalDisk
            foreach ($logicalDisk in $logicalDisks) {
                [PSCustomObject]@{
                    Vendor = $disk.Manufacturer
                    Model = $disk.Model
                    Size = '{0:N2} GB' -f ($disk.Size / 1GB)
                    'Free Space' = '{0:N2} GB' -f ($logicalDisk.FreeSpace / 1GB)
                    'Used Space' = '{0:N2} GB' -f (($logicalDisk.Size - $logicalDisk.FreeSpace) / 1GB)
                    'Percentage Free' = '{0:N2}%' -f (($logicalDisk.FreeSpace / $logicalDisk.Size) * 100)
                }
            }
        }
    }

    $diskInfo | Format-Table -AutoSize
}


Function Get-VideoCardInfo {
    $videoCard = Get-CimInstance win32_videocontroller
    $props = @{
        Description = $videoCard.Description
        Manufacturer = $videoCard.VideoProcessor
        "Adapter RAM (MB)" = [math]::Round($videoCard.AdapterRAM / 1MB)
        "Driver Version" = $videoCard.DriverVersion
    }
    New-Object -TypeName PSObject -Property $props | Format-List Description, Manufacturer, 'Adapter RAM (MB)', 'Driver Version'
}

function Get-SystemReport {
    Write-Host "=== System Hardware ===`n"
    Get-ComputerSystem | Format-List Model, Manufacturer, 'Total Physical Memory', 'Number Of Processors', 'SystemType'

    Write-Host "`n=== Operating System ===`n"
    Get-OperatingSystem | Format-List Caption, Version, Build

    Write-Host "`n=== Processor ===`n"
    Get-ProcessorInfo | Format-List Description, Speed, 'Number of Cores', L2Cache, L3Cache

    Write-Host "`n=== Memory ===`n"
    Get-PhysicalMemorySummary

    Write-Host "`n=== Physical Disks ===`n"
    Get-PhysicalDiskSummary

    Write-Host "`n=== Network Adapters ===`n"
    IPConfigurationReport

    Write-Host "`n=== Video Card ===`n"
    Get-VideoCardInfo
}



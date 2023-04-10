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

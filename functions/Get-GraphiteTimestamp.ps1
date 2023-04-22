function Get-GraphiteTimestamp {
    <#
    .Synopsis
        Create a timestamp suitable for Graphite (Unix Epoch).
    .Description
        Calling this function will return a timestamp suitable for Graphite:
            - If a timestamp is provided it will be parsed and converted.
            - If no timestamp is provided the current date/time will be used.
    .Example
        $timestamp = Get-GraphiteTimestamp
        Write-Host "Current Unix Epoch is: $timestamp"
    .Example
        $timestamp = Get-GraphiteTimestamp -Timestamp '2022-09-07T14:51:57Z'
        Write-Host "Unix Epoch for 2022-09-07T14:51:57Z is: $timestamp"
    .Example
        $timestamp = Get-GraphiteTimestamp -Timestamp '1662562317'
        Write-Host "Unix Epoch for 1662562317 is, you guessed it...: $timestamp"
    .Link
        https://en.wikipedia.org/wiki/Unix_time
    #>
    param (
        # Specifies the timstamp to parse, if provided.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Timestamp,

        # Specifies the number of seconds to add to the timestamp. The value can be negative or positive.
        [int] $AddSeconds = 0
    )

    process {
        Write-Debug -Message "Input timestamp: $Timestamp"

        # Check if already a Unix Epoch string
        if ($Timestamp -notmatch '^\d{10}$') {
            if (-Not $Timestamp) {
                $date = [DateTime]::UtcNow
                Write-Debug -Message "Generated new timestamp: $($date.ToString('yyyy-MM-ddTHH:mm:ssZ'))"
            } else {
                $date = [DateTime]::Parse($Timestamp, [CultureInfo]::InvariantCulture).ToUniversalTime()
            }
        } else {
            $date = [DateTime]::Parse('1970-01-01T00:00:00Z', [CultureInfo]::InvariantCulture).ToUniversalTime().AddSeconds($Timestamp)
        }

        # Convert to Unix Epoch
        $Timestamp = Get-Date ($date.AddSeconds($AddSeconds)) -UFormat %s
        Write-Debug -Message "Converted to timestamp Unix Epoch: $Timestamp"

        # Output Unix Epoch
        $Timestamp
    }
}

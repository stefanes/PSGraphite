﻿function Get-GraphiteTimestamp {
    <#
    .Synopsis
        Create a timestamp suitable for Graphite (Unix epoch).
    .Description
        Calling this function will return a timestamp suitable for Graphite:
          * If a timestamp is provided it will be parsed and converted.
          * If no timestamp is provided the current date/time will be used.
    .Example
        $timestamp = Get-GraphiteTimestamp
        Write-Host "Current Unix epoch is: $timestamp"
    .Example
        $timestamp = Get-GraphiteTimestamp -Timestamp '2022-09-07T14:51:57Z'
        Write-Host "Unix epoch for 2022-09-07T14:51:57Z is: $timestamp"
    .Example
        $timestamp = Get-GraphiteTimestamp -Timestamp '1662562317'
        Write-Host "Unix epoch for 1662562317 is, you guessed it...: $timestamp"
    .Link
        https://en.wikipedia.org/wiki/Unix_time
    #>
    param (
        # Specifies the timstamp to parse, if provided.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Timestamp
    )

    process {
        Write-Debug "Input timestamp: $Timestamp"

        # Check if already a Unix epoch string
        if ($Timestamp -notmatch '^\d{10}$') {
            if (-Not $Timestamp) {
                $date = [DateTime]::UtcNow
                Write-Debug "Generated new timestamp: $($date.ToString('yyyy-MM-ddTHH:mm:ssZ'))"
            }
            else {
                $date = [DateTime]::Parse($Timestamp)
            }

            # Convert to Unix epoch time
            $Timestamp = Get-Date $date.ToUniversalTime() -UFormat %s
            Write-Debug "Converted to Unix epoch timestamp: $Timestamp"
        }

        # Output Unix epoch timestamp
        $Timestamp
    }
}

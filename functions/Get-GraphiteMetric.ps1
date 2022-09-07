function Get-GraphiteMetric {
    <#
    .Synopsis
        Get Graphite metrics data to send.
    .Description
        Calling this function will return metrics data for sending to Graphite.

        Note: Metrics input must be provided in the format '@(@{...}, @{...})', see example.
    .Example
        $graphiteMetrics = Get-GraphiteMetric -Metrics @(
            @{
                name = 'test.series.1'; value = 3.14159
            }
            @{
                name = 'test.series.2'; value = 3.14159
            }
        ) -IntervalInSeconds 10 -Timestamp $timestamp
        Write-Host "Will send the following metrics to Graphite: $graphiteMetrics"
    .Link
        Get-GraphiteTimestamp
    .Link
        https://grafana.com/docs/grafana-cloud/data-configuration/metrics/metrics-graphite/http-api/#adding-new-data-posting-to-metrics
    #>
    param (
        # Specifies the metrics name/value pair to send.
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [Object[]] $Metrics,

        # Specifies the resolution of the metric in seconds.
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [Alias('Interval')]
        [int] $IntervalInSeconds,

        # Specifies timestamp, will be converted to Unix epoch time if needed.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Timestamp
    )
    process {
        # Construct Graphite metrics data
        $sendTimestamp = Get-GraphiteTimestamp -Timestamp $Timestamp
        $sendMetrics = @()
        foreach ($metric in $Metrics) {
            $sendMetrics += @{
                name     = $metric.name
                interval = [int] $IntervalInSeconds # int
                value    = [float] $metric.value # float64
                time     = [int64] $sendTimestamp # int64
            }
        }
        $sendMetrics = @(, $sendMetrics) | ConvertTo-Json -Depth 10
        Write-Debug "Gaphite metrics:"
        Write-Debug "$sendMetrics"

        # Output object
        $sendMetrics
    }
}

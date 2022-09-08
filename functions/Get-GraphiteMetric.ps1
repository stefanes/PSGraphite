function Get-GraphiteMetric {
    <#
    .Synopsis
        Get Graphite metrics data to send.
    .Description
        Calling this function will return metrics data for sending to Graphite.

        Notes:
            - Metrics input must be provided in the format '@(@{...}, @{...})', see example.
            - Tags can be added globally, i.e. to all metrics, or per metric
    .Example
        $graphiteMetrics = Get-GraphiteMetric -Metrics @{
            name = 'test.series.0'; value = '3.14'
        } -IntervalInSeconds 10 -Timestamp $timestamp -Tags 'tag1=value1'
        Write-Host "Will send the following metrics to Graphite: $graphiteMetrics"
    .Example
        $graphiteMetrics = Get-GraphiteMetric -Metrics @(
            @{
                name = 'test.series.1'; value = '3.14159'
            }
            @{
                name  = 'test.series.2'
                value = '3'
                tags  = @(
                    'tag3=value3'
                    'tag4=value4'
                )
            }
        ) -IntervalInSeconds 10 -Timestamp $timestamp -Tags @('tag1=value1', 'tag2=value2')
        Write-Host "Will send the following metrics to Graphite: $graphiteMetrics"
    .Link
        Get-GraphiteTimestamp
    .Link
        https://grafana.com/docs/grafana-cloud/data-configuration/metrics/metrics-graphite/http-api/#adding-new-data-posting-to-metrics
    #>
    param (
        # Specifies the metrics name/value pairs to send.
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [Object[]] $Metrics,

        # Specifies the resolution of the metrics in seconds.
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [Alias('Interval')]
        [int] $IntervalInSeconds,

        # Specifies the timestamp of the metrics, converted to Unix Epoch if needed.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Timestamp,

        # Specifies the tag, in the format 'tag=value', to add to every metric.
        [string[]] $Tags
    )
    process {
        # Construct Graphite metrics data to send
        $sendTimestamp = Get-GraphiteTimestamp -Timestamp $Timestamp
        $sendMetrics = @()
        foreach ($metric in $Metrics) {
            # Create new metric point
            $metricPoint = @{
                name     = $metric.name
                interval = [int] $IntervalInSeconds # int
                value    = [float] $metric.value # float64
                time     = [int64] $sendTimestamp # int64
            }

            # If applicable, add tags - both global, and local to the metric point
            $tags = $Tags
            if ($metric.tags) {
                $tags += $metric.tags
            }
            if ($tags) {
                $metricPoint += @{ tags = $tags }
            }
            $sendMetrics += $metricPoint
        }
        $sendMetrics = @(, $sendMetrics) | ConvertTo-Json -Depth 10
        Write-Debug "Gaphite metrics:"
        Write-Debug "$sendMetrics"

        # Output object
        $sendMetrics
    }
}

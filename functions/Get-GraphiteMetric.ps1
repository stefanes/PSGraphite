function Get-GraphiteMetric {
    <#
    .Synopsis
        Get Graphite metrics data to send.
    .Description
        Calling this function will return metrics data for sending to Graphite, given the provided metric points.

        Notes:
            - Metrics input must be provided in the format '@( @{...}, @{...} )'.
            - The metric points *must* include a 'value' property
            - Tags, provided through the '-Tags' parameter, are appended to all metric points.
            - For all other properties the parameter value is used if value it missing from input.
    .Example
        $graphiteMetrics = Get-GraphiteMetric -Metrics @{
            name = 'test.series.0'; value = '3.14159'; tags = 'tag1=value1'
        } -IntervalInSeconds 10 -Timestamp $timestamp
        Write-Host "Will send the following metrics to Graphite: $graphiteMetrics"
    .Example
        $graphiteMetrics = Get-GraphiteMetric -Metrics @(
            @{
                name = 'test.series.1'; value = '3.14159'
            }
            @{
                name  = 'test.series.2'
                value = '3.14159'
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
        # Specifies the metric points to send.
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [Object[]] $Metrics,

        # Specifies the name of the metrics, unless provided in metric point.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Name,

        # Specifies the resolution of the metrics in seconds, unless provided in metric point.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Interval')]
        [int] $IntervalInSeconds = 10,

        # Specifies the timestamp of the metrics, converted to Unix Epoch if needed, unless provided in metric point.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Timestamp,

        # Specifies tags, in the format 'tag=value', to add to all metric points.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]] $Tags = @()
    )
    process {
        # Construct Graphite metrics data to send
        $sendMetrics = @()
        foreach ($metric in $Metrics) {
            # Create new metric point
            $mpName = if ($metric.name) { $metric.name } else { $Name }
            $mpPointInterval = if ($metric.interval -gt 0) { $metric.interval } else { $IntervalInSeconds }
            $mpPointTime = if ($metric.time -gt 0) { $metric.time } else { Get-GraphiteTimestamp -Timestamp $Timestamp }
            $metricPoint = @{
                name     = $mpName
                interval = [int] $mpPointInterval # int
                value    = [float] $metric.value # float64
                time     = [int64] $mpPointTime # int64
            }

            # If applicable, add tags - both global, and local to the metric point
            [string[]] $mpTags = $Tags
            $mpTags += if ($metric.tags) { $metric.tags }
            $mpTags = $mpTags | Select-Object -Unique
            if ($mpTags) {
                $metricPoint += @{ tags = $mpTags }
            }

            # Validate mertic point
            if ($null -eq $metricPoint.name -Or `
                    $metricPoint.name -eq '') {
                throw "Invalid metric point: $($metricPoint | ConvertTo-Json | Out-String)"
            }

            # Append metric point to metrics
            $sendMetrics += $metricPoint
        }
        $sendMetrics = @(, $sendMetrics) | ConvertTo-Json -Depth 10
        Write-Debug "Gaphite metrics:"
        Write-Debug "$sendMetrics"

        # Output object
        $sendMetrics
    }
}

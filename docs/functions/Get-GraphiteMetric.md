# Get-GraphiteMetric

## SYNOPSIS
Get Graphite metrics data to send.

## SYNTAX

```
Get-GraphiteMetric [-Metrics] <Object[]> [-IntervalInSeconds] <Int32> [[-Timestamp] <String>]
 [[-Tags] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Calling this function will return metrics data for sending to Graphite.

Notes:
    - Metrics input must be provided in the format '@(@{...}, @{...})', see example.
    - Tags can be added globally, i.e.
to all metrics, or per metric

## EXAMPLES

### EXAMPLE 1
```
$graphiteMetrics = Get-GraphiteMetric -Metrics @{
    name = 'test.series.0'; value = '3.14'
} -IntervalInSeconds 10 -Timestamp $timestamp -Tags 'tag1=value1'
Write-Host "Will send the following metrics to Graphite: $graphiteMetrics"
```

### EXAMPLE 2
```
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
```

## PARAMETERS

### -Metrics
Specifies the metrics name/value pairs to send.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -IntervalInSeconds
Specifies the resolution of the metrics in seconds.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: Interval

Required: True
Position: 2
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Timestamp
Specifies the timestamp of the metrics, converted to Unix Epoch if needed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Tags
Specifies the tag, in the format 'tag=value', to add to every metric.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[Get-GraphiteTimestamp](Get-GraphiteTimestamp.md)

[https://grafana.com/docs/grafana-cloud/data-configuration/metrics/metrics-graphite/http-api/#adding-new-data-posting-to-metrics](https://grafana.com/docs/grafana-cloud/data-configuration/metrics/metrics-graphite/http-api/#adding-new-data-posting-to-metrics)


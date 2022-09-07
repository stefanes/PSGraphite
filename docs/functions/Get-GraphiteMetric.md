# Get-GraphiteMetric

## SYNOPSIS
Get Graphite metrics data to send.

## SYNTAX

```
Get-GraphiteMetric [-Metrics] <Object[]> [-IntervalInSeconds] <Int32> [[-Timestamp] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Calling this function will return metrics data for sending to Graphite.

Note: Metrics input must be provided in the format '@(@{...}, @{...})', see example.

## EXAMPLES

### EXAMPLE 1
```
$graphiteMetrics = Get-GraphiteMetric -Metrics @(
    @{
        name = 'test.series.1'; value = 3.14159
    }
    @{
        name = 'test.series.2'; value = 3.14159
    }
) -IntervalInSeconds 10 -Timestamp $timestamp
Write-Host "Will send the following metrics to Graphite: $graphiteMetrics"
```

## PARAMETERS

### -Metrics
Specifies the metrics name/value pair to send.

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
Specifies the resolution of the metric in seconds.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[Get-GraphiteTimestamp](Get-GraphiteTimestamp.md)

[https://grafana.com/docs/grafana-cloud/data-configuration/metrics/metrics-graphite/http-api/#adding-new-data-posting-to-metrics](https://grafana.com/docs/grafana-cloud/data-configuration/metrics/metrics-graphite/http-api/#adding-new-data-posting-to-metrics)


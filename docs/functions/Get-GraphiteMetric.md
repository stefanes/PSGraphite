# Get-GraphiteMetric

## SYNOPSIS
Get Graphite metrics data to send.

## SYNTAX

```
Get-GraphiteMetric [-Metrics] <Hashtable[]> [[-Name] <String>] [-ToLower] [[-IntervalInSeconds] <Int32>]
 [[-Timestamp] <String>] [[-Tags] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Calling this function will return metrics data for sending to Graphite, given the provided metric points.

Notes:
    - Metrics input must be provided in the format '@( @{...}, @{...} )'.
    - The metric points *must* include a 'value' property
    - Tags, provided through the '-Tags' parameter, are appended to all metric points.
    - For all other properties the parameter value is used if value it missing from input.

## EXAMPLES

### EXAMPLE 1
```
$graphiteMetrics = Get-GraphiteMetric -Metrics @{
    name = 'test.series.0'; value = '3.14159'; tags = 'tag1=value1'
} -IntervalInSeconds 10 -Timestamp $timestamp
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
        value = '3.14159'
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
Specifies the metric points to send.

```yaml
Type: Hashtable[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
Specifies the name of the metrics, unless provided in metric point.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ToLower
Switch to convert the name of the metrics to lowercase.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IntervalInSeconds
Specifies the resolution of the metrics in seconds, unless provided in metric point.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: Interval

Required: False
Position: 3
Default value: 10
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Timestamp
Specifies the timestamp of the metrics, converted to Unix Epoch if needed, unless provided in metric point.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Tags
Specifies tags, in the format 'tag=value', to add to all metric points.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: @()
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


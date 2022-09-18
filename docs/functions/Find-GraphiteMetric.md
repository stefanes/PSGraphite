# Find-GraphiteMetric

## SYNOPSIS
Find available Graphite metrics.

## SYNTAX

```
Find-GraphiteMetric [-URI <Uri>] [-Metric <String>] [-From <String>] [-To <String>] [-ContentType <String>]
 [-AccessToken <String>] [<CommonParameters>]
```

## DESCRIPTION
Calling this function will return true or false depending on the availablity of a metric.

## EXAMPLES

### EXAMPLE 1
```
Get-GraphiteTimestamp
```

## PARAMETERS

### -URI
Specifies the URI for the request.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases: URL

Required: False
Position: Named
Default value: Https://graphite-us-central1.grafana.net/graphite/metrics/find
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Metric
Specifies the metric to find.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -From
Specifies the Epoch timestamp from which to consider metrics.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -To
Specifies the Epoch timestamp until which to consider metrics.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ContentType
Specifies the content type of the request.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Application/json
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AccessToken
Specifies the access token to use for the communication.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Token

Required: False
Position: Named
Default value: $(
            if ($script:GraphiteAccessTokenCache) {
                $script:GraphiteAccessTokenCache
            }
            elseif ($env:GRAPHITE_ACCESS_TOKEN) {
                $env:GRAPHITE_ACCESS_TOKEN
            }
        )
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Boolean
## NOTES

## RELATED LINKS

[https://grafana.com/docs/grafana-cloud/data-configuration/metrics/metrics-graphite/http-api/#http-api](https://grafana.com/docs/grafana-cloud/data-configuration/metrics/metrics-graphite/http-api/#http-api)


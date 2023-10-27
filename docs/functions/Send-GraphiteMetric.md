# Send-GraphiteMetric

## SYNOPSIS
Send Graphite metrics to an HTTP endpoint.

## SYNTAX

```
Send-GraphiteMetric [-URI <Uri>] [-Metrics <String>] [-AccessToken <String>] [-OutputToConsole] [-PassThru]
 [<CommonParameters>]
```

## DESCRIPTION
Calling this function will return data returned from the request.

## EXAMPLES

### EXAMPLE 1
```
$response = Send-GraphiteMetric -Metrics @"
[
    {
        "name": "test.series.1",
        "value": 3.14159,
        "interval": 10,
        "time": 1662562317
    },
    {
        "name": "test.series.2",
        "value": 3.14159,
        "interval": 10,
        "time": 1662562317
    }
]
"@
Write-Host "Metrics sent to Graphite [$($response.StatusCode) $($response.StatusDescription)]: $($response.Content | ConvertFrom-Json | Select-Object Invalid, Published)"
```

## PARAMETERS

### -URI
Specifies the URI for the request.
Override default using the GRAPHITE_ENDPOINT or GRAPHITE_HOST environment variables.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases: URL

Required: False
Position: Named
Default value: $(
            if ($env:GRAPHITE_ENDPOINT) {
                $env:GRAPHITE_ENDPOINT
            } elseif ($env:GRAPHITE_HOST) {
                "https://$env:GRAPHITE_HOST/graphite/metrics"
            } else {
                'https://graphite-blocks-prod-us-central1.grafana.net/graphite/metrics'
            }
        )
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Metrics
Specifies the metrics to send.

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

### -AccessToken
Specifies the access token to use for the communication.
Override default using the GRAPHITE_ACCESS_TOKEN environment variable.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Token

Required: False
Position: Named
Default value: $(
            if ($script:GraphiteAccessTokenCache) {
                $script:GraphiteAccessTokenCache
            } elseif ($env:GRAPHITE_ACCESS_TOKEN) {
                $env:GRAPHITE_ACCESS_TOKEN
            }
        )
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -OutputToConsole
Switch to output result to the console.

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

### -PassThru
Switch to still return the reponse even when the '-OutputToConsole' parameter is provided.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[Get-GraphiteMetric](Get-GraphiteMetric.md)

[https://grafana.com/docs/grafana-cloud/data-configuration/metrics/metrics-graphite/http-api/#http-api](https://grafana.com/docs/grafana-cloud/data-configuration/metrics/metrics-graphite/http-api/#http-api)


function Send-GraphiteMetric {
    <#
    .Synopsis
        Send Graphite metrics to an HTTP endpoint.
    .Description
        Calling this function will return data returned from the request.
    .Example
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
    .Link
        Get-GraphiteMetric
    .Link
        https://grafana.com/docs/grafana-cloud/data-configuration/metrics/metrics-graphite/http-api/#http-api
    #>
    [CmdletBinding(DefaultParameterSetName = 'URI')]
    param (
        # Specifies the URI for the request.
        # Override default using the GRAPHITE_HOST environment variable.
        [Parameter(ParameterSetName = 'URI', ValueFromPipelineByPropertyName)]
        [Alias('URL')]
        [Uri] $URI = $(
            if ($env:GRAPHITE_HOST) {
                "$env:GRAPHITE_HOST/metrics"
            }
            else {
                'https://graphite-us-central1.grafana.net/metrics'
            }
        ),

        # Specifies the metrics to send.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Metrics,

        # Specifies the access token to use for the communication.
        # Override default using the GRAPHITE_ACCESS_TOKEN environment variable.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Token')]
        [string] $AccessToken = $(
            if ($script:GraphiteAccessTokenCache) {
                $script:GraphiteAccessTokenCache
            }
            elseif ($env:GRAPHITE_ACCESS_TOKEN) {
                $env:GRAPHITE_ACCESS_TOKEN
            }
        )
    )

    begin {
        # Cache the access token (if provided)
        if ($AccessToken) {
            $script:GraphiteAccessTokenCache = $AccessToken
        }

        # Setup request headers
        $headers = @{
            'Content-Type'  = 'application/json'
            'Authorization' = "Bearer $AccessToken"
        }
    }

    process {
        # Setup parameters
        $splat = @{
            Method        = 'POST'
            Body          = $Metrics
            Headers       = $headers
            TimeoutSec    = 60
            ErrorVariable = 'err'
        }
        if ($PSVersionTable.PSVersion.Major -le 5) {
            # Additional parameters *not* supported from PowerShell version 6
            $splat += @{
                UseBasicParsing = $true
            }
        }
        $err = @( )

        # Make the request
        # Note: Using 'Invoke-WebRequest' to get the headers
        $eap = $ErrorActionPreference
        $ErrorActionPreference = 'SilentlyContinue'
        Write-Verbose -Message "Invoking web request: POST $URI"
        Write-Debug -Message "Graphite metrics: $($splat.Body)"
        $response = Invoke-WebRequest @splat -Uri $URI
        $ErrorActionPreference = $eap

        # Check for error
        if ($err) {
            $errorMessage = @"
Failed to invoke request to:
    POST $URI

Error message:
    $($err.Message)

Exception:
    $($err.InnerException.Message)
"@
            Write-Error -Message $errorMessage -Exception $err.InnerException -Category ConnectionError
            return
        }

        # Output response
        $response
    }
}

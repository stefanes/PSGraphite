﻿function Send-GraphiteMetric {
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
        # Override default using the GRAPHITE_ENDPOINT or GRAPHITE_HOST environment variables.
        [Parameter(ParameterSetName = 'URI', ValueFromPipelineByPropertyName)]
        [Alias('URL')]
        [Uri] $URI = $(
            if ($env:GRAPHITE_ENDPOINT) {
                $env:GRAPHITE_ENDPOINT
            } elseif ($env:GRAPHITE_HOST) {
                "https://$env:GRAPHITE_HOST/graphite/metrics" -replace '^https:\/\/http', 'http'
            } else {
                'https://graphite-blocks-prod-us-central1.grafana.net/graphite/metrics'
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
            } elseif ($env:GRAPHITE_ACCESS_TOKEN) {
                $env:GRAPHITE_ACCESS_TOKEN
            }
        ),

        # Switch to output result to the console.
        [switch] $OutputToConsole,

        # Switch to still return the reponse even when the '-OutputToConsole' parameter is provided.
        [switch] $PassThru
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

        # Output to console
        if ($OutputToConsole.IsPresent) {
            $columns = @(
                @{ label = 'Status'; expression = { "$($_.StatusCode) $($_.StatusDescription)" } }
                @{ label = 'Published'; expression = { "$(($_.Content | ConvertFrom-Json).Published)" } }
                @{ label = 'Invalid'; expression = { "$(($_.Content | ConvertFrom-Json).Invalid)" } }
            )
            $response | Select-Object $columns | ForEach-Object { $_ | Out-Host }
        }

        # Output response
        if (-Not $OutputToConsole.IsPresent -Or $PassThru.IsPresent) {
            $response
        }
    }
}

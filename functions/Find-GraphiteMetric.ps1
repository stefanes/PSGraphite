function Find-GraphiteMetric {
    <#
    .Synopsis
        Find available Graphite metrics.
    .Description
        Calling this function will return true or false depending on the availablity of a metric.
    .Example
        Get-GraphiteTimestamp
    .Link
        https://grafana.com/docs/grafana-cloud/data-configuration/metrics/metrics-graphite/http-api/#http-api
    #>
    [CmdletBinding(DefaultParameterSetName = 'URI')]
    [OutputType([bool])]
    param (
        # Specifies the URI for the request.
        # Override default using the GRAPHITE_HOST environment variable.
        [Parameter(ParameterSetName = 'URI', ValueFromPipelineByPropertyName)]
        [Alias('URL')]
        [Uri] $URI = $(
            if ($env:GRAPHITE_HOST) {
                "$env:GRAPHITE_HOST/find"
            } else {
                'https://graphite-blocks-prod-us-central1.grafana.net/graphite/metrics/find'
            }
        ),

        # Specifies the metric to find.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Metric,

        # Specifies the Epoch timestamp from which to consider metrics.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $From,

        # Specifies the Epoch timestamp until which to consider metrics.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $To,

        # Specifies the content type of the request.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $ContentType = 'application/json',

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
        )
    )

    begin {
        # Cache the access token (if provided)
        if ($AccessToken) {
            $script:GraphiteAccessTokenCache = $AccessToken
        }

        # Setup request headers
        $headers = @{
            'Content-Type'  = $ContentType
            'Authorization' = "Bearer $AccessToken"
        }
    }

    process {
        # Setup parameters
        $splat = @{
            Method        = 'GET'
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

        # Append query to the URI
        $URI = $URI.toString() + "?query=$Metric&from=$(Get-GraphiteTimestamp -Timestamp $From)&to=$(Get-GraphiteTimestamp -Timestamp $To)"

        # Make the request
        # Note: Using 'Invoke-WebRequest' to get the headers
        $eap = $ErrorActionPreference
        $ErrorActionPreference = 'SilentlyContinue'
        Write-Debug -Message "Invoking web request: GET $URI"
        $response = Invoke-WebRequest @splat -Uri $URI
        $responseContent = $response.Content | ConvertFrom-Json # Convert the response from JSON
        Write-Debug -Message "Response: $($response.StatusCode) $($response.StatusDescription)"
        Write-Debug -Message "Response content: $responseContent"
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

        # Check response
        if ($responseContent) {
            $true
        } else {
            $false
        }
    }
}

# PSGraphite

PowerShell module for publishing metrics to Graphite.

[![Latest version](https://img.shields.io/powershellgallery/v/PSGraphite?style=flat&color=blue&label=Latest%20version)](https://www.powershellgallery.com/packages/PSGraphite) [![Download count](https://img.shields.io/powershellgallery/dt/PSGraphite?style=flat&color=green&label=Download%20count)](https://www.powershellgallery.com/packages/PSGraphite)

> _:heavy_check_mark: See [CHANGELOG.md](CHANGELOG.md) for what's new!_

![Grafana](docs/resources/grafana.png)

> _:heavy_check_mark: See [here](https://github.com/stefanes/tibber-pulse) for an example of this module in action..._

## Installation

Using the [latest version of PowerShellGet](https://www.powershellgallery.com/packages/PowerShellGet):

```powershell
Install-Module -Name PSGraphite -Repository PSGallery -Scope CurrentUser -Force -PassThru
Import-Module -Name PSGraphite -Force -PassThru
```

Or if you already have the module installed, update to the latest version:

```powershell
Update-Module -Name PSGraphite
Import-Module -Name PSGraphite -Force -PassThru
```

## Authentication

For use with e.g. Grafana Cloud you must have an account to access the API. Access tokens (_API Keys_) for Grafana can be generated at <https://grafana.com/orgs/[your-user-name]/api-keys>.

To authenticate, pass the generated access token using the [`-AccessToken`](docs/functions/Send-GraphiteMetric.md#-accesstoken) parameter with each call or set the `GRAPHITE_ACCESS_TOKEN` environment variable:

```powershell
$env:GRAPHITE_ACCESS_TOKEN = "<your access token>"
```

## Usage

Use `Get-Command -Module PSGraphite` for a list of functions provided by this module. See the help associated with each function using the `Get-Help` command, e.g. `Get-Help Get-GraphiteMetric -Detailed`, and the documentation available [in `docs`](docs/functions/) for more details:

- [`Get-GraphiteMetric`](docs/functions/Get-GraphiteMetric.md)
- [`Get-GraphiteTimestamp`](docs/functions/Get-GraphiteTimestamp.md)
- [`Send-GraphiteMetric`](docs/functions/Send-GraphiteMetric.md)

### Examples

#### Get Unix Epoch for current date/time

```powershell
$timestamp = Get-GraphiteTimestamp
Write-Host "Current Unix Epoch is: $timestamp"
```

#### Get Graphite metrics data

```powershell
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

#### Send metrics to Graphite

```powershell
$response = Send-GraphiteMetric -URI "https://graphite-blocks-prod-us-central1.grafana.net/graphite" -Metrics $graphiteMetrics
Write-Host "Metrics sent to Graphite [$($response.StatusCode) $($response.StatusDescription)]: $($response.Content | ConvertFrom-Json | Select Invalid, Published)"
```

The endpoint URL can also be specified by setting the `GRAPHITE_ENDPOINT` or `GRAPHITE_HOST` environment variables.

### Debugging

To view the actual Graphite metrics sent in the requests, add the `-Debug` switch to the command.

Example:

```powershell
PS> Send-GraphiteMetric -Metrics $graphiteMetrics -Debug
DEBUG: Invoking web request: POST https://graphite-blocks-prod-us-central1.grafana.net/graphite
DEBUG: Graphite metrics: [
  {
    "name": "test.series.1",
    "value": 3.14159,
    "interval": 10,
    "time": 1662578870
  },
  {
    "name": "test.series.2",
    "value": 3.14159,
    "interval": 10,
    "time": 1662578870
  }
]
```

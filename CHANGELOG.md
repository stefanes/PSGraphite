# Changelog

## Version 0.1.5

* Override default using the `GRAPHITE_HOST` environment variable in [`Send-GraphiteMetric`](docs/functions/Send-GraphiteMetric.md) and [`Find-GraphiteMetric`](docs/functions/Find-GraphiteMetric.md).

## Version 0.1.4

* :new: Support for finding metrics published to Graphite with [`Find-GraphiteMetric`](docs/functions/Find-GraphiteMetric.md).

## Version 0.1.3

* Fixed release notes link in [PowerShell Gallery](https://www.powershellgallery.com/packages/PSGraphite).

## Version 0.1.2

* Allow '0' value metrics in [`Get-GraphiteMetric`](docs/functions/Get-GraphiteMetric.md).

## Version 0.1.1

* Added support for tags in [`Get-GraphiteMetric`](docs/functions/Get-GraphiteMetric.md).

## Version 0.1.0

* Initial version, see [README.md](README.md#usage) for how to use this module.
* :new: Functions for publishing metrics to Graphite:
  * [`Get-GraphiteTimestamp`](docs/functions/Get-GraphiteTimestamp.md)
  * [`Get-GraphiteMetric`](docs/functions/Get-GraphiteMetric.md)
  * [`Send-GraphiteMetric`](docs/functions/Send-GraphiteMetric.md)

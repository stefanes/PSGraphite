[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
param()

$global:pester_URI = 'https://graphite-us-central1.grafana.net/metrics'

Describe "Get-GraphiteTimestamp" {
    It "Can get new Graphite timestamp (Unix Epoch)" {
        $global:timestamp = Get-GraphiteTimestamp
        $timestamp | Should -Not -Be $null
    }

    It "Can get Unix Epoch from date" {
        Get-GraphiteTimestamp -Timestamp '2022-09-07T14:51:57Z' | Should -Be '1662562317'
    }

    It "Can get Unix Epoch back" {
        Get-GraphiteTimestamp -Timestamp '1662562317' | Should -Be '1662562317'
    }
}

Describe "Get-GraphiteMetric" {
    #region Metrics
    $singleGraphiteMetric = Get-GraphiteMetric -Metrics @{
        name = 'test.series.0'; value = '3.14'
    } -Interval 10 -Timestamp $timestamp

    $graphiteMetricWithTag = Get-GraphiteMetric -Metrics @{
        name = 'test.series.0'; value = '3.14'
    } -Interval 10 -Timestamp $timestamp -Tag 'tag=value' | ConvertFrom-Json

    $graphiteMetrics = Get-GraphiteMetric -Metrics @(
        @{
            name = 'test.series.1'; value = '3.14159'
        }
        @{
            name = 'test.series.2'; value = '3'
        }
    ) -Interval 10 -Timestamp $timestamp

    $graphiteMetricsWithTags = Get-GraphiteMetric -Metrics @(
        @{
            name = 'test.series.1'; value = '3.14159'
        }
        @{
            name = 'test.series.2'; value = '3'
        }
    ) -Interval 10 -Timestamp $timestamp -Tag 'tag1=value1', 'tag2=value2' | ConvertFrom-Json
    #endregion

    It "Can get Graphite metric" {
        Get-GraphiteMetric -Metrics @(
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
        ) -Interval 10 -Timestamp $timestamp -Tag 'tag1=value1', 'tag2=value2' | Should -Not -Be $null
    }

    It "Format of singel Graphite metric (root)" {
        $singleGraphiteMetric.StartsWith('[') | Should -Be $true
    }

    It "Format of singel Graphite metric (no tags)" {
        $($singleGraphiteMetric | ConvertFrom-Json).tags | Should -Be $null
    }

    It "Format of singel Graphite metric (interval)" {
        ($graphiteMetricWithTag.interval.GetType()).Name | Should -Be 'Int64'
    }

    It "Format of singel Graphite metric (value)" {
        ($graphiteMetricWithTag.value.GetType()).Name | Should -Be 'Double'
    }

    It "Format of singel Graphite metric (time)" {
        ($graphiteMetricWithTag.time.GetType()).Name | Should -Be 'Int64'
    }

    It "Format of singe Graphite metric tag" {
        ($graphiteMetricWithTag.tags.GetType()).Name | Should -Be 'Object[]'
    }

    It "Format of multiple Graphite metrics" {
        $graphiteMetrics.StartsWith('[') | Should -Be $true
    }

    It "Format of multiple Graphite metric tags" {
        ($graphiteMetricsWithTags.tags.GetType()).Name | Should -Be 'Object[]'
    }
}

Describe "Send-GraphiteMetric" {
    #region Metrics
    $singleGraphiteMetric = Get-GraphiteMetric -Metrics @{
        name = 'test.series.0'; value = '3.14'
    } -Interval 10

    $graphiteMetrics = Get-GraphiteMetric -Metrics @(
        @{
            name = 'test.series.1'; value = '3.14159'
        }
        @{
            name = 'test.series.2'; value = '3'
        }
    ) -Interval 10 -Tag 'tag1=value1', 'tag2=value2' | ConvertFrom-Json
    #endregion

    It "Can send single Graphite metric" {
        if ($env:GRAPHITE_ACCESS_TOKEN) {
            $response = Send-GraphiteMetric -Metrics $singleGraphiteMetric
        }
        else {
            Write-Warning "Environment variable '`$env:GRAPHITE_ACCESS_TOKEN' not set..."
        }
        $response | Should -Not -Be $null
    }

    It "Can send multiple Graphite metrics" {
        if ($env:GRAPHITE_ACCESS_TOKEN) {
            $response = Send-GraphiteMetric -Metrics $graphiteMetrics
        }
        else {
            Write-Warning "Environment variable '`$env:GRAPHITE_ACCESS_TOKEN' not set..."
        }
        $response | Should -Not -Be $null
    }

    It "Fails with invalid metrics" {
        { Send-GraphiteMetric -Metrics @"
[
    {
        "name": "test.series.0",
        "value": "3.14",
        "interval": 10,
        "time": 1662562317
    }
]
"@
        } | Should -Throw
    }

    It "Fails when invalid URI" {
        { Invoke-TibberQuery -URI $($Pester_URI -replace '.net', '.com') -Query "{}" } | Should -Throw
    }
}

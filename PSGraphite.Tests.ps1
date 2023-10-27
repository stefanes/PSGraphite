[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param()

BeforeAll {
    $GraphiteURI = 'https://graphite-blocks-prod-us-central1.grafana.net/graphite'
}

Describe "Get-GraphiteTimestamp" {
    It "Can get new Graphite timestamp (Unix Epoch)" {
        Get-GraphiteTimestamp | Should -Not -Be $null
    }

    It "Can get Unix Epoch from date string" {
        Get-GraphiteTimestamp -Timestamp '2022-09-07T14:51:57Z' | Should -Be '1662562317'
    }

    It "Can get Unix Epoch from date string adding seconds" {
        Get-GraphiteTimestamp -Timestamp '2022-09-07T14:51:57Z' -AddSeconds 100 | Should -Be '1662562417'
    }

    It "Can get Unix Epoch from date" {
        Get-GraphiteTimestamp -Date $([DateTime]::Parse('2022-09-07T14:51:57Z')) | Should -Be '1662562317'
    }

    It "Can get Unix Epoch back" {
        Get-GraphiteTimestamp -Timestamp '1662562317' | Should -Be '1662562317'
    }
}

Describe "Get-GraphiteMetric" {
    BeforeAll {
        $metricsSingle = Get-GraphiteMetric -Metrics @{
            name = 'test.series.0'; value = '3.14159'
        } -IntervalInSeconds 10 -Timestamp '1662562317'

        $metricsSingleWithTag = Get-GraphiteMetric -Metrics @{
            name = 'test.series.0'; value = '3.14159'
        } -IntervalInSeconds 10 -Timestamp '1662562317' -Tag 'tag=value'

        $metricsMultiWithTags = Get-GraphiteMetric -Metrics @(
            @{
                name = 'test.series.1'; value = '3.14159'
            }
            @{
                name = 'test.series.2'; value = '3.14159'
            }
        ) -IntervalInSeconds 10 -Timestamp '1662562317' -Tag 'tag1=value1', 'tag2=value2'
    }

    It "Can get Graphite metric" {
        Get-GraphiteMetric -Metrics @(
            @{
                name = 'test.series.1'; value = '3.14159'
            }
            @{
                value = '3.14159'; time = '1662562317'
            }
            @{
                name  = 'test.series.2'
                value = '3.14159'
                tags  = @(
                    'tag3=value3'
                    'tag4=value4'
                )
            }
        ) -Name 'test.series.0' -IntervalInSeconds 10 -Tag 'tag1=value1', 'tag2=value2' -ToLower | Should -Not -Be $null
    }

    It "Fail to get metric with missing name" {
        { Get-GraphiteMetric -Metrics @(
                @{
                    value    = '3.14159'
                    interval = 10
                    time     = 1662562317
                }
            ) } | Should -Throw
    }

    It "Fail to get metric with empty name" {
        { Get-GraphiteMetric -Metrics @(
                @{
                    name     = ''
                    value    = '3.14159'
                    interval = 10
                    time     = 1662562317
                }
            ) } | Should -Throw
    }

    It "Format of Single Graphite metric (root)" {
        $metricsSingle.StartsWith('[') | Should -Be $true
    }

    It "Format of multiple Graphite metrics (root)" {
        $metricsMultiWithTags.StartsWith('[') | Should -Be $true
    }

    It "Format of Single Graphite metric (no tags)" {
        $($metricsSingle | ConvertFrom-Json).tags | Should -Be $null
    }

    It "Format of Single Graphite metric (interval)" {
        (($metricsSingleWithTag | ConvertFrom-Json).interval.GetType()).Name | Should -Be 'Int64'
    }

    It "Format of Single Graphite metric (value)" {
        (($metricsSingleWithTag | ConvertFrom-Json).value.GetType()).Name | Should -Be 'Double'
    }

    It "Format of Single Graphite metric (time)" {
        (($metricsSingleWithTag | ConvertFrom-Json).time.GetType()).Name | Should -Be 'Int64'
    }

    It "Format of singe Graphite metric tag" {
        (($metricsSingleWithTag | ConvertFrom-Json).tags.GetType()).Name | Should -Be 'Object[]'
    }

    It "Format of multiple Graphite metric tags" {
        (($metricsMultiWithTags | ConvertFrom-Json).tags.GetType()).Name | Should -Be 'Object[]'
    }
}

Describe "Send-GraphiteMetric" {
    BeforeAll {
        $sendMetricsSingle = Get-GraphiteMetric -Metrics @{
            name = 'test.series.0'; value = '3.14159'
        } -IntervalInSeconds 10

        $sendMetricsMulti = Get-GraphiteMetric -Metrics @(
            @{
                name = 'test.series.1'; value = '3.14159'
            }
            @{
                name = 'test.series.2'; value = '3.14159'
            }
        ) -IntervalInSeconds 10 -Tag 'tag1=value1', 'tag2=value2'
    }

    It "Can send single Graphite metric" {
        if ($env:GRAPHITE_ACCESS_TOKEN) {
            $response = Send-GraphiteMetric -Metrics $sendMetricsSingle
        } else {
            Write-Warning "Environment variable '`$env:GRAPHITE_ACCESS_TOKEN' not set..."
        }
        $response | Should -Not -Be $null
    }

    It "Can send single Graphite metric with output to console" {
        if ($env:GRAPHITE_ACCESS_TOKEN) {
            $response = Send-GraphiteMetric -Metrics $sendMetricsSingle -OutputToConsole -PassThru
        } else {
            Write-Warning "Environment variable '`$env:GRAPHITE_ACCESS_TOKEN' not set..."
        }
        $response | Should -Not -Be $null
    }

    It "Can send multiple Graphite metrics" {
        if ($env:GRAPHITE_ACCESS_TOKEN) {
            $response = Send-GraphiteMetric -Metrics $sendMetricsMulti
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
        "value": "3.14159",
        "interval": 10,
        "time": 1662562317
    }
]
"@
        } | Should -Throw
    }

    It "Fails when invalid URI" {
        { Send-GraphiteMetric -URI $($GraphiteURI -replace '.net', '.com') -Metrics "" } | Should -Throw
    }
}

Describe "Find-GraphiteMetric" {
    It "Can find Graphite metric" {
        if ($env:GRAPHITE_ACCESS_TOKEN) {
            Find-GraphiteMetric -Metric 'test.series.0' -From $([DateTime]::Now.AddHours(-1)) -To $([DateTime]::Now.AddHours(1)) | Should -Be $true
        }
        else {
            Write-Warning "Environment variable '`$env:GRAPHITE_ACCESS_TOKEN' not set..."
        }
    }

    It "Fails when invalid URI" {
        { Find-GraphiteMetric -URI $($GraphiteURI -replace '.net', '.com') } | Should -Throw
    }
}

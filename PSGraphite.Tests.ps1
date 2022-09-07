[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
param()

Describe "Get-GraphiteTimestamp" {
    It "Can get Graphite timestamp" {
        $global:timestamp = Get-GraphiteTimestamp
        $timestamp | Should -Not -Be $null
    }

    It "Can get Graphite timestamp from date" {
        Get-GraphiteTimestamp -Timestamp '2022-09-07T14:51:57Z' | Should -Be '1662562317'
    }

    It "Can get epoch back" {
        Get-GraphiteTimestamp -Timestamp '1662562317' | Should -Be '1662562317'
    }
}

Describe "Get-GraphiteMetrics" {
    It "Can get Graphite metrics" {
        $global:graphiteMetrics = Get-GraphiteMetric -Metrics @{
            name = 'test.series.1'; value = '3.14159'
        } -Interval 10 -Timestamp $timestamp
        $graphiteMetrics | Should -Not -Be $null
    }
}

Describe "Send-GraphiteMetric" {
    It "Can send Graphite metrics" {
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
        "name": "test.series.1",
        "value": "3.14159",
        "interval": 10,
        "time": $timestamp
    }
]
"@
        } | Should -Throw
    }
}

Function Invoke-RoutineChecks {
    <#
    .SYNOPSIS
        Executes the automated Routine Checks for one or more specified subscriptions.
    #>
    param(
        [string[]]
        $SubscriptionName
    )

    $TestPath = "$PSScriptRoot\..\Private\RoutineChecks.ps1"

    $Container = New-PesterContainer -Path $TestPath -Data @{ 
        SubscriptionName = $SubscriptionName 
    }

    $Config = New-PesterConfiguration 
    $Config.Output.StackTraceVerbosity = 'None'
    $Config.Output.Verbosity = 'Detailed'
    $Config.Run.Container = $Container

    Invoke-Pester -Configuration $Config
}

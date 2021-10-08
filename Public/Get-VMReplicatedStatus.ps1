function Get-VMReplicatedStatus {
    <#
    .SYNOPSIS
        Retrieve VM replicated status for all VMs.
    #>
    [CmdletBinding()]
    param (
        [string]
        $SubscriptionName
    )

    $Subscriptions = if ($SubscriptionName) {
        (Get-AzSubscription -SubscriptionName $SubscriptionName).Name
    }
    else {
        (Get-AzSubscription).Name
    }

    foreach ($Subscription in $Subscriptions) {

        Select-AzSubscription -SubscriptionName $Subscription | Out-Null

        $VMs = Get-AzVM
        $Vaults = Get-AzRecoveryServicesVault
        
        foreach ($Vault in $Vaults) {

            Set-AzRecoveryServicesAsrVaultContext -Vault $Vault | Out-Null

            $Fabrics = Get-AzRecoveryServicesAsrFabric
    
            if ($Fabrics) {

                $Items = foreach ($Fabric in $Fabrics) {

                    $Container = Get-AzRecoveryServicesAsrProtectionContainer -Fabric $Fabric
                    Get-AzRecoveryServicesAsrReplicationProtectedItem -ProtectionContainer $Container
                }

                foreach ($VM in $VMs) {

                    $Item = $Items | Where-Object { $_.FriendlyName -eq $VM.Name }

                    [PSCustomObject]@{
                        Subscription      = $Subscription
                        ResourceGroupName = $VM.ResourceGroupName
                        Name              = $VM.Name
                        Location          = $VM.Location
                        RecoveryVaultName = if ($item) { $Vault.Name } else { $null }
                        ReplicationStatus = $Item.ProtectionState
                        ReplicationHealth = $Item.ReplicationHealth
                    }
                }
            }
        } 
    }
}
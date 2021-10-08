Param(
    $SubscriptionName
)

Describe 'RoutineChecks' {
    
    BeforeAll { }

    ForEach ($Subscription in $SubscriptionName) {

        $Sub = Get-AzSubscription -SubscriptionName $Subscription | Select-AzSubscription
     
        Context "$SubscriptionName API Management Certificate Checks" {
            
            $APIMCerts = Get-APIManagementExpiringCertificate -SubscriptionName $Sub.Subscription.Name -ExpiresInDays 365
            
            $TestCases = foreach ($APIMCert in $APIMCerts) {
                @{ 
                    Name              = $APIMCert.Name
                    ResourceGroupName = $APIMCert.ResourceGroupName
                    Subject           = $APIMCert.Subject
                    ValidDays         = $APIMCert.ValidDays
                }
            }

            It "<ResourceGroupName> <Name> <Subject> validity > 45 days" -TestCases $TestCases {
                $_.ValidDays | Should -BeGreaterThan 45
            }
        }

        Context "$SubscriptionName App Gateway Certificate Checks" {
            
            $AppGwCerts = Get-AppGatewayExpiringCertificate -SubscriptionName $Sub.Subscription.Name -ExpiresInDays 365
            
            $TestCases = foreach ($AppGwCert in $AppGwCerts) {
                @{ 
                    Name              = $AppGwCert.Name
                    ResourceGroupName = $AppGwCert.ResourceGroupName
                    CertificateName   = $AppGwCert.CertificateName
                    ValidDays         = $AppGwCert.ValidDays
                }
            }

            It "<ResourceGroupName> <Name> <CertificateName> validity > 45 days" -TestCases $TestCases {
                $_.ValidDays | Should -BeGreaterThan 45
            }
        }

        Context "$SubscriptionName App Service Certificate Checks" {
            
            $AppServCerts = Get-AppServiceCertificate -SubscriptionName $Sub.Subscription.Name -ExpiresInDays 365
            
            $TestCases = foreach ($AppServCert in $AppServCerts) {
                @{ 
                    Name              = $AppServCert.Name
                    ResourceGroupName = $AppServCert.ResourceGroupName
                    Subject           = $AppServCert.Subject
                    ValidDays         = $AppServCert.ValidDays
                }
            }

            It "<ResourceGroupName> <Name> <Subject> validity > 45 days" -TestCases $TestCases {
                $_.ValidDays | Should -BeGreaterThan 45
            }
        }

        Context "$SubscriptionName Disk Encryption Checks" {
            
            $Disks = Get-DiskEncryptionStatus -SubscriptionName $Sub.Subscription.Name
            
            $TestCases = foreach ($Disk in $Disks) {
                @{ 
                    Name              = $Disk.Name
                    ResourceGroupName = $Disk.ResourceGroupName
                    EncryptionEnabled = $Disk.EncryptionEnabled
                }
            }

            It "<ResourceGroupName> <Name> disk encryption enabled" -TestCases $TestCases {
                $_.EncryptionEnabled | Should -BeTrue
            }
        }

        Context "$SubscriptionName VM Backup Checks" {
            
            $VMs = Get-VMBackupStatus -SubscriptionName $Sub.Subscription.Name
            
            $TestCases = foreach ($VM in $VMs) {
                @{ 
                    Name                      = $VM.Name
                    ResourceGroupName         = $VM.ResourceGroupName
                    BackedUp                  = $VM.BackedUp
                    BackupHealthStatus        = $VM.BackupHealthStatus
                    BackupProtectionStatus    = $VM.BackupProtectionStatus
                    LastBackupStatus          = $VM.LastBackupStatus
                    LastBackupTime            = $VM.LastBackupTime
                    BackupDeleteState         = $VM.BackupDeleteState
                    BackupLatestRecoveryPoint = $VM.BackupLatestRecoveryPoint
                }
            }

            It "<ResourceGroupName> <Name> VM backed up" -TestCases $TestCases {
                $_.BackedUp | Should -BeTrue
            }
        }

        Context "$SubscriptionName VM Disk Encryption Checks" {
            
            $VMDisks = Get-VMDiskEncryptionStatus -SubscriptionName $Sub.Subscription.Name
            
            $TestCases = foreach ($VMDisk in $VMDisks) {
                @{ 
                    Name                 = $VMDisk.Name
                    ResourceGroupName    = $VMDisk.ResourceGroupName
                    OSVolumeEncrypted    = $VMDisk.OSVolumeEncrypted
                    DataVolumesEncrypted = $VMDisk.DataVolumesEncrypted
                }
            }

            It "<ResourceGroupName> <Name> VM OS disk encrypted" -TestCases $TestCases {
                $_.OSVolumeEncrypted | Should -BeTrue
            }
            It "<ResourceGroupName> <Name> VM Data disks encrypted" -TestCases $TestCases {
                $_.DataVolumesEncrypted | Should -BeTrue
            }
        }

        Context "$SubscriptionName VM Replicated Checks" {
            
            $VMRSs = Get-VMReplicatedStatus -SubscriptionName $Sub.Subscription.Name
            
            $TestCases = foreach ($VMRS in $VMRSs) {

                if ($VMRS.RecoveryVaultName) {
                    @{ 
                        Name              = $VMRS.Name
                        ResourceGroupName = $VMRS.ResourceGroupName
                        ReplicationStatus = $VMRS.ReplicationStatus
                        ReplicationHealth = $VMRS.ReplicationHealth
                    }
                }
            }

            It "<ResourceGroupName> <Name> VM replicated" -TestCases $TestCases {
                $_.ReplicationStatus | Should -Be 'Protected'
            }
            It "<ResourceGroupName> <Name> VM replication healthy" -TestCases $TestCases {
                $_.ReplicationHealth | Should -Be 'Normal'
            }
        }
    }
}
$AssessmentTypes = @('AzureSqlManagedInstance',
					 'AzureSqlDatabase',
					 'AzureSqlVirtualMachine')
					 
$OutputLocation = "C:\REPORTS\Data"

# Declare arrays
foreach  ($AssessmentType in $AssessmentTypes) {
	New-Variable -Name $AssessmentType -Value @()
}

$Folders = Get-ChildItem $OutputLocation
ForEach ($Path in $Folders.Fullname) {
	ForEach ($AssessmentType in $AssessmentTypes) {
		$Files = Get-ChildItem $($Path)*$($AssessmentType).json
		ForEach ($File in $Files) {
			$JsonData = Get-Content $File | ConvertFrom-Json
			Write-Host "Working on file $File"
			
			ForEach ($SQLServer in $JsonData.Servers) {
				
				#Azure SQL Server
				if ($SQLServer.TargetPlatform -eq "AzureSqlDatabase") {
					
					ForEach ($DBLevelRequirement in $SQLServer.Requirements.DatabaseLevelRequirements) {
						$data = New-Object PSObject -property @{}
						$data | Add-Member -NotePropertyName "ServerName" -NotePropertyValue $SQLServer.ServerName
						$data | Add-Member -NotePropertyName "TargetPlatform" -NotePropertyValue $SQLServer.TargetPlatform
								
						$data | Add-Member -NotePropertyName "DatabaseName" -NotePropertyValue $DBLevelRequirement.DatabaseName
						$data | Add-Member -NotePropertyName "CpuRequirementInCores" -NotePropertyValue $DBLevelRequirement.CpuRequirementInCores
						$data | Add-Member -NotePropertyName "DataIOPSRequirement" -NotePropertyValue $DBLevelRequirement.DataIOPSRequirement
						$data | Add-Member -NotePropertyName "LogIOPSRequirement" -NotePropertyValue $DBLevelRequirement.LogIOPSRequirement
						$data | Add-Member -NotePropertyName "IOLatencyRequirementInMs" -NotePropertyValue $DBLevelRequirement.IOLatencyRequirementInMs
						$data | Add-Member -NotePropertyName "IOThroughputRequirementInMBps" -NotePropertyValue $DBLevelRequirement.IOThroughputRequirementInMBps
						$data | Add-Member -NotePropertyName "DataFileIOThroughputRequirementInMBps" -NotePropertyValue $DBLevelRequirement.DataFileIOThroughputRequirementInMBps
						$data | Add-Member -NotePropertyName "LogFileIOThroughputRequirementInMBps" -NotePropertyValue $DBLevelRequirement.LogFileIOThroughputRequirementInMBps
						$data | Add-Member -NotePropertyName "LogWriteRateInMBPerSecRequirement" -NotePropertyValue $DBLevelRequirement.LogWriteRateInMBPerSecRequirement
						$data | Add-Member -NotePropertyName "DataStorageRequirementInMB" -NotePropertyValue $DBLevelRequirement.DataStorageRequirementInMB
						$data | Add-Member -NotePropertyName "LogStorageRequirementInMB" -NotePropertyValue $DBLevelRequirement.LogStorageRequirementInMB
						$data | Add-Member -NotePropertyName "MemoryRequirementInMB" -NotePropertyValue $DBLevelRequirement.MemoryRequirementInMB
						$data | Add-Member -NotePropertyName "CpuRequirementInPercentageOfTotalInstance" -NotePropertyValue $DBLevelRequirement.CpuRequirementInPercentageOfTotalInstance
						#$data | Add-Member -NotePropertyName "FileLevelRequirements" -NotePropertyValue $DBLevelRequirement.FileLevelRequirements
						$data | Add-Member -NotePropertyName "NumberOfDataPointsAnalyzed" -NotePropertyValue $DBLevelRequirement.NumberOfDataPointsAnalyzed
						
						$Index = $SQLServer.Recommendations.DatabaseName.IndexOf($DBLevelRequirement.DatabaseName)					
						$data | Add-Member -NotePropertyName "RecommendedSku.Platform" -NotePropertyValue $SQLServer.Recommendations[$Index].RecommendedSku.Platform
						$data | Add-Member -NotePropertyName "RecommendedSku.ServiceTier" -NotePropertyValue $SQLServer.Recommendations[$Index].RecommendedSku.ServiceTier
						$data | Add-Member -NotePropertyName "RecommendedSku.SizeInVCores" -NotePropertyValue $SQLServer.Recommendations[$Index].RecommendedSku.SizeInVCores
						$data | Add-Member -NotePropertyName "RecommendedSku.StorageSizeInGb" -NotePropertyValue $SQLServer.Recommendations[$Index].RecommendedSku.StorageSizeInGb
						
						$Justifications = ($SQLServer.Recommendations[$Index].Justifications) -join "`r`n"
						$data | Add-Member -NotePropertyName "RecommendedSku.Justifications" -NotePropertyValue $Justifications
						
						$AzureSqlDatabase +=$data
					}
				}
				#Managed Instance
				if ($SQLServer.TargetPlatform -eq "AzureSqlManagedInstance") {

					$data = New-Object PSObject -property @{}
					$data | Add-Member -NotePropertyName "ServerName" -NotePropertyValue $SQLServer.ServerName
					$data | Add-Member -NotePropertyName "TargetPlatform" -NotePropertyValue $SQLServer.TargetPlatform
					
					$data | Add-Member -NotePropertyName "Requirements.CpuRequirementInCores" -NotePropertyValue $SQLServer.Requirements.CpuRequirementInCores
					$data | Add-Member -NotePropertyName "Requirements.DataStorageRequirementInMB" -NotePropertyValue $SQLServer.Requirements.DataStorageRequirementInMB
					$data | Add-Member -NotePropertyName "Requirements.LogStorageRequirementInMB" -NotePropertyValue $SQLServer.Requirements.LogStorageRequirementInMB
					$data | Add-Member -NotePropertyName "Requirements.MemoryRequirementInMB" -NotePropertyValue $SQLServer.Requirements.MemoryRequirementInMB
					$data | Add-Member -NotePropertyName "Requirements.DataIOPSRequirement" -NotePropertyValue $SQLServer.Requirements.DataIOPSRequirement
					$data | Add-Member -NotePropertyName "Requirements.LogIOPSRequirement" -NotePropertyValue $SQLServer.Requirements.LogIOPSRequirement
					$data | Add-Member -NotePropertyName "Requirements.IOLatencyRequirementInMs" -NotePropertyValue $SQLServer.Requirements.IOLatencyRequirementInMs 
					$data | Add-Member -NotePropertyName "Requirements.IOThroughputRequirementInMBps" -NotePropertyValue $SQLServer.Requirements.IOThroughputRequirementInMBps
					$data | Add-Member -NotePropertyName "Requirements.DataIOThroughputRequirementInMBps" -NotePropertyValue $SQLServer.Requirements.DataIOThroughputRequirementInMBps
					$data | Add-Member -NotePropertyName "Requirements.LogIOThroughputRequirementInMBps" -NotePropertyValue $SQLServer.Requirements.LogIOThroughputRequirementInMBps
					$data | Add-Member -NotePropertyName "Requirements.TempDBSizeInMB" -NotePropertyValue $SQLServer.Requirements.TempDBSizeInMB
					
					$data | Add-Member -NotePropertyName "RecommendedSku.Platform" -NotePropertyValue $SQLServer.Recommendations.RecommendedSku.Platform
					$data | Add-Member -NotePropertyName "RecommendedSku.HardwareGeneration" -NotePropertyValue $SQLServer.Recommendations.RecommendedSku.HardwareGeneration
					$data | Add-Member -NotePropertyName "RecommendedSku.ServiceTier" -NotePropertyValue $SQLServer.Recommendations.RecommendedSku.ServiceTier
					$data | Add-Member -NotePropertyName "RecommendedSku.SizeInVCores" -NotePropertyValue $SQLServer.Recommendations.RecommendedSku.SizeInVCores
					$data | Add-Member -NotePropertyName "RecommendedSku.StorageSizeInGb" -NotePropertyValue $SQLServer.Recommendations.RecommendedSku.StorageSizeInGb
					
					$Justifications = ($SQLServer.Recommendations.Justifications) -join "`r`n"
					$data | Add-Member -NotePropertyName "RecommendedSku.Justifications" -NotePropertyValue $Justifications
					
					$AzureSqlManagedInstance +=$data
				}
				
				if ($SQLServer.TargetPlatform -eq "AzureSqlVirtualMachine") {

					$data = New-Object PSObject -property @{}
					$data | Add-Member -NotePropertyName "ServerName" -NotePropertyValue $SQLServer.ServerName
					$data | Add-Member -NotePropertyName "TargetPlatform" -NotePropertyValue $SQLServer.TargetPlatform
					
					$data | Add-Member -NotePropertyName "Requirements.CpuRequirementInCores" -NotePropertyValue $SQLServer.Requirements.CpuRequirementInCores
					$data | Add-Member -NotePropertyName "Requirements.DataStorageRequirementInMB" -NotePropertyValue $SQLServer.Requirements.DataStorageRequirementInMB
					$data | Add-Member -NotePropertyName "Requirements.LogStorageRequirementInMB" -NotePropertyValue $SQLServer.Requirements.LogStorageRequirementInMB
					$data | Add-Member -NotePropertyName "Requirements.MemoryRequirementInMB" -NotePropertyValue $SQLServer.Requirements.MemoryRequirementInMB
					$data | Add-Member -NotePropertyName "Requirements.DataIOPSRequirement" -NotePropertyValue $SQLServer.Requirements.DataIOPSRequirement
					$data | Add-Member -NotePropertyName "Requirements.LogIOPSRequirement" -NotePropertyValue $SQLServer.Requirements.LogIOPSRequirement
					$data | Add-Member -NotePropertyName "Requirements.IOLatencyRequirementInMs" -NotePropertyValue $SQLServer.Requirements.IOLatencyRequirementInMs 
					$data | Add-Member -NotePropertyName "Requirements.IOThroughputRequirementInMBps" -NotePropertyValue $SQLServer.Requirements.IOThroughputRequirementInMBps
					$data | Add-Member -NotePropertyName "Requirements.DataIOThroughputRequirementInMBps" -NotePropertyValue $SQLServer.Requirements.DataIOThroughputRequirementInMBps
					$data | Add-Member -NotePropertyName "Requirements.LogIOThroughputRequirementInMBps" -NotePropertyValue $SQLServer.Requirements.LogIOThroughputRequirementInMBps
					$data | Add-Member -NotePropertyName "Requirements.TempDBSizeInMB" -NotePropertyValue $SQLServer.Requirements.TempDBSizeInMB
					
					$data | Add-Member -NotePropertyName "RecommendedSku.Platform" -NotePropertyValue $SQLServer.Recommendations.RecommendedSku.Platform
					$data | Add-Member -NotePropertyName "RecommendedSku.VirtualMachineFamily" -NotePropertyValue $SQLServer.Recommendations.RecommendedSku.VirtualMachineFamily
					$data | Add-Member -NotePropertyName "RecommendedSku.VirtualMachineSize" -NotePropertyValue $SQLServer.Recommendations.RecommendedSku.VirtualMachineSize
					$data | Add-Member -NotePropertyName "RecommendedSku.SizeInVCores" -NotePropertyValue $SQLServer.Recommendations.RecommendedSku.SizeInVCores

					$RecID=1
					ForEach ($DataDisk in $SQLServer.Recommendations.RecommendedSku.DataDisks) {
						$data | Add-Member -NotePropertyName "DataDisk.Type$RecID" -NotePropertyValue $DataDisk.Type
						$data | Add-Member -NotePropertyName "DataDisk.Size$RecID" -NotePropertyValue $DataDisk.Size
						$data | Add-Member -NotePropertyName "DataDisk.Caching$RecID" -NotePropertyValue $DataDisk.Caching
						$RecID++
					}
					
					$RecID=1
					ForEach ($LogDisk in $SQLServer.Recommendations.RecommendedSku.LogDisks) {
						$data | Add-Member -NotePropertyName "LogDisk.Type$RecID" -NotePropertyValue $LogDisk.Type
						$data | Add-Member -NotePropertyName "LogDisk.Size$RecID" -NotePropertyValue $LogDisk.Size
						$data | Add-Member -NotePropertyName "LogDisk.Caching$RecID" -NotePropertyValue $LogDisk.Caching
						$RecID++
					}
					
					$RecID=1
					ForEach ($TempDbDisk in $SQLServer.Recommendations.RecommendedSku.TempDbDisks) {
						$data | Add-Member -NotePropertyName "TempDbDisk.Type$RecID" -NotePropertyValue $TempDbDisk.Type
						$data | Add-Member -NotePropertyName "TempDbDisk.Size$RecID" -NotePropertyValue $TempDbDisk.Size
						$data | Add-Member -NotePropertyName "TempDbDisk.Caching$RecID" -NotePropertyValue $TempDbDisk.Caching
						$RecID++
					}
					
					$Justifications = ($SQLServer.Recommendations.Justifications) -join "`r`n"
					$data | Add-Member -NotePropertyName "RecommendedSku.Justifications" -NotePropertyValue $Justifications
					
					$AzureSqlVirtualMachine +=$data
				}
			}
				
		}
	}
}
			
$Output=$AzureSqlDatabase | ForEach{$_.PSObject.Properties} | Select -Expand Name -Unique
$Output|Where{$_ -notin $AzureSqlDatabase[0].psobject.properties.name}|ForEach{Add-Member -InputObject $AzureSqlDatabase[0] -NotePropertyName $_ -NotePropertyValue $null}
$AzureSqlDatabase | Export-CSV -NoTypeInformation .\AzureSqlDatabase-SizingReportCombined.csv

$Output=$AzureSqlManagedInstance | ForEach{$_.PSObject.Properties} | Select -Expand Name -Unique
$Output|Where{$_ -notin $AzureSqlManagedInstance[0].psobject.properties.name}|ForEach{Add-Member -InputObject $AzureSqlManagedInstance[0] -NotePropertyName $_ -NotePropertyValue $null}
$AzureSqlManagedInstance | Export-CSV -NoTypeInformation .\AzureSqlManagedInstance-SizingReportCombined.csv

$AzureSqlVirtualMachine | Export-CSV -NoTypeInformation .\AzureSqlVirtualMachine-SizingReportCombined.csv

			
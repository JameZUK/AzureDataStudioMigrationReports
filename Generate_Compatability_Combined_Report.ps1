$SQLServers = @('<<MSSQL SERVER 1>>',
                '<<MSSQL SERVER 2>>',
                '<<MSSQL SERVER 3>>')

$AssessmentTypes = @('ManagedSqlServer',
					 'AzureSqlDatabase',
					 'SqlServerWindows2019',
					 'SqlServerWindows2022',
					 'SqlServerLinux2019')
					 
$OutputLocation = "C:\REPORTS\Data\"

$report = @()
$Folders = Get-ChildItem $OutputLocation
ForEach ($Path in $Folders.Fullname) {
	ForEach ($AssessmentType in $AssessmentTypes) {
		$Files = Get-ChildItem $($Path)*$($AssessmentType)Compatibility.json
		ForEach ($File in $Files) {
			$data = New-Object PSObject -property @{}
			$JsonData = Get-Content $File | ConvertFrom-Json
			Write-Host "Working on file $File"
			
			$data | Add-Member -NotePropertyName "InstanceName" -NotePropertyValue $JsonData.Name
			$data | Add-Member -NotePropertyName "SourcePlatform" -NotePropertyValue $JsonData.SourcePlatform
			$data | Add-Member -NotePropertyName "TargetPlatform" -NotePropertyValue $JsonData.TargetPlatform
			$data | Add-Member -NotePropertyName "DatabasesName" -NotePropertyValue $JsonData.Databases.Name
			$data | Add-Member -NotePropertyName "DBSizeMB" -NotePropertyValue $JsonData.Databases.SizeMB
			$data | Add-Member -NotePropertyName "DBServerVersion" -NotePropertyValue $JsonData.Databases.ServerVersion
			$data | Add-Member -NotePropertyName "DBServerEdition" -NotePropertyValue $JsonData.Databases.ServerEdition
			$data | Add-Member -NotePropertyName "CompatibilityLevel" -NotePropertyValue $JsonData.Databases.CompatibilityLevel
			$data | Add-Member -NotePropertyName "AssessmentStatus" -NotePropertyValue $JsonData.Databases.Status
			
			if ($JsonData.EvaluateCompatibilityIssues) {
				$RecID=1
				ForEach ($AssessmentRecommendation in $JsonData.Databases.AssessmentRecommendations | Sort -Descending -Property CompatibilityLevel | Sort -Descending -Unique -Property RuleId | sort Severity) {
					$data | Add-Member -NotePropertyName "CompatCategory$RecID" -NotePropertyValue $AssessmentRecommendation.Category
					$data | Add-Member -NotePropertyName "CompatSeverity$RecID" -NotePropertyValue $AssessmentRecommendation.Severity
					$data | Add-Member -NotePropertyName "CompatChangeCategory$RecID" -NotePropertyValue $AssessmentRecommendation.ChangeCategory
					$data | Add-Member -NotePropertyName "CompatTitle$RecID" -NotePropertyValue $AssessmentRecommendation.Title
					$data | Add-Member -NotePropertyName "CompatImpact$RecID" -NotePropertyValue $AssessmentRecommendation.Impact
					$data | Add-Member -NotePropertyName "CompatRecommendation$RecID" -NotePropertyValue $AssessmentRecommendation.Recommendation					
					$RecID++
				}
			
			if ($JsonData.EvaluateFeatureParity) {
				$RecID=1
				ForEach ($AssessmentRecommendation in $JsonData.ServerInstances.AssessmentRecommendations | Sort -Descending -Unique -Property RuleId | sort Severity) {
					$data | Add-Member -NotePropertyName "FeatureParityCategory$RecID" -NotePropertyValue $AssessmentRecommendation.Category
					$data | Add-Member -NotePropertyName "FeatureParitySeverity$RecID" -NotePropertyValue $AssessmentRecommendation.Severity
					$data | Add-Member -NotePropertyName "FeatureParityChangeCategory$RecID" -NotePropertyValue $AssessmentRecommendation.FeatureParityCategory
					$data | Add-Member -NotePropertyName "FeatureParityTitle$RecID" -NotePropertyValue $AssessmentRecommendation.Title
					$data | Add-Member -NotePropertyName "FeatureParityImpact$RecID" -NotePropertyValue $AssessmentRecommendation.Impact
					$data | Add-Member -NotePropertyName "FeatureParityRecommendation$RecID" -NotePropertyValue $AssessmentRecommendation.Recommendation					
					$RecID++
				}
			}
		$report +=$data
		}
	}
}
}			
$Output=$report | ForEach{$_.PSObject.Properties} | Select -Expand Name -Unique
$Output|Where{$_ -notin $report[0].psobject.properties.name}|ForEach{Add-Member -InputObject $report[0] -NotePropertyName $_ -NotePropertyValue $null}

$report | Export-CSV -NoTypeInformation .\CompatibilityReportCombined.csv
			
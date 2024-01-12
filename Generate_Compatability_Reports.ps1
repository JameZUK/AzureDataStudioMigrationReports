Install-Module SQLServer

# SqlServer2012
# SqlServer2014
# SqlServer2016
# SqlServerWindows2017
# SqlServerLinux2017
# SqlServerWindows2019
# SqlServerLinux2019
# SqlServerWindows2022
# SqlDataWarehouse
# AzureSqlDatabase
# ManagedSqlServer
# CosmosDB
# AzureMySqlDatabase

$SQLServers = @('<<MSSQL SERVER 1>>',
                '<<MSSQL SERVER 2>>',
                '<<MSSQL SERVER 3>>')

$AssessmentTypes = @('ManagedSqlServer',
					 'AzureSqlDatabase',
					 'SqlServerWindows2019',
					 'SqlServerWindows2022',
					 'SqlServerLinux2019')
					 
$DomainName = "<<DOMAIN NAME>>"
$OutputLocation = "C:\REPORTS\Data"

ForEach ($DBServerName in $SQLServers) {
	$DBServerNameFQ = "$DBServerName.$DomainName"
	$DBs = Get-SqlInstance -ServerInstance $DBServerNameFQ | Get-SqlDatabase
	
	ForEach ($DB in $DBs) {
		ForEach ($AssessmentType in $AssessmentTypes) {
			If ($AssessmentType -eq "AzureSqlDatabase" -or $AssessmentType -eq "ManagedSqlServer" -or $AssessmentType -eq "SqlServerLinux2017" -or $AssessmentType -eq "SqlServerLinux2019") {
				& "C:\Program Files\Microsoft Data Migration Assistant\DmaCmd.exe" /AssessmentName="$DBServerName" /AssessmentDatabases="Server=$DBServerNameFQ;Initial Catalog=$($DB.Name);Integrated Security=true" /AssessmentTargetPlatform="$AssessmentType" /AssessmentEvaluateCompatibilityIssues /AssessmentEvaluateFeatureParity /AssessmentOverwriteResult /AssessmentResultCsv="$OutputLocation\$DBServerName\$DBServerName-$($DB.Name)-$($AssessmentType)Compatibility.csv" /AssessmentResultJson="$OutputLocation\$DBServerName\$DBServerName-$($DB.Name)-$($AssessmentType)Compatibility.json"
			} else {
				& "C:\Program Files\Microsoft Data Migration Assistant\DmaCmd.exe" /AssessmentName="$DBServerName" /AssessmentDatabases="Server=$DBServerNameFQ;Initial Catalog=$($DB.Name);Integrated Security=true" /AssessmentTargetPlatform="$AssessmentType" /AssessmentEvaluateCompatibilityIssues /AssessmentOverwriteResult /AssessmentResultCsv="$OutputLocation\$DBServerName\$DBServerName-$($DB.Name)-$($AssessmentType)Compatibility.csv" /AssessmentResultJson="$OutputLocation\$DBServerName\$DBServerName-$($DB.Name)-$($AssessmentType)Compatibility.json"
			}
		}
	}
}
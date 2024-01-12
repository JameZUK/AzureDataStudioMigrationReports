# Azure Data Studio CSV Migration Reports  -Useful combined reports for right sizing and comatibility with Azure SQL, Managed SQL and SQL VM offerings
Some scripts to ease the creation of SQL Migration Reports with data generated from Azure Data Studio.
## How to gather and create combined Azure SQL, managed instance and SQL VM sizing reports
1. Install Azure Data Studio
2. Now collect stats for the databases. Using command line is best. Just create a batch file and add a new line as follows for each SQL Server. Note, each server output should be in its own folder. Note, I'm assuming you are using an account with DBOwner rights on these databases. See example:

`start /D "C:\Program Files\Microsoft Data Migration Assistant\SqlAssessmentConsole\" SqlAssessment.exe PerfDataCollection  --sqlConnectionStrings "Data Source=<<MSSQL SERVER NAME>>;Initial Catalog=master;Integrated Security=True;"  --outputFolder C:\REPORTS\Data\<<MSSQL SERVER NAME>>`

`start /D "C:\Program Files\Microsoft Data Migration Assistant\SqlAssessmentConsole\" SqlAssessment.exe PerfDataCollection  --sqlConnectionStrings "Data Source=<<MSSQL SERVER NAME1>>;Initial Catalog=master;Integrated Security=True;"  --outputFolder C:\REPORTS\Data\<<MSSQL SERVER NAME1>>`

3. Leave the data collection running for as long as possible, ideally for at least a week but usually it is best to cover a month so that business trends (Highs and lows) are captured to a sensible result.
4. Once you have finished capturing data update Generate_Sizing_Combined_Report.ps1. Note that the OuttutLocationm referrs to the parent location of the data written in the previous step I.E. C:\REPORTS\Data\
5. Now run the customised script and it will read all the json data in, combine it and output it in 3 nice easy to use CSV files. (One for AzureSqlManagedInstance, AzureSqlDatabase and AzureSqlVirtualMachine)
6. The data can then be used to determine sizings for all databases / database servers in Azure.

## How to gather and create combined Azure SQL compatibility reports
1. Update Generate_Compatability_Reports.ps1 with the MSSQL Servers, AssessmentTypes, domain name and output location.
2. Run Generate_Compatability_Reports.ps1 and the script will run all enabled assessments on all listed SQL servers. The data will be output in the OutputLocation path.
3. Now update Generate_Compatability_Combined_Report.ps1 with the MSSQL Servers, AssessmentTypes and OutputLocation. Note the OutputLocation refers to the output location used in the previous script as it uses it to locate the data generated. AssessmentType should be the same as the previous script too.
4. Run Generate_Compatability_Combined_Report.ps1 and the json files from the first script will be combined to 1 nice easy to use CSV file.

I'm aware that these scripts are a little rough around the edges but they did what I needed them to do and saved me from a huge amount of grunt work during a recent data migration I carried out. Feel free to make them better :)

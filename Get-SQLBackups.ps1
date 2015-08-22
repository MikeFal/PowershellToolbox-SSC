function Get-SQLBackups{
    param([Parameter(Mandatory=$true)][string]$Directory
        ,[ValidateSet('Full','Differential','Log')]$Type
        ,[int] $OlderThanHours=0
        ,[int] $EarlierThanHours=0)

    if(Test-Path $Directory){
        $extension = switch($Type){
                 Full{'.bak'}
                 Differential{'.dff'}
                 Log{'.trn'}
                 }
        if($OlderThanHours -gt 0){
            $files = Get-ChildItem $Directory -Filter "*$extension" -Recurse | Where-Object {$_.LastWriteTime -lt (Get-Date).AddHours(-$OlderThanHours)}
            }
        elseif($EarlierThanHours -gt 0){
            $files = Get-ChildItem $Directory -Filter "*$extension" -Recurse | Where-Object {$_.LastWriteTime -gt (Get-Date).AddHours(-$EarlierThanHours)}
            }
        else{
            $files = Get-ChildItem $Directory -Filter "*$extension" -Recurse
            }      

        return $files
        }
    else{
        Write-Warning "'$Directory' is not a valid path."
    } 
}

Get-SQLBackups -Directory C:\Nothing -Type Log
Get-SQLBackups -Directory C:\DBFiles\backups\backups -Type Full -OlderThanHours 24
Get-SQLBackups -Directory C:\DBFiles\backups\backups -Type Differential -EarlierThanHours 24

"--A Simple TLog Restore" | Out-File C:\TEMP\RestoreDemo.sql
$tlogs=Get-SQLBackups -Directory C:\DBFiles\backups\backups -Type Log -EarlierThanHours 24 | Sort-Object LastWriteTime
foreach($tlog in $tlogs){
    "RESTORE LOG [RestoreDemo] FROM DISK=N'$($tlog.name)' WITH NORECOVERY;" | Out-File C:\TEMP\RestoreDemo.sql -Append
}
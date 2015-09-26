function Get-FreeSpace{
    param([string] $HostName = ($env:COMPUTERNAME))

	Get-WmiObject win32_volume -computername $hostname  | `
            Where-Object {$_.drivetype -eq 3} | `
            Sort-Object name | `
            Format-Table name,@{l="Size(GB)";e={($_.capacity/1gb).ToString("F2")}},`
                              @{l="Free Space(GB)";e={($_.freespace/1gb).ToString("F2")}},`
                              @{l="% Free";e={(($_.Freespace/$_.Capacity)*100).ToString("F2")}}

}

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

function Test-SQLConnection{
    param([parameter(mandatory=$true)][string[]] $Instances)

    $return = @()
    foreach($InstanceName in $Instances){    
        $row = New-Object –TypeName PSObject –Prop @{'InstanceName'=$InstanceName;'StartupTime'=$null}
        try{
            $check=Invoke-Sqlcmd -ServerInstance $InstanceName -Database TempDB -Query "SELECT @@SERVERNAME as Name,Create_Date FROM sys.databases WHERE name = 'TempDB'" -ErrorAction Stop -ConnectionTimeout 3
            $row.InstanceName = $check.Name
            $row.StartupTime = $check.Create_Date
        }
        catch{
            #do nothing on the catch
        }
        finally{
            $return += $row
        }
    }
    return $return
}

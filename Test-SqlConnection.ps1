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

#Basic function example
function Invoke-Message{
    Write-Host -ForegroundColor Yellow 'Hello World!'
}

Invoke-Message

#basic Function example with parameter
function Invoke-Message{
    param([string] $message)

    Write-Host -ForegroundColor Yellow $message
}

Invoke-Message 'Hello World!'

#our first Powershell Tool, Get-FreeSpace
function Get-FreeSpace{
    param([string] $HostName = ($env:COMPUTERNAME))

	Get-WmiObject win32_volume -computername $hostname  | `
            Where-Object {$_.drivetype -eq 3} | `
            Sort-Object name | `
            Format-Table name,@{l="Size(GB)";e={($_.capacity/1gb).ToString("F2")}},`
                              @{l="Free Space(GB)";e={($_.freespace/1gb).ToString("F2")}},`
                              @{l="% Free";e={(($_.Freespace/$_.Capacity)*100).ToString("F2")}}

}

Get-FreeSpace -HostName localhost
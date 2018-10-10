##=================================================================================
##       Project:  Powershell Scripts
##        AUTHOR:  SADDAM ZEMMALI
##         eMail:  --
##       CREATED:  10.02.2018 10:22:01
##      REVISION:  SZEMMALI Professional Services
##       Version:  0.1  ¯\_(ツ)_/¯
##    Repository:  
##          Task:  Change Path Selection Policy for ESXI Hosts
##          FILE:  change-path-policy-esxi.ps1
##   Description:  This script will Change Path Policy for ESXI Hosts
##   Requirement:  --
##          Note:  -- 
##          BUGS:  Set-ExecutionPolicy -ExecutionPolicy Bypass
##=================================================================================
$StartTime = Get-Date
Set-PowerCLIConfiguration -InvalidCertificateAction ignore -confirm:$false
#################################
#    VMware vCenter server name # 
#################################  
$vCenterList = Get-Content vCenter.txt
$username = 'administrator@vsphere.local'
$password = Read-Host 'Enter The vCenter Password' -AsSecureString  

foreach ($vCenter in $vCenterList){
    Connect-VIServer -Server $vCenter -User  $username -Password  $password   
    Write-Host "Connecting to $vCenter..." -Foregroundcolor "Yellow" -NoNewLine
    If($? -Eq $True){
    Write-Host "Connected" -Foregroundcolor "Green" 
    ############################
    # Gathering VM information #
    ############################
    Write-Host "Gathering VM Information"
    $Report = @()  
    foreach ($Hosts in Get-VMHost) { 
        $VMHost = $Hosts.Name
        Write-Host Modifying the Multipathing policy on host $VMHost
        # Connect to esxcli commands environment on the specific Host
        $esxcli = Get-EsxCli -VMHost $VMHost
        # Get a list of all available LUNs, sorting them by device name
        $lunList = Get-VMHost $VMHost | Get-ScsiLun -CanonicalName "*" | % {$_.CanonicalName}
        # Looping through all available LUNs
        foreach ($lun in $lunList)
            {
            write-Host Executing set policy RR per device on $lun
            # Perform the required Multipathing Policy change to Round Robin against the specific LUN
            $esxcli.storage.nmp.device.set($null,$lun,"VMW_PSP_RR")
            }
        }
    }
    Else   
    {
        Write-Host "Error in Connecting to $vCenter; Try Again with correct user name & password!" -Foregroundcolor "Red" 
    }    
    ##############################
    # Disconnect session from VC #
    ##############################  
    Write-Host "Disconnect to $vCenter..." -Foregroundcolor "Yellow" -NoNewLine 
    $disconnection =Disconnect-VIServer -Server $vCenter  -Force -confirm:$false  -ErrorAction SilentlyContinue -WarningAction 0 | Out-Null
    If($? -Eq $True){
        Write-Host "Disconnected" -Foregroundcolor "Green" 
        Write-Host "#####################################" -Foregroundcolor "Blue" 
    }
    
    Else   
    {
        Write-Host "Error in Disconnecting to $vCenter" -Foregroundcolor "Red" 
    }
}    
$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)
Write-Host "================================"
Write-Host " Change Path Selection Policy for All ESXi Hosts Complete!"
Write-Host " StartTime: $StartTime"
Write-Host " EndTime:   $EndTime"
Write-Host " Duration:  $duration minutes"
Write-Host "================================"

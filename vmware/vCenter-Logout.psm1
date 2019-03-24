##========================================================================================
##       Project:  Powershell scripts for VMware
##        AUTHOR:  SADDAM ZEMMALI
##         eMail:  saddam.zemmali@gmail.com
##       CREATED:  03.24.2019 10:03:00
##      REVISION:  --
##       Version:  1.0  ¯\_(ツ)_/¯
##    Repository:  https://github.com/szemmali/powershell-scripts/
##          Task:  Powershell funtion to Logout from vCenter 
##          FILE:  vCenter-Logout.psm1
##   Description:  Function vCenter-Logout
##   Requirement:  --
##          Note:  -- 
##       Example:  vCenter-Logout "*"       #  Logout from all vcenter 
##                 vCenter-Logout "vcenter01"  
##          BUGS:  Set-ExecutionPolicy -ExecutionPolicy Bypass
##========================================================================================
####################################
#  Function to Logout from vCenter # 
####################################
function vCenter-Logout ($vcenter) {
  Write-Host "Disconnect to $vCenter..." -Foregroundcolor "Yellow" -NoNewLine 
  $disconnection =Disconnect-VIServer -Server $vCenter  -Force -confirm:$false  -ErrorAction SilentlyContinue -WarningAction 0 | Out-Null
  If($? -Eq $True){
    Write-Host "Disconnected" -Foregroundcolor "Green" 
    Write-Host "#####################################" 
  }

  Else{
    Write-Host "Error in Disconnecting to $vCenter" -Foregroundcolor "red"
  }
}


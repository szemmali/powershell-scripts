##========================================================================================
##       Project:  Powershell scripts for VMware
##        AUTHOR:  SADDAM ZEMMALI
##         eMail:  saddam.zemmali@gmail.com
##       CREATED:  03.24.2019 10:03:00
##      REVISION:  --
##       Version:  1.0  ¯\_(ツ)_/¯
##    Repository:  https://github.com/szemmali/powershell-scripts/
##          Task:  Powershell Function to Login in vCenter
##          FILE:  Function-Reset-IIS.psm1
##   Description:  Function vCenter-Login
##   Requirement:  --
##          Note:  -- 
##       Example:  vCenter-Login 
##          BUGS:  Set-ExecutionPolicy -ExecutionPolicy Bypass
##========================================================================================
#################################
#  Function to Login in vCenter # 
#################################
function vCenter-Login {
  begin {
    $vcenter = Read-Host 'Enter The VCENTER FQDN'
    $username = Read-Host 'Enter The vCenter Username'
    $password = Read-Host 'Enter The vCenter Password' -AsSecureString    
    $vccredential = New-Object System.Management.Automation.PSCredential ($username, $password)
  }
  process {
    Write-Host "Connecting to $vCenter..." -Foregroundcolor "Yellow" -NoNewLine
    $connection = Connect-VIServer -Server $vCenter -Cred $vccredential -ErrorAction SilentlyContinue -WarningAction 0 | Out-Null
    If($? -Eq $True){
      Write-Host "Connected" -Foregroundcolor "Green" }
    Else{
      Write-Host "Error in Connecting to $vCenter; Try Again with correct username & password!" -Foregroundcolor "Red" }
  }
}

vCenter-Login

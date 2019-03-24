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

# Logout from all vcenter 
vCenter-Logout "*"

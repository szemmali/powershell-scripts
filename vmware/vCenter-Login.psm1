#vCenter-Login
function vCenter-Login {
  begin {
    $vcenter = "VCENTER_FQDN"
    $username = Read-Host 'Enter The vCenter Username'
    $password = Read-Host 'Enter The vCenter Password' -AsSecureString    
    $vccredential = New-Object System.Management.Automation.PSCredential ($username, $password)
  }
  process {
    Write-Host "Connecting to $vCenter..." -Foregroundcolor "Yellow" -NoNewLine
    $connection = Connect-VIServer -Server $vCenter -Cred $vccredential -ErrorAction SilentlyContinue -WarningAction 0 | Out-Null
    If($? -Eq $True){
      Write-Host "Connected" -Foregroundcolor "Green" 
    }
    Else{
		  Write-Host "Error in Connecting to $vCenter; Try Again with correct username & password!" -Foregroundcolor "Red" 
	  }
  }
}

vCenter-Login

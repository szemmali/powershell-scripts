##=========================================================================================
##       Project:  Extend the Hard Disk for list of Windows VMs
##        AUTHOR:  SADDAM ZEMMALI
##         eMail:  saddam.zemmali@gmail.com
##       CREATED:  14.07.2018 02:03:01
##      REVISION:  --
##       Version:  1.0  ¯\_(ツ)_/¯
##    Repository:  https://github.com/szemmali/powershell-scripts
##          Task:  Extend the Hard Disk for list of VMs using PowerCLI
##          FILE:  Extend-HardDisk.psm1
##   Description:  Extend the Hard Disk for list of Windows VMs
##				         - Connect to vCenter
##				         - Check the connect session 
##				         - Extend the Hard Disk for each VM
##				         - Run DISKPART in Windows Machines
##       Example:  Extend-HardDisk "vm01" 
##   Requirement:  --
##          Note:  Connect With USERNAME/PASSWORD Credential 
##          BUGS:  Set-ExecutionPolicy -ExecutionPolicy Bypass
##=========================================================================================
##########################
# Function to PowerOn-VM # 
##########################
Function PowerOn-VM($vm){
   Start-VM -VM $vm -Confirm:$false -RunAsync | Out-Null
   Write-Host "$vm is starting!"
   sleep 5
   $time = 1
   # Now check if the VM is started within 120 loops with each 5 seconds of waittime
   do {
      $vmview = Get-VM $VM | Get-View
      $getvm = Get-VM $vm
      $powerstate = $getvm.PowerState
      $toolsstatus = $vmview.Guest.ToolsRunningStatus
      Write-Host "$vm is starting, powerstate is $powerstate and toolsstatus is $toolsstatus!"
      sleep 5
      $time++
   # Adjust the timer $time to wait longer or shorter for the VM to start up. Lowering this value will not break anything, you'll just have to check manually whether the VM started successfully.
   }until((($powerstate -match "PoweredOn") -and ($toolsstatus -match "guestToolsRunning")) -or ($time -eq 2))
   if ($toolsstatus -match "guestToolsRunning"){
      Write-Host "$vm is started and has ToolsStatus $toolsstatus"
   }
    else{$Startup = "ERROR"}
    return $Startup
}

#####################################################
# Function to Extend the Hard Disk for list of VMs  # 
#####################################################
Function Extend-HardDisk { 
	param(
	  [string]$VMs
	)
	BEGIN {
		$StartTime = Get-Date
		# The vCenter Credential 
		$vcenter = Read-Host 'Enter The vCenter Name'
		$username = Read-Host 'Enter The vCenter Username'
		$password = Read-Host 'Enter The vCenter Password' -AsSecureString  
		$vccredential = New-Object System.Management.Automation.PSCredential ($username, $password)

		# Hard Disk Informations 
		$HardDiskId = Read-Host "Enter VMware Hard Disk (Ex. 1)"
		$NewHDSize = Read-Host "Enter the new Hard Disk size in GB (Ex. 50)"
		$HardDisk = "Hard Disk " + $HardDiskId
		Disconnect-VIServer  -Force -confirm:$false  -ErrorAction SilentlyContinue -WarningAction 0 | Out-Null
	}
	PROCESS {
		#############################
		# Connect session from VC 	#
		############################# 
		$connection = Connect-VIServer -Server $vCenter -Cred $vccredential -ErrorAction SilentlyContinue -WarningAction 0 | Out-Null
		Write-Host "Connecting to $vCenter..." -Foregroundcolor "Yellow" -NoNewLine
		If($? -Eq $True){
			Write-Host "Connected" -Foregroundcolor "Green"
			foreach ($VM in $VMs) {
				# Extend the Hard Disk for each VM
				$VMdetails =Get-VM $VM
				$VMdetails | Get-HardDisk | Where-Object {$_.Name -eq "$HardDisk"} | Set-HardDisk -CapacityGB $NewHDSize -Confirm:$false
				# Check The OS

				# Check for Windows Machines
				if ({$VMdetails.Guest.OSFullName -like "*Microsoft*"}){
					# Check the status of the Machines
					$VolumeLetter = Read-Host "Enter the volume letter (Ex. c,d,e,f)"
					# If status == PowerOff	
					if ($VMdetails.PowerState -eq "PoweredOff" ) {
					    # PowerOn The VM
					    PowerOn-VM($vm)

						# Run DISKPART in the guest OS 
						Invoke-VMScript -vm $VM -ScriptText "echo rescan > c:\diskpart.txt && echo select vol $VolumeLetter >> c:\diskpart.txt && echo extend >> c:\diskpart.txt && diskpart.exe /s c:\diskpart.txt" -ScriptType BAT
					}

					# If status == PowerOn
					else {
						# Run DISKPART in the guest OS 
						Invoke-VMScript -vm $VM -ScriptText "echo rescan > c:\diskpart.txt && echo select vol $VolumeLetter >> c:\diskpart.txt && echo extend >> c:\diskpart.txt && diskpart.exe /s c:\diskpart.txt" -ScriptType BAT
					}
				}

				# Check for Linux Machines
				else {
					Write-Host "For the other OS"
					Write-Host "https://www.techrepublic.com/blog/smb-technologist/extending-partitions-on-linux-vmware-virtual-machines/"
					start 'https://www.techrepublic.com/blog/smb-technologist/extending-partitions-on-linux-vmware-virtual-machines/'
				}
			}
		}		
		Else{
			Write-Host  "Error in Connecting to $vCenter; Try Again with correct user name & password!" -Foregroundcolor "Red" 
		}
		##############################
		# Disconnect session from VC #
		##############################  
		Write-Host  "Disconnect to $vCenter..." -Foregroundcolor "Yellow" -NoNewLine 
		$disconnection =Disconnect-VIServer -Server $vCenter  -Force -confirm:$false  -ErrorAction SilentlyContinue -WarningAction 0 | Out-Null
		If($? -Eq $True){
		   Write-Host  "Disconnected" -Foregroundcolor "Green" 
		   Write-Host  "#####################################" 
		}
		Else{
		   Write-Host  "Error in Disconnecting to $vCenter"
		}				
	}
	END {
		##############################
		#       End of Script        #
		############################## 
		$EndTime = Get-Date
		$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)
		Write-Host "================================"
		Write-Host "Extend HardDisk Completed!"
		Write-Host "StartTime: $StartTime"
		Write-Host "  EndTime: $EndTime"
		Write-Host "  Duration: $duration minutes"
		Write-Host "================================"		
	}
}

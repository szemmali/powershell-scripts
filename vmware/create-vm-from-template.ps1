##=================================================================================
##       Project:  create-vm-from-template
##        AUTHOR:  SADDAM ZEMMALI
##         eMail:  saddam.zemmali@gmail.com
##       CREATED:  20.11.2018 02:03:01
##      REVISION:  --
##       Version:  1.0  ¯\_(ツ)_/¯
##    Repository:  ---------------------------------------------------
##          Task:  Create new VM from template With vCenter Credential
##          FILE:  create-vm-from-template.ps1
##   Description:  Deploy VMs from template and Configure the Guest OS
##   Requirement:  --
##          Note:  Connect With USERNAME/PASSWORD Credential 
##          BUGS:  Set-ExecutionPolicy -ExecutionPolicy Bypass
##=================================================================================
$StartTime = Get-Date
#################################
#       vSphere Variables       # 
#################################  
$vCenter = Get-Content "PATH:\vCenter.txt"
$username = Read-Host 'Enter The vCenter Username'
$password = Read-Host 'Enter The vCenter Password' -AsSecureString    
$vccredential = New-Object System.Management.Automation.PSCredential ($username, $password)

#################################
# 		    LOG INFO            # 
#################################  

#################################
#   Virtual Machine Variables   #
#################################
$NUMvCPU = '2'
$RAM =  '4'
$DiskSpace = '40'
$VMName = Read-Host 'Enter The VM Name'
$DomainControllerVMName = "DESIRED DC NAME HERE"
$FSVMName = "DESIRED FS NAME HERE"
$TargetCluster = Get-Cluster -Name "TARGET CLUSTER IN VCENTER"
$SourceVMTemplate = Get-Template -Name "SOURCE TEMPLATE IN VCENTER"
$SourceCustomSpec = Get-OSCustomizationSpec -Name "SOURCE CUSTOMIZATION SPEC IN VCENTER"

#######################################################
# Get list of Computer names and IP address from FILE #
#######################################################
$CSVFile = ipcsv -Path "C:\VistaComputers.csv" 

####################################
# IP Settings included in the GOSC # 
####################################
$IPMask = "255.255.255.0"
$IPGateway = "x.y.z.254"                                     
$DNS = "a.b.c.d"  

#################################
#  GOSC and Template Variables  #
#################################
$GOSCName = "GOSC Name"
$TempName = "Template Name"
$TempToUse = Get-Template -Name $TempName
 
#################################
#      Connecting to vCenter    # 
################################# 
Write-Host "Connecting to $vCenter..." -Foregroundcolor "Yellow" -NoNewLine
$connection = Connect-VIServer -Server $vCenter -Cred $vccredential -ErrorAction SilentlyContinue -WarningAction 0 | Out-Null
$DS = Get-Cluster -Name $CLUSTER | Get-Datastore | Select Name, FreeSpaceGB | Sort-Object FreeSpaceGB -Descending | Select -first 1

If($? -Eq $True){
    Write-Host "Connected" -Foregroundcolor "Green" 
    write-host "************ Creating $VMName; DO NOT CLOSE/STOP THIS SCRIPT! ************" -f red
    
    ##################
    #   Creating VM  # 
    ################## 
    foreach ($VM in $CSVFile){
 
        #Read the computer name and IP address
        $CompName = $VM.VMName
        $IPAddr = $VM.IPAddress
     
        #Amend the computer name and IP address in the GOSC
        Write-Host ("GOSC : Adding " + "IP Address" + $IPAddr + " and Computer Name " + $CompName)
        Get-OSCustomizationSpec $GOSCName | Set-OSCustomizationSpec -NamingPrefix $CompName -NamingScheme fixed | Out-Null
        Get-OSCustomizationNicMapping -OSCustomizationSpec $GOSCName | Set-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress $IPAddr -SubnetMask $IPMask -DefaultGateway $IPGateway -Dns $DNS | Out-Null

        #Create a new VM based on the set template and GOSC
        Write-Host ("Deploying : " + $CompName + " from template " + $TempName + "`n")
        New-VM -Name $CompName -Template $TempToUse -OSCustomizationSpec (Get-OSCustomizationSpec -Name $GOSCName) -Location $Location -VMHost $ESXHost -Datastore $Datastore | Out-Null
    }

    ##################
    #   Creating VM  # 
    ################## 
    foreach ($VM in $CSVFile){
        Write-Host("Power Up : " + $VM.VMName)
        Start-VM -VM $VMName -confirm:$false -RunAsync
    }

Else{
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

Else{
    Write-Host "Error in Disconnecting to $vCenter" -Foregroundcolor "Red" 
}

##############################
#       End of Script        #
############################## 
$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)
Write-Host "================================"
Write-Host "Create new VM from template Completed!"
Write-Host "StartTime: $StartTime"
Write-Host "  EndTime: $EndTime"
Write-Host "  Duration: $duration minutes"
Write-Host "================================"

##================================================================================================
##       Project:  Reset AD User Password Using PowerShell
##        AUTHOR:  SADDAM ZEMMALI
##         eMail:  saddam.zemmali@gmail.com
##       CREATED:  31.12.2018 14:03:01
##      REVISION:  --
##       Version:  1.0  ¯\_(ツ)_/¯
##    Repository:  hhttps://github.com/szemmali/powershell-scripts
##          Task:  Reset AD User Password Using PowerShell
##          FILE:  Reset_AD_User_Password.ps1
##   Description:  Reset AD User Password Using PowerShell
##   Requirement:  --
##          Note:  --
##          BUGS:  Set-ExecutionPolicy -ExecutionPolicy Bypass
##================================================================================================
#################################
# Reset PWD Targeting Variables # 
################################# 
$StartTime = Get-Date 
$UserList = Get-Content "UserList.txt"
$password = Read-Host 'Enter The New Password' -AsSecureString    
$vccredential = New-Object System.Management.Automation.PSCredential ($username, $password)

$Users = 0
$TotalUsers = $UserList.count
Write-Host "There are $TotalUsers vCenter"  -Foregroundcolor "Cyan"

foreach ($user in $UserList){
    $Users++
    Write-Host "Start Reset AD Password for user: $user" -Foregroundcolor "Green" 

    Write-Progress -Id 0 -Activity 'Checking User' -Status "Processing $($Users) of $($TotalUsers):  $($user)" -CurrentOperation $Users -PercentComplete (($Users/$TotalUsers) * 100)
    if (($Server -eq $Null) -or ($Server -eq '')){
        write-hosts "Reset the password for user $user with Plain Text Password:" -f "Cyan"
        Set-ADAccountPassword $user -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "P@ssW0rD!" -Force -Verbose) -PassThru
    }
    else {
        write-hosts "Reset the password for user $user with Secure String Password: "   -f "Cyan"
        Set-ADAccountPassword $user -Reset -NewPassword $password -PassThru
        #Set-ADAccountPassword $user -Reset -NewPassword (Read-Host -AsSecureString "AccountPassword") -PassThru
    }

    write-hosts "Force the user $user to change the password at next login:"    -f "Cyan"
    Set-ADUser -Identity $user -ChangePasswordAtLogon $true

    write-hosts "Set the password to never expires:"    -f "Cyan"
    Set-ADUser -Identity $user -ChangePasswordAtLogon $false -PasswordNeverExpires $true

    write-hosts "Verify that the password was reset successfully:"  -f "Cyan"
    Get-ADUser $user -Properties * | Select name, pass*
}
##############################
#       End of Script        #
############################## 
$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)
Write-Host "================================"
Write-Host "Reset AD User Password Completed!"
Write-Host "There are $TotalUsers AD User Password Reseted" -Foregroundcolor "Cyan"
Write-Host "StartTime: $StartTime"
Write-Host "  EndTime: $EndTime"
Write-Host "  Duration: $duration minutes"
Write-Host "================================"

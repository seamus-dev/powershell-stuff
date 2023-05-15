#this was pulled wholesale from someone else, so thanks them!
#I then got rid of some of it and re-wrote a bit, so...good luck!
#the right way to run this is script.ps1 and then it will ask you for the things, otherwise it won't secure string your password(s)
#I guess you could run it as script.ps1 -Username USERNAME -DomainController IPHERE if you wanted, but that seems like a lot of effort
#semi-author: seamus enright

[CmdletBinding(DefaultParameterSetName = 'Secure')]
param(
    [Parameter(ParameterSetName = 'Secure', Mandatory=$true)]    
    [string] $UserName,
    [Parameter(ParameterSetName = 'Secure', Mandatory=$true)]
    [securestring] $OldPassword,
    [Parameter(ParameterSetName = 'Secure', Mandatory=$true)]
    [securestring] $NewPassword,
    [alias('DC', 'Server', 'ComputerName')]
    [Parameter(ParameterSetName = 'Secure', Mandatory=$true)]
    [string] $DomainController
)
Begin {
    $DllImport = @'
[DllImport("netapi32.dll", CharSet = CharSet.Unicode)]
public static extern bool NetUserChangePassword(string domain, string username, string oldpassword, string newpassword);
'@
    $NetApi32 = Add-Type -MemberDefinition $DllImport -Name 'NetApi32' -Namespace 'Win32' -PassThru
}
Process {
    if ($DomainController -and $OldPassword -and $NewPassword -and $UserName) {
        $OldPasswordPlain = [System.Net.NetworkCredential]::new([string]::Empty, $OldPassword).Password
        $NewPasswordPlain = [System.Net.NetworkCredential]::new([string]::Empty, $NewPassword).Password

        $result = $NetApi32::NetUserChangePassword($DomainController, $UserName, $OldPasswordPlain, $NewPasswordPlain)
        if ($result) {
            Write-Host -Object "Set-PasswordRemotely - Password change for account $UserName failed on $DomainController. Please try again." -ForegroundColor Red
        } else {
            Write-Host -Object "Set-PasswordRemotely - Password change for account $UserName succeeded on $DomainController." -ForegroundColor Cyan
        }
    } else {
        Write-Warning "Set-PasswordRemotely - Password change for account failed. All parameters are required. (UserName, OldPassword, NewPassword, DomainController) "
    }
}
#this will create the firewall log fire
#due to problems, if you enable firewall logging through GPO, this does not get created
#unfortunately, you do have to restart the system after this for it to actually get created so, have fun with that in your production environment
# good luck out there -seamus
Function New-FirewallLogFile
{
  param ([string]$filename)

  New-Item $FileName -Type File -Force
  $Acl = Get-Acl $FileName
  $Acl.SetAccessRuleProtection( $True, $False )
  $PermittedUsers = @( 'NT AUTHORITY\SYSTEM', 'BUILTIN\Administrators', 'BUILTIN\Network Configuration Operators', 'NT SERVICE\MpsSvc' )
  foreach( $PermittedUser in $PermittedUsers ) {
    $Permission = $PermittedUser, 'FullControl', 'Allow'
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $Permission
    $Acl.AddAccessRule( $AccessRule )
  }
  
  $Acl.SetOwner( (new-object System.Security.Principal.NTAccount( 'BUILTIN\Administrators' )) )

  $Acl | Set-Acl $FileName  
}

New-FirewallLogFile 'C:\Windows\System32\LogFiles\Firewall\pfirewall.log'

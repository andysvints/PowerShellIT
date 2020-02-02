
<#
.Synopsis
   Grant User permissions to send email to specified Distribution Group using AD Attributes
.DESCRIPTION
   Grant User permissions to send email to specified Distribution Group using AD Attributes. If any of the group member is also group with "ReceiveEmailOnlyFrom" restriction
   add specified user to that group also.
.EXAMPLE
   Add-DLSentPermission -DLName "Project management" -User andryi_svintsitsky

   Group "Project Management" contain another group "logmein" user will be allowed to send emails to both of those groups. 
#>
function Add-DLSentPermission
{
    [CmdletBinding(SupportsShouldProcess=$true, 
                   ConfirmImpact='Medium')]
    [Alias()]
    Param
    (
        # Distribution Group Name
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("DL","DistributionGroup","MailList")] 
        $DLName,

        # User to be granted permissions to sent to
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("User")]
        $UserName
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("$DLName for $UserName"))
        {
            $RequiredModuleLoaded=$false
            Write-Verbose "Import ActiveDirectory Module"
            try{
                Import-Module ActiveDirectory -ErrorAction Stop
                $RequiredModuleLoaded=$true
                Write-Verbose "ActiveDirectory module has been successfully imported."
         

            if($RequiredModuleLoaded){
                Write-Verbose "Looking for $DLName group."
                $DLGroup=Get-Adgroup $DLName -Properties Members
                Write-Verbose "Group has been found."
                Write-Verbose "Looing for user $UserName"
                $User=Get-Aduser $UserName
                Write-Verbose "User has been found."
                Write-Verbose "Adding Sent to permission to the Group"
                Set-AdObject $DLGroup.DistinguishedName -Add @{authOrig="$($User.DistinguishedName)"}
                Set-AdObject $DLGroup.DistinguishedName -Add @{dlmemsubmitperms="$($User.DistinguishedName)"}
                Write-Verbose "Permissions have been added"
                $DLGroupMembers=$DLGroup | select -ExpandProperty Members
                $DLGroupEnclosed=$DLGroupMembers | foreach {try{Get-Adgroup $_ -Properties authOrig,dlmemsubmitperms -ErrorAction SilentlyContinue}catch{}}
                
                Write-Verbose "Checking if any child groups exist"
                foreach($g in $DLGroupEnclosed){
                    if($g.authOrig -ne $null){
                      Write-Verbose "$($g.Name) has sent to restictions."
                      Write-Verbose "Adding sent to permissions for $UserName"
                      Add-DLSentPermission -DLName $g.DistinguishedName -UserName $UserName  
                    }
                }  
            }

             }catch{
                Write-Verbose "Something bad happened. Please review exception message for more details."
                Write-Output "Catched Exception: $_"
                $RequiredModuleLoaded=$false
            }

            
        }
    }
    End
    {
    }
}




<#
.Synopsis
   Remove User permissions to send email to specified Distribution Group using AD Attributes
.DESCRIPTION
   Remove User permissions to send email to specified Distribution Group using AD Attributes. If any of the group members is also group with "ReceiveEmailOnlyFrom" restriction
   remove specified user permissions from that group also.
.EXAMPLE
   Remove-DLSentPermission -DLName "Project management" -User andrew.svintsitsky

   Group "Project Management" contain another group "Important Projects" user will be allowed to send emails to both of those groups. 
#>
function Remove-DLSentPermission
{
    [CmdletBinding(SupportsShouldProcess=$true, 
                   ConfirmImpact='Medium')]
    [Alias()]
    Param
    (
        # Distribution Group Name
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("DL","DistributionGroup","MailList")] 
        $DLName,

        # User to remove permissions to sent to
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("User")]
        $UserName
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("$DLName for $UserName"))
        {
            $RequiredModuleLoaded=$false
            #Import ActiveDirectory Module
            try{
                Import-Module ActiveDirectory -ErrorAction Stop
                $RequiredModuleLoaded=$true
            }catch{
                Write-Output "Catched Exception: $_"
                $RequiredModuleLoaded=$false
            }

            if($RequiredModuleLoaded){
                $DLGroup=Get-Adgroup $DLName -Properties Members
                $User=Get-Aduser $UserName
                Set-AdObject $DLGroup.DistinguishedName -Remove @{authOrig="$($User.DistinguishedName)"}
                Set-AdObject $DLGroup.DistinguishedName -Remove @{dlmemsubmitperms="$($User.DistinguishedName)"}

                $DLGroupMembers=$DLGroup | select -ExpandProperty Members
                $DLGroupEnclosed=$DLGroupMembers | foreach {try{Get-Adgroup $_ -Properties authOrig,dlmemsubmitperms -ErrorAction SilentlyContinue}catch{}}
                
                foreach($g in $DLGroupEnclosed){
                    if($g.authOrig -ne $null){
                      Remove-DLSentPermission -DLName $g.DistinguishedName -UserName $UserName  
                    }
                }  
            }

            
        }
    }
    End
    {
    }
}



<#
.Synopsis
   Get permissions to send email to specified Distribution Group using AD Attributes
.DESCRIPTION
   Get permissions to send email to specified Distribution Group using AD Attributes. 
.EXAMPLE
   Get-DLSentPermission -DLName "Project management" -User andrew.svintsitsky

   List of users who have permissions to sent email to the Distribution Group.
#>
function Get-DLSentPermission
{
    [CmdletBinding(SupportsShouldProcess=$true, 
                   ConfirmImpact='Medium')]
    [Alias()]
    Param
    (
        # Distribution Group Name
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("DL","DistributionGroup","MailList")] 
        $DLName


    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("$DLName"))
        {
            $RequiredModuleLoaded=$false
            #Import ActiveDirectory Module
            try{
                Import-Module ActiveDirectory -ErrorAction Stop
                $AllowedToSent=New-Object System.Collections.ArrayList
                $DLGroup=Get-Adgroup $DLName -Properties Members
                $GroupObj=Get-ADObject $DLGroup.DistinguishedName -Properties authOrig,dlmemsubmitperms
                
                $AutOrig=$GroupObj | Select -ExpandProperty authOrig 
                $DlMemSubmitPerms=$GroupObj | Select -ExpandProperty dlmemsubmitperms

                $AutOrig | %{
                    $p=[ordered]@{
                        Group=$DLName
                        User=$_
                        Attribute="AutOrig"
                    }
                    $Obj=New-Object -TypeName psobject -Property $p
                    $AllowedToSent.Add($Obj)>$null
                    }
                $DlMemSubmitPerms | %{
                    $p=[ordered]@{
                        Group=$DLName
                        User=$_
                        Attribute="DlMemSubmitPerms"
                    }
                    $Obj=New-Object -TypeName psobject -Property $p
                    $AllowedToSent.Add($Obj)>$null
                    }

                if($AutOrig.count -ne $DlMemSubmitPerms.count){
                    Write-Warning "Permissions error for $DLName number of users in authOrig do not equal users in DLMemSubmitPerms"
                    Write-Warning "Please review and correct issue"
                }

                $DLGroupMembers=$DLGroup | select -ExpandProperty Members
                $DLGroupEnclosed=$DLGroupMembers | foreach {try{Get-Adgroup $_ -Properties authOrig,dlmemsubmitperms -ErrorAction SilentlyContinue}catch{}}
                
                foreach($g in $DLGroupEnclosed){
                    if($g.authOrig -ne $null){
                      $AllowedToSent.Add($(Get-DLSentPermission -DLName $g.Name)) > $null
                      
                    }
                } 


                $AllowedToSent


            }catch{
                Write-Output "Catched Exception: $_"

            }


            
        }
    }
    End
    {
    }
}



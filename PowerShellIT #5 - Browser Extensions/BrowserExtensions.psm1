

<#
.Synopsis
   Get Specific Extension Risk Rating.
.DESCRIPTION
   Get Specific Extension Risk Rating using crxcavator.io API. Reference: https://crxcavator.io/docs.html#/report_breakdown
.EXAMPLE
   Get-ExtensionRiskRating -ExtensionID "{33730d30-3c0a-46f7-be41-3e0cda806b94}" -ExtensionVersion "1.2.1" -ExtensionPlatform "Firefox" -Verbose

VERBOSE: Performing the operation "Get-ExtensionRiskRating" on target "ExtensionID={33730d30-3c0a-46f7-be41-3e0cda806b94}, ExtensionVersion=1.2.1 for Firefox platform using crxcavator.io API".
VERBOSE: GET https://api.crxcavator.io/v1/report/{33730d30-3c0a-46f7-be41-3e0cda806b94}/1.2.1?platform=Firefox with 0-byte payload
VERBOSE: received -byte response of content type application/json

RiskLevel RiskScore RiskDetails
--------- --------- -----------
High            644 {Webstore, RetireJS, ContentSecurityPolicy, Permissions}

#>
function Get-ExtensionRiskRating
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    [Alias("ExtensionRisk")]
    Param
    (
        # Specific Extension ID
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $ExtensionID,

        # Specific Extension Version
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        $ExtensionVersion,

        # Specific Extension Platform
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [ValidateSet("FireFox","Chrome","Edge")]
        $ExtensionPlatform
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("ExtensionID=$ExtensionID, ExtensionVersion=$ExtensionVersion for $ExtensionPlatform platform using crxcavator.io API", "Get-ExtensionRiskRating"))
        {
            try {
                $Uri="https://api.crxcavator.io/v1/report/$ExtensionID/$($ExtensionVersion)?platform=$ExtensionPlatform"
                $CRXResponse=Invoke-WebRequest $Uri
                $CRXRiskDetails=$CRXResponse | ConvertFrom-Json
                $RiskDetailProps=@{
                    ContentSecurityPolicy=$CRXRiskDetails.data.risk.csp.total        
                    Permissions=$CRXRiskDetails.data.risk.permissions.total
                    RetireJS=$CRXRiskDetails.data.risk.retire.total    
                    Webstore =$CRXRiskDetails.data.risk.webstore.total
                }
                $p=@{
                    RiskScore=$CRXRiskDetails.data.risk.total
                    RiskLevel=switch ($CRXRiskDetails.data.risk.total) {
                        {$_ -le 377} { "Low" }
                        {$_ -gt 377 -and $_ -le 478} { "Medium" }
                        {$_ -gt 478} { "High" }
                        Default {"N/A"}
                    }
                    RiskDetails=$RiskDetailProps
                }

                $RiskScoreObj=New-Object -TypeName psobject -Property $p
                $RiskScoreObj    
            }
            catch {
                #Catch Exception
                Write-Verbose "Something Bad Happened. Please read exception message for more details."
                Write-Output "Catched Exception: $_"   
            }
        }

    }
    End
    {
    }
}

<#
.Synopsis
   Get installed Mozilla Firefox browser extensions for specific user.
.DESCRIPTION
   Get installed Mozilla Firefox browser extensions for specific user. Gets all enabled extensions from all Firefox profiles.
.EXAMPLE
PS > Get-FirefoxInstalledExtension -Username andys -Verbose            

VERBOSE: Performing the operation "Get-FirefoxInstalledExtension" on target "Username=andys".

User                : andys
Browser             : Firefox
Profile             : 9kb82iec.default-release-1585665124484
Id                  : {33730d30-3c0a-46f7-be41-3e0cda806b94}
Name                : Resting
Version             : 1.2.1
Type                : extension
Description         :
Creator             : Mirko Perillo
HomepageURL         : https://github.com/mirkoperillo/resting
Visible             : True
Active              : True
InstallDate         : 7/20/2021 8:18:24 AM
UpdateDate          : 7/20/2021 8:18:24 AM
Path                : C:\Users\andys\AppData\Roaming\Mozilla\Firefox\Profiles\9kb82iec.default-release-1585665124484\extensions\{33730d30 
                      -3c0a-46f7-be41-3e0cda806b94}.xpi
UserPermissions     : @{permissions=System.Object[]; origins=System.Object[]}
OptionalPermissions : @{permissions=System.Object[]; origins=System.Object[]}

User                : andys
Browser             : Firefox
Profile             : 9kb82iec.default-release-1585665124484
Id                  : {73a6fe31-595d-460b-a920-fcc0f8843232}
Name                : NoScript
Version             : 11.2.11
Type                : extension
Description         :
Creator             :
HomepageURL         :
Visible             : True
Active              : True
InstallDate         : 3/31/2020 2:32:58 PM
UpdateDate          : 8/2/2021 11:06:34 AM
Path                : C:\Users\andys\AppData\Roaming\Mozilla\Firefox\Profiles\9kb82iec.default-release-1585665124484\extensions\{73a6fe31
                      -595d-460b-a920-fcc0f8843232}.xpi
UserPermissions     : @{permissions=System.Object[]; origins=System.Object[]}
OptionalPermissions : @{permissions=System.Object[]; origins=System.Object[]}


#>
function Get-FirefoxInstalledExtension
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    [Alias("FirefoxExtension","gfie")]
    Param
    (
        # Username(s) to get installed browser extensions from
        [Parameter(ValueFromPipelineByPropertyName=$true,
        Mandatory=$true,
        Position=0)]      
        [string[]]$Username
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Username=$Username", "Get-FirefoxInstalledExtension"))
        {
            try {
                $origin = New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0
                $ExtensionsList=New-Object 'System.Collections.Generic.List[psobject]'
                
                foreach($u in $Username){
                    #Get Firefox Extension Json
                    $Path="C:\Users\$u\AppData\Roaming\Mozilla\Firefox\Profiles\"
                    $ExtFile=Get-ChildItem -path $Path -File  -Filter "extensions.json" -Recurse
                    
                    foreach($ef in $ExtFile){
                        $ExtensionList=(Get-Content -Path $ef.FullName | ConvertFrom-Json).addons | Where-Object {$_.active -eq $true}
                        foreach($e in $ExtensionList){
                            
                            $p=[ordered]@{
    
                                User=$u
                                Browser="Firefox"
                                Profile=$ef.Directory.Name
                                Id=$e.Id
                                Name=$e.defaultLocale.Name
                                Version=$e.version
                                Type=$e.Type
                                Description=$e.defaultLocale.Descripiton
                                Creator=$e.defaultLocale.Creator
                                HomepageURL=$e.defaultLocale.homepageURL
                                Active=$e.active
                                InstallDate=$origin.AddMilliseconds($e.installDate)
                                UpdateDate=$origin.AddMilliseconds($e.updateDate)
                                Path=$e.path
                                UserPermissions=$e.UserPermissions
                                OptionalPermissions=$e.OptionalPermissions
    
                            }
                            $ExtObj=New-Object psobject -Property $p
                            $ExtensionsList.add($ExtObj) | Out-Null
                            
                            
                            
                            
                        }
                    }
                    
                }
    
                $ExtensionsList
            }
            catch {
                #Catch Exception
                Write-Verbose "Something Bad Happened. Please read exception message for more details."
                Write-Output "Catched Exception: $_"
            }


            
        }
    }
    End
    {
    }
}

<#
.Synopsis
   Get installed Chrome like browser(s) extensions for specific user.
.DESCRIPTION
   Get installed Google Chrome and Microsoft Edge browser extensions for specific user. Gets all enabled extensions from all Chrome and Edge profiles.
.EXAMPLE
PS> Get-ChromeInstalledExtension -Username andys -Verbose

VERBOSE: Performing the operation "Get-ChromeInstalledExtension" on target "Username=andys".

User                : andys
Browser             : Chrome
Profile             : Default
Id                  : aapocclcgogkmnckokdopfmhonfmgoek
Name                : Slides
Version             : 0.10
Type                : app
Description         : Create and edit presentations
Creator             :
HomepageURL         :
Active              : True
InstallDate         : 3/31/2020 10:44:03 AM
UpdateDate          : 3/31/2020 10:44:03 AM
Path                : C:\Users\andys\AppData\Local\Google\Chrome\User Data\Default\Extensions\aapocclcgogkmnckokdopfmhonfmgoek\0.10_0
UserPermissions     :
OptionalPermissions :

User                : andys
Browser             : Chrome
Profile             : Default
Id                  : aohghmighlieiainnegkcijnfilokake
Name                : Docs
Version             : 0.10
Type                : app
Description         : Create and edit documents
Creator             :
HomepageURL         :
Active              : True
InstallDate         : 3/31/2020 10:44:04 AM
UpdateDate          : 3/31/2020 10:44:04 AM
Path                : C:\Users\andys\AppData\Local\Google\Chrome\User Data\Default\Extensions\aohghmighlieiainnegkcijnfilokake\0.10_0
UserPermissions     :
OptionalPermissions :

.EXAMPLE
Get-ChromeInstalledExtension -Username andys -Verbose -Edge

VERBOSE: Performing the operation "Get-ChromeInstalledExtension" on target "Username=andys".
VERBOSE: Getting Extensions for Default profile
VERBOSE: Getting Extensions for Profile 1 profile
VERBOSE: There are no installed extensions for Profile 1 profile.

User                : andys
Browser             : Edge
Profile             : Default
Id                  : bhmdjpobkcdcompmlhiigoidknlgghfo
Name                : Boomerang - SOAP & REST Client
Version             : 7.4.4
Type                : extension
Description         : Seamlessly integrate and test SOAP & REST services.
Creator             : Ashwin K
HomepageURL         :
Active              : True
InstallDate         : 11/17/2021 7:34:00 AM
UpdateDate          : 11/17/2021 7:34:00 AM
Path                : C:\Users\andys\AppData\Local\Microsoft\Edge\User Data\Default\Extensions\bhmdjpobkcdcompmlhiigoidknlgghfo\7.4.4_0
UserPermissions     : {<all_urls>, contextMenus, http://*/, https://*/…}
OptionalPermissions :

User                : andys
Browser             : Edge
Profile             : Default
Id                  : ndcileolkflehcjpmjnfbnaibdcgglog
Name                :
Version             : 4.40.0
Type                : app
Description         :
Creator             : BetaFish
HomepageURL         :
Active              : True
InstallDate         : 11/17/2021 7:33:34 AM
UpdateDate          : 11/17/2021 7:33:34 AM
Path                : C:\Users\andys\AppData\Local\Microsoft\Edge\User Data\Default\Extensions\ndcileolkflehcjpmjnfbnaibdcgglog\4.40.0_0
UserPermissions     : {tabs, <all_urls>, contextMenus, webRequest…}
OptionalPermissions :
#>
function Get-ChromeInstalledExtension
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    [Alias("ChromeExtension","gcie")]
    Param
    (
        # Username(s) to get installed browser extensions from
        [Parameter(ValueFromPipelineByPropertyName=$true,
        Mandatory=$true,
        Position=0)]      
        [string[]]$Username,

        [switch]$Edge


    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Username=$Username", "Get-ChromeInstalledExtension"))
        {
            try {
                $ExtensionsList=New-Object 'System.Collections.Generic.List[psobject]'
                if($Edge){
                    $SpecificPath="Microsoft\Edge"
                    $Browser="Edge"
                }else{
                    
                    $SpecificPath="Google\Chrome"
                    $Browser="Chrome"
                }
                foreach($u in $Username){
                    $LocalState=Get-content "C:\Users\$Username\AppData\Local\$SpecificPath\User Data\Local State" | ConvertFrom-Json
                    $ChromeProfiles=$LocalState.profile.info_cache | Get-Member | Where-Object {$_.MemberType -eq "NoteProperty"} | Select-Object -ExpandProperty Name
                    foreach ($profile in $ChromeProfiles) {
                        Write-Verbose "Getting Extensions for $profile profile"
                        if(Test-Path -Path "C:\Users\$Username\AppData\Local\$SpecificPath\User Data\$profile\Extensions"){
                            $ExtensionFolders = Get-ChildItem -Path "C:\Users\$Username\AppData\Local\$SpecificPath\User Data\$profile\Extensions" | Where-Object {$_.name -ne "Temp"}
                            foreach ($e in $ExtensionFolders) {
                                $ExtensionVersions = Get-ChildItem -Path "$($e.FullName)" | Select-Object -First 1
                                $Manifest=Get-Content -Raw -Path "$($ExtensionVersions.FullName)\manifest.json" | ConvertFrom-Json
                                $ExtensionName=$Manifest.name
                                $ExtensionDescr=$Manifest.Description
                                $ExtensionType="extension"
                                if($ExtensionName -like "*MSG*")
                                {
                                    $MessagesPath=Get-ChildItem "$($ExtensionVersions.FullName)\_locales\en*" | Select-Object -First 1
                                    $Messages=Get-Content -Raw -Path "$MessagesPath\messages.json" | ConvertFrom-Json
                                    $ExtensionName=$Messages.appName.Message
                                    $ExtensionDescr=$Messages.appDesc.Message
                                    $ExtensionType="app"
                                }
                                    
                                $p=[ordered]@{
        
                                    User=$u
                                    Browser=$Browser
                                    Profile=$profile
                                    Id=$e.Name
                                    Name=$ExtensionName
                                    Version=$Manifest.version
                                    Type=$ExtensionType
                                    Description=$ExtensionDescr
                                    Creator=$Manifest.author
                                    HomepageURL=""
                                    Active=$true
                                    InstallDate=$e.CreationTime
                                    UpdateDate=$e.LastWriteTime
                                    Path=$($ExtensionVersions.FullName)
                                    UserPermissions=$Manifest.permissions
                                    OptionalPermissions=""
        
                                }
                                $ExtObj=New-Object psobject -Property $p
                                $ExtensionsList.Add($ExtObj) | Out-Null  
                            }
                        }else {
                            Write-Verbose "There are no installed extensions for $profile profile."
                        }
                    }
                }
                $ExtensionsList
            }
            catch {
                #Catch Exception
                Write-Verbose "Something Bad Happened. Please read exception message for more details."
                Write-Output "Catched Exception: $_"
            }


            
        }
    }
    End
    {
    }
}



<#
.Synopsis
   Get Installed Browser Extensions and analyzing Risk Rating.
.DESCRIPTION
   Get Installed Browser Extensions and analyzing Risk Rating  using crxcavator.io API. Supported browsers: Firefox, Chrome and Edge.
.EXAMPLE
   PS > Get-InstalledBrowserExtension -Browser FireFox,Edge,Chrome -Verbose

VERBOSE: Performing the operation "Get-InstalledBrowserExtension" on target "Username=*, Browser=FireFox Edge Chrome,  RiskScore Skipped - False".
VERBOSE: Getting Local Users
VERBOSE: Getting Mozilla Firefox Installed Extensions
VERBOSE: There are 17 Firefox active extensions.
VERBOSE: Getting Edge Installed Extensions
VERBOSE: Getting Extensions for Default profile
VERBOSE: Getting Extensions for Profile 1 profile
VERBOSE: There are no installed extensions for Profile 1 profile.
VERBOSE: There are 2 Edge active extensions.
VERBOSE: Getting Google Chrome Installed Extensions
VERBOSE: Getting Extensions for Default profile
VERBOSE: Getting Extensions for Profile 1 profile
VERBOSE: Getting Extensions for Profile 2 profile
VERBOSE: There are 23 Chrome active extensions.
VERBOSE: Getting Risk Score for Installed Extensions
VERBOSE: There are 4 browser profiles.
VERBOSE: There are 42 installed extensions identified.
VERBOSE: 
                    Extension Risk Ratings Summary:

                        High Risk - 4 (10%)
                        Medium Risk - 4 (10%)
                        Low Risk - 34 (81%)


User                : andys
Browser             : Firefox
Profile             : 9kb82iec.default-release-1585665124484
Id                  : {33730d30-3c0a-46f7-be41-3e0cda806b94}
Name                : Resting
Version             : 1.2.1
Type                : extension
Description         :
Creator             : Mirko Perillo
HomepageURL         : https://github.com/mirkoperillo/resting
Active              : True
InstallDate         : 7/20/2021 8:18:24 AM
UpdateDate          : 7/20/2021 8:18:24 AM
Path                : C:\Users\andys\AppData\Roaming\Mozilla\Firefox\Profiles\9kb82iec.default-release-1585665124484\extensions\{33730d30-3c0a-46f7-be41-3e0cda806b94 
                      }.xpi
UserPermissions     : @{permissions=System.Object[]; origins=System.Object[]}
OptionalPermissions : @{permissions=System.Object[]; origins=System.Object[]}
RiskRating          : @{RiskLevel=High; RiskScore=644; RiskDetails=System.Collections.Hashtable}

User                : andys
Browser             : Firefox
Profile             : 9kb82iec.default-release-1585665124484
Id                  : {73a6fe31-595d-460b-a920-fcc0f8843232}
Name                : NoScript
Version             : 11.2.11
Type                : extension
Description         :
Creator             :
HomepageURL         :
Active              : True
InstallDate         : 3/31/2020 2:32:58 PM
UpdateDate          : 8/2/2021 11:06:34 AM
Path                : C:\Users\andys\AppData\Roaming\Mozilla\Firefox\Profiles\9kb82iec.default-release-1585665124484\extensions\{73a6fe31-595d-460b-a920-fcc0f8843232 
                      }.xpi
UserPermissions     : @{permissions=System.Object[]; origins=System.Object[]}
OptionalPermissions : @{permissions=System.Object[]; origins=System.Object[]}
RiskRating          : @{RiskLevel=High; RiskScore=513; RiskDetails=System.Collections.Hashtable}

User                : andys
Browser             : Firefox
Profile             : 9kb82iec.default-release-1585665124484
Id                  : {d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}
Name                : Adblock Plus - free ad blocker
Version             : 3.11.2
Type                : extension
Description         :
Creator             : eyeo GmbH
HomepageURL         :
Active              : True
InstallDate         : 3/31/2020 2:33:17 PM
UpdateDate          : 9/1/2021 1:23:48 PM
Path                : C:\Users\andys\AppData\Roaming\Mozilla\Firefox\Profiles\9kb82iec.default-release-1585665124484\extensions\{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d 
                      }.xpi
UserPermissions     : @{permissions=System.Object[]; origins=System.Object[]}
OptionalPermissions : @{permissions=System.Object[]; origins=System.Object[]}
RiskRating          : @{RiskLevel=Low; RiskScore=; RiskDetails=System.Collections.Hashtable}
#>
function Get-InstalledBrowserExtension
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    [Alias("gibe")]
    Param
    (
        # Username to get installed browser extensions from
        [Parameter(ValueFromPipelineByPropertyName=$true,
        Position=0)]      
        $Username="*",

        # Browser to get installed extensions from
        [Parameter(ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [ValidateSet("FireFox","Chrome","Edge")]
        $Browser=@("FireFox","Chrome","Edge"),

        # Do not perform Risc Score Check for installed browser extensions
        [Parameter(ValueFromPipelineByPropertyName=$true,
        Position=2)]  
        [switch]    
        $NoRiskScore=$false


    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Username=$Username, Browser=$($Browser),  RiskScore Skipped - $NoRiskScore", "Get-InstalledBrowserExtension"))
        {

            try {
                Write-Verbose "Getting Local Users"
                $Users=Get-LocalUser | Where-Object {$_.Enabled -eq $true}
                if($Username -ne "*"){
                    Write-Verbose "Checking if '$($Username)' exists on local machine"
                    $Users=$Users | Where-Object {$_.name -eq "$Username"} | Select-Object -ExpandProperty Name
                    if($Users.count -eq 0){
                        Write-Error "User '$($Username)' cannot be found."
                        break
                    }
                }
                $ExtensionList=$null
                foreach ($u in $Users){
                    #Get respective function for selected browser
                    switch ($Browser) {
                        "Firefox" { 
                            Write-Verbose "Getting Mozilla Firefox Installed Extensions"
                            $FirefoxExtensions=Get-FirefoxInstalledExtension -UserName $u
                            $ExtensionList+=$FirefoxExtensions
                            Write-Verbose "There are $($FirefoxExtensions.count) Firefox active extensions."
    
                            }
                        
                        "Chrome" { 
                            Write-Verbose "Getting Google Chrome Installed Extensions" 
                            $ChromeExtensions=Get-ChromeInstalledExtension -Username $u
                            $ExtensionList+=$ChromeExtensions
                            Write-Verbose "There are $($ChromeExtensions.count) Chrome active extensions."
                        }
                        
                        "Edge" { 
                            Write-Verbose "Getting Edge Installed Extensions" 
                            $EdgeExtensions=Get-ChromeInstalledExtension -Edge -Username $u
                            $ExtensionList+=$EdgeExtensions
                            Write-Verbose "There are $($EdgeExtensions.count) Edge active extensions."
                        }
                        
                        Default {}
                    }
                    
                    #Merge all functions output into one

                    if(!$NoRiskScore){
                        Write-Verbose "Getting Risk Score for Installed Extensions"
                        foreach($e in $ExtensionList){
                            $RiskScoreObj=Get-ExtensionRiskRating -ExtensionID $e.Id -ExtensionVersion $e.version -ExtensionPlatform $e.Browser
                            $e | Add-Member  -NotePropertyName "RiskRating" -NotePropertyValue $RiskScoreObj
                        }
                    }
                    Write-Verbose "There are $($ExtensionList| Select-Object -ExpandProperty User -Unique | Measure-Object | Select-Object -ExpandProperty Count) users."
                    Write-Verbose "There are $($ExtensionList| Select-Object -ExpandProperty Profile -Unique | Measure-Object | Select-Object -ExpandProperty Count) browser profiles."
                    
                    Write-Verbose "There are $($ExtensionList.count) installed extensions identified."
                    $HighRiskExtensions=$ExtensionList| Where-Object {$_.RiskRating.RiskLevel -eq "High"} | Measure-Object | Select-Object -ExpandProperty Count
                    $MediumRiskExtensions=$ExtensionList| Where-Object {$_.RiskRating.RiskLevel -eq "Medium"} | Measure-Object | Select-Object -ExpandProperty Count
                    $LowRiskExtensions=$ExtensionList| Where-Object {$_.RiskRating.RiskLevel -eq "Low"} | Measure-Object | Select-Object -ExpandProperty Count
                    
                    Write-Verbose "
                    Extension Risk Ratings Summary:

                        High Risk - $($HighRiskExtensions) ($([Math]::Round(($HighRiskExtensions*100)/$($ExtensionList.Count)))%)
                        Medium Risk - $($MediumRiskExtensions) ($([Math]::Round(($MediumRiskExtensions*100)/$($ExtensionList.Count)))%)
                        Low Risk - $($LowRiskExtensions) ($([Math]::Round(($LowRiskExtensions*100)/$($ExtensionList.Count)))%)
                    "
                    $ExtensionList
    
                }

                

            }
            catch {
                #Catch Exception
                Write-Verbose "Something Bad Happened. Please read exception message for more details."
                Write-Output "Catched Exception: $_"   
            }
        }
    }
    End
    {
    }
}



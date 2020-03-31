#region HelperFunction(s)

<#
.Synopsis
   Get files from user profile folder.
.DESCRIPTION
   Get files from user profile folder. Appdata folder is excluded by default.
.EXAMPLE
   Get-UserFiles -UserName testuser

   

    Directory: C:\Users\testuser

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d----           3/26/2020 10:27 PM                .config        
d----           3/26/2020 10:27 PM                .dotnet        
d----           3/26/2020 10:27 PM                .nuget
d----           3/26/2020 10:27 PM                .templateengine
d----           3/26/2020 10:27 PM                .vscode        
d-r--           3/26/2020 10:27 PM                3D Objects     
d-r--           3/26/2020 10:27 PM                Contacts       
d-r--           3/26/2020 10:27 PM                Desktop        
d-r--           3/26/2020 10:27 PM                Documents
d-r--           3/26/2020 10:27 PM                Downloads

.EXAMPLE
   Get-UserFiles -UserName test -verbose

   VERBOSE: test profile folder exists.
VERBOSE: Performing the operation "Get-UserFiles" on target "test".
VERBOSE: Get list of all user files
VERBOSE: Filtering Excluded folder AppData

    Directory: C:\Users\test

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d----           3/26/2020 10:27 PM                .config        
d----           3/26/2020 10:27 PM                .dotnet        
d----           3/26/2020 10:27 PM                .nuget
d----           3/26/2020 10:27 PM                .templateengine
d----           3/26/2020 10:27 PM                .vscode        
d-r--           3/26/2020 10:27 PM                3D Objects     
d-r--           3/26/2020 10:27 PM                Contacts       
d-r--           3/26/2020 10:27 PM                Desktop        
d-r--           3/26/2020 10:27 PM                Documents
d-r--           3/26/2020 10:27 PM                Downloads
#>
function Get-UserFiles {
    [CmdletBinding(SupportsShouldProcess=$true, 
    ConfirmImpact='Medium')]
    param (
        # Username to copy data from
        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("user")] 
        $UserName,

        # Folder to exclude. Default is AppData
        $ExcludeFolder="AppData"
    )
    
    begin {
        try {
            #Check if UserProfile Present on computer
            $UserProfileExist=Test-Path -Path "$( $Env:windir.split(':')[0]):\Users\$UserName"
            Write-Verbose "$UserName profile folder exists."
        }
        catch {
            #Catch Exception
            Write-Verbose "Something Bad Happened. Please read exception message for more details."
            Write-Output "Catched Exception: $_"
            
        }
    }
    
    process {
        if ($pscmdlet.ShouldProcess("$UserName"))
        {
            if($UserProfileExist){
                try {
                    New-Item -Path "C:\Users\$UserName\" -Name ".BackupUserProfile.true" -ItemType File -Force
                    Write-Verbose "Get list of all user files"
                    $AllFiles=Get-ChildItem -Path "C:\Users\$UserName\*" -Recurse -Force
                    Write-Verbose "Filtering Excluded folder $ExcludeFolder"
                    $AllFilesFiltered=$AllFiles | Where-Object {$_.FullName -notlike "*$ExcludeFolder*"}
                    return $AllFilesFiltered
                }
                catch {
                    #Catch Exception
                    Write-Verbose "Something Bad Happened. Please read exception message for more details."
                    Write-Output "Catched Exception: $_"
                    
                }
            }
        }
    }
    
    end {
        
    }
}

<#
.Synopsis
   Copy collection of files.
.DESCRIPTION
   Copy collection of files to destination preserving folder structure.
.EXAMPLE
   $Files2Migrate=Get-UserFiles -UserName $UserName
   Copy-Files -Files $Files2Migrate -DestinationPath C:\MigrationDestination

   Copying Files...
#>
function Copy-Files {
    [CmdletBinding(SupportsShouldProcess=$true, 
    ConfirmImpact='Medium')]
    param (
        #Files which need to be copied
        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias()] 
        $Files,

        #Destination Path
        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias()] 
        $DestinationPath
    )
    
    begin {
        $BaseDestination=$DestinationPath
        Write-Verbose "There are $($Files.count) file(s)."
    }
    
    process {
        if ($pscmdlet.ShouldProcess("$UserName"))
        {
            try {
                Write-Verbose "Sorting files to represent 2D tree structure"
                $Files=$Files | Sort-Object -Property FullName
                if($Files[0].mode -like "*d-*"){
                    $BaseSource=$(Get-Item $($Files[0].PSParentPath.split(':')[-1])).parent.FullName.Split(':')[-1]
                    
                }else{
                    $BaseSource=$Files[0].PSParentPath.split(':')[-1]
                }
                
                $count=1
                Write-Output "Copying Files..."
                foreach($f in $Files){
                    if($f.PSParentPath.split(':')[-1] -ne $BaseSource ){
                        $DestinationPath+=($f.PSParentPath.split(':')[-1].substring($BaseSource.Length))
                    }
                    
                    Copy-Item -Path $f.FullName -Destination $DestinationPath
                    Write-Verbose "$($f.FullName) has been copied to $DestinationPath"
                    Write-Verbose "$count of $($Files.count) copied."
                    Write-Verbose "$([math]::Round($($($count*100)/$($Files.Count))))% completed."
                    $DestinationPath=$BaseDestination
                    $count++

                }
            }
            catch {
                #Catch Exception
                Write-Verbose "Something Bad Happened. Please read exception message for more details."
                Write-Output "Catched Exception: $_"
            }
            
            
        }
    }
    
    end {
        
    }
}

<#
.Synopsis
   Get all saved wifi network SSIDs and password. 
.DESCRIPTION
   Get all saved wifi network SSIDs and password.
.EXAMPLE
   Get-SavedWiFiNetworks
#>
function Get-SavedWiFiNetworks {
    [CmdletBinding(SupportsShouldProcess=$true, 
    ConfirmImpact='Medium')]
    param (
        
    )
    
    begin {
        $Hostname=hostname    
    }
    
    process {
        if ($pscmdlet.ShouldProcess("$Hostname"))
        {
            try {
                $WifiNetworks=New-Object System.Collections.ArrayList
                $WLanProfiles=netsh.exe wlan show profiles | Select-String -Pattern "All User Profile" | ForEach-Object{$_.tostring().split(':')[-1].trim()}
                foreach($p in $WLanProfiles){
                    $ProfileDetails=netsh.exe wlan show profiles name="$($p)" key=clear
                    $WiFiNetworkKey=($ProfileDetails | Select-String -Pattern "Key Content").tostring().split(':')[-1].trim()
                    $Prop=[ordered]@{
                        WifiNetwork=$p
                        Password=$WiFiNetworkKey
                    }

                    $WiFiNetWorkObj=New-Object -TypeName psobject -Property $Prop
                    $WifiNetworks.Add($WiFiNetWorkObj) | Out-Null

                }
                $WifiNetworks
            }
            catch {
               #Catch Exception
               Write-Verbose "Something Bad Happened. Please read exception message for more details."
               Write-Output "Catched Exception: $_" 
            }
        }    
    }
    
    end {
        
    }
}

#endregion

#region ModuleFunction(s)

<#
.Synopsis
    Copy User profile files to desired destination.
.DESCRIPTION
    Copy User profile files to desired destination. Supported data and settings:
    User Profile Files - all files from user profile folder. AppData folder is excluded by default
    Printers - list of printers added to the computer
    WiFiNetworks - list of saved wifi networks and passwords.
    BrowserProfiles - web browser profiles. Mozilla Firefox and Google Chrome are supported.
.EXAMPLE
    Copy-UserProfile -UserName test -Data2Copy All -DestinationPath F:\
.EXAMPLE
   Copy-UserProfile -UserName andys -Data2Copy All -DestinationPath C:\MigrationDestination\

    Copying andys's BrowserProfiles
    Copying Firefox Profiles
    Copying Files...
    Copying Chrome Profiles
    Copying Files...
#>
function Copy-UserProfile {
    [CmdletBinding(SupportsShouldProcess=$true, 
    ConfirmImpact='Medium')]
    param 
    (
        # Username to copy data from
        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("user")] 
        $UserName,

        # Destination Path
        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("destination")] 
        $DestinationPath,

        # What data to copy
        [Parameter(ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [ValidateSet("All", "*", "Files","Printers","WiFiNetworks","BrowserProfiles")]
        [Alias("Data")]
        $Data2Copy="*"
        
    )
    
    begin 
    {
        try {
            #Check if UserProfile Present on computer
            $UserProfileExist=Test-Path -Path "$( $Env:windir.split(':')[0]):\Users\$UserName"
        }
        catch {
            #Catch Exception
            Write-Verbose "Something Bad Happened. Please read exception message for more details."
            Write-Output "Catched Exception: $_"
            
        }
    }
    
    process 
    {
        if ($pscmdlet.ShouldProcess("$UserName"))
        {
            if($UserProfileExist){
                try {
                    if($Data2Copy -eq "*" -or $Data2Copy -eq "All"){
                        $Data2Copy="Files","Printers","WiFiNetworks","BrowserProfiles"
                    }
                    #Create Folder with Username at the destination
                    New-Item -Path $DestinationPath -Name $UserName -ItemType Directory | Out-Null
                    $DestinationPath+="\$UserName"
                    switch ($Data2Copy) {
                        
                        {'Files' -in $_} {
                            Write-Output "Copying $UserName's Files"
                            $Files2Migrate=Get-UserFiles -UserName $UserName
                            New-Item -Path $DestinationPath -Name "Files" -ItemType Directory | Out-Null
                            Copy-Files -Files $Files2Migrate -DestinationPath "$DestinationPath\Files"

                        }
                        
                        {'Printers' -in $_} {
                            Write-Output "Copying $UserName's Printers"
                            New-Item -Path $DestinationPath -Name "Printers" -ItemType Directory | Out-Null
                            Get-Printer | Export-Csv -NoTypeInformation -Path "$DestinationPath\Printers\PrintersList.csv"
                            
                        }
                        
                        {'WiFiNetworks' -in $_} {
                            Write-Output "Copying $UserName's WiFiNetworks"
                            New-Item -Path $DestinationPath -Name "WiFiNetworks" -ItemType Directory | Out-Null
                            Get-SavedWiFINetworks | Export-Csv -NoTypeInformation -Path "$DestinationPath\WiFiNetworks\WiFiNetworksList.csv"
                        }

                        {'BrowserProfiles' -in $_} {
                            Write-Output "Copying $UserName's BrowserProfiles"
                            New-Item -Path $DestinationPath -Name "BrowserProfiles" -ItemType Directory | Out-Null

                            $FirefoxProfilePath="C:\Users\$Username\AppData\Roaming\Mozilla\Firefox\Profiles"
                            if(Test-path $FirefoxProfilePath){
                                Write-Output "Copying Firefox Profiles"
                                New-Item -Path $FirefoxProfilePath -Name ".BackupFirefoxprofile.true" -ItemType File -Force | Out-Null
                                $FirefoxProfilesData=Get-ChildItem -Path "$FirefoxProfilePath\*" -Recurse -Force
                                $FirefoxProfilesDataDestination="$DestinationPath\BrowserProfiles\"
                                New-Item -Path $FirefoxProfilesDataDestination -Name "Firefox" -ItemType Directory | Out-Null
                                Copy-Files -Files $FirefoxProfilesData -DestinationPath "$FirefoxProfilesDataDestination\Firefox"
                            
                            }
                            $ChromeProfilePath="C:\Users\$UserName\AppData\Local\Google\Chrome\User Data"
                            if(Test-Path $ChromeProfilePath){
                                $ChromeProfilesData=New-Object System.Collections.ArrayList
                                Write-Output "Copying Chrome Profiles"
                                New-Item -Path $ChromeProfilePath -Name ".BackupChromeprofile.true" -ItemType File -Force | Out-Null
                                $ChromeProfiles=Get-ChildItem -Path "$ChromeProfilePath\*" -Recurse -Force
                                $DefaultProfiles=$ChromeProfiles | Where-Object {$_.FullName -like "$ChromeProfilePath\Default\*" }
                                $CustomProfiles=$ChromeProfiles | Where-Object {$_.FullName -like "$ChromeProfilePath\Profile*"}
                                $DefaultProfiles | ForEach-Object {$ChromeProfilesData.Add($_)| Out-Null}
                                $CustomProfiles | ForEach-Object {$ChromeProfilesData.Add($_)| Out-Null}
                                $ChromeProfilesData.Add($($ChromeProfiles | Where-Object {$_.fullName -like "*.BackupChromeprofile.true"})) | Out-Null
                                $ChromeProfileDataDestination="$DestinationPath\BrowserProfiles\"
                                New-Item -Path $ChromeProfileDataDestination -Name "Chrome" -ItemType Directory | Out-Null
                                Copy-Files -Files $ChromeProfilesData -DestinationPath "$ChromeProfileDataDestination\Chrome"
                            
                            }
                            
                        }

                        Default {
                        }
                    }
                    
                }
                catch {
                    #Catch Exception
                    Write-Verbose "Something Bad Happened. Please read exception message for more details."
                    Write-Output "Catched Exception: $_" 
                }

            }else {
                Write-Verbose "Profile for $UserName do not exist."
                Write-Output "$UserName profile cannot be found. Please check username and try again."
            }
            
        } 
    }
    
    end 
    {
        
    }
}

#endregion

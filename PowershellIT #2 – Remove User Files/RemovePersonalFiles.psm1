<#
.Synopsis
   Remove personal files from computer.
.DESCRIPTION
    Remove personal files types specified in the Config file from all filesystem drives.
.EXAMPLE
   Remove-PersonalFile -whatif

   What if: Performing the operation "Remove-PersonalFile" on target "All filesystem drives".
.EXAMPLE
   Remove-PersonalFile 
#>
function Remove-PersonalFile
{
    [CmdletBinding(SupportsShouldProcess=$true, 
                  PositionalBinding=$false)]
    [Alias()]

    Param
    (
        # Folder path which should be excluded
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]

        [ValidateNotNullOrEmpty()]

        [Alias()] 
        $Exclude="C:\windows\"
    )

    Begin
    {
        $ModuleBase=Get-Module RemovePersonalFile -ListAvailable | select -ExpandProperty modulebase
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("All filesystem drives. Excluding $Exclude folder."))
        {
            
            $Cfg=Get-RemovePersonalFileConfig
            if($Cfg){
                $ListOFDrives=Get-PSDrive -p "FileSystem" 
                if($Exclude[-1] -eq '\'){$Exclude+="*"}else{$Exclude+="\*"}
                foreach($Drive in $ListOFDrives){
                   Get-ChildItem $d.root -Include $cfg.filetype.extension -Recurse -ErrorAction Ignore | Where {$_.fullname -notlike $Exclude } | Remove-Item 
                   
                }
            }else{
                Write-Warning "Config file not found. Please run 'Create-RemovePersonalFileDefaultConfig' cmdlet first."
            }

        }
    }
    End
    {
    }
}


<#
.Synopsis
  Generate RemovePersonalFile default config.
.DESCRIPTION
   Generate RemovePersonalFile default config. Default config file contains 6 Categories and 56 personal file extensions.
   Config File is saved at PS Module root location.
   Category and FileType Reference: https://www.computerhope.com/issues/ch001789.htm 
.EXAMPLE
   Create-RemovePersonalFileDefaultConfig

   Creates a Default config File. 
.EXAMPLE
   Create-RemovePersonalFileDefaultConfig -Display

Category                             FileType                                                                                                                                        
--------                             --------                                                                                                                                        
Presentation file formats            {@{extension=*.key; description=Keynote presentation}, @{extension=*.odp; description=OpenOffice Impress presentation file}...
Audio file formats                   {@{extension=*.aif; description=AIF audio file}, @{extension=*.cda; description=CD audio track file}, @{extension=*.mid; de...
Spreadsheet file formats             {@{extension=*.ods; description=OpenOffice Calc spreadsheet file}, @{extension=*.xlr; description=Microsoft Works spreadshe...
Video file formats                   {@{extension=*.3g2; description=3GPP2 multimedia file}, @{extension=*.3gp; description=3GPP multimedia file}, @{extension=*...
Word processor and text file formats {@{extension=*.doc; description=Microsoft Word file}, @{extension=*.docx; description=Microsoft Word file}, @{extension=*.o...
Image file formats                   {@{extension=*.ai; description=Adobe Illustrator file}, @{extension=*.bmp; description=Bitmap image}, @{extension=*.gif; de...

    Creates a Default config File and immediately displays it to the console. 

#>
function Create-RemovePersonalFileDefaultConfig
{
    [CmdletBinding(SupportsShouldProcess=$true, 
                  ConfirmImpact='Medium')]
    [Alias()]

    Param
    (
        [switch]$Display
    )

    Begin
    {
        $PresentationFileFormats=[ordered]@{
    
            Category="Presentation file formats"
            FileType=@(
                @{
                    description="Keynote presentation"
                    extension="*.key"
                },
                @{
                description="OpenOffice Impress presentation file"
                extension="*.odp"
                },
                @{
                description="PowerPoint slide show"
                extension="*.pps"
                },
                @{
                description="PowerPoint presentation"
                extension="*.ppt"
                },
                @{
                description="PowerPoint Open XML presentation"
                extension="*.pptx"
                }
            )
    

        }

        $AudioFileFormats=[ordered]@{

            Category="Audio file formats"
            FileType=@(
                @{
                    description="AIF audio file"
                    extension="*.aif"
                },
                @{
                    description="CD audio track file"
                    extension="*.cda"
                },
                @{
                    description="MIDI audio file"
                    extension="*.mid"
                },
                @{
                    description="MIDI audio file"
                    extension="*.midi"
                },
                @{
                    description="MP3 audio file"
                    extension="*.mp3"
                },
                @{
                    description="MPEG-2 audio file"
                    extension="*.mpa"
                },
                @{
                    description="Ogg Vorbis audio file"
                    extension="*.ogg"
                },
                @{
                    description="WAV file"
                    extension="*.wav"
                },
                @{
                    description="WMA audio file"
                    extension="*.wma"
                },
                @{
                    description="Windows Media Player playlist"
                    extension="*.wpl"
                }
            )

        }

        $SpreadsheetFileFormats=[ordered]@{
            Category="Spreadsheet file formats"
            FileType=@(
                @{
                    description="OpenOffice Calc spreadsheet file"
                    extension="*.ods"
                },
                @{
                    description="Microsoft Works spreadsheet file"
                    extension="*.xlr"
                },
                @{
                    description="Microsoft Excel file"
                    extension="*.xls"
                },
                @{
                    description="Microsoft Excel Open XML spreadsheet file"
                    extension="*.xlsx"
                }
            )
        }

        $VideoFileFormats=[ordered]@{
            Category="Video file formats"
            FileType=@(
                @{
                    description="3GPP2 multimedia file"
                    extension="*.3g2"
                },
                @{
                    description="3GPP multimedia file"
                    extension="*.3gp"
                },
                @{
                    description="AVI file"
                    extension="*.avi"
                },
                @{
                    description="Adobe Flash file"
                    extension="*.flv"
                },
                @{
                    description="H.264 video file"
                    extension="*.h264"
                },
                @{
                    description="Apple MP4 video file"
                    extension="*.m4v"
                },
                @{
                    description="Matroska Multimedia Container"
                    extension="*.mkv"
                },
                @{
                    description="Apple QuickTime movie file"
                    extension="*.mov"
                },
                @{
                    description="MPEG4 video file"
                    extension="*.mp4"
                },
                @{
                    description="MPEG video file"
                    extension="*.mpg"
                },
                @{
                    description="MPEG video file"
                    extension="*.mpeg"
                },
                @{
                    description="RealMedia file"
                    extension="*.rm"
                },
                @{
                    description="Shockwave flash file"
                    extension="*.swf"
                },
                @{
                    description="DVD Video Object"
                    extension="*.vob"
                },
                @{
                    description="Windows Media Video file"
                    extension="*.wmv"
                }
            )
        }

        $TextFileFormats=[ordered]@{
            Category="Word processor and text file formats"
            FileType=@(
                @{
                    description="Microsoft Word file"
                    extension="*.doc"
                },
                @{
                    description="Microsoft Word file"
                    extension="*.docx"
                },
                @{
                    description="OpenOffice Writer document file"
                    extension="*.odt"
                },
                @{
                    description="PDF file"
                    extension="*.pdf"
                },
                @{
                    description="Rich Text Format"
                    extension="*.rtf"
                },
                @{
                    description="A LaTeX document file"
                    extension="*.tex"
                },
                @{
                    description="Plain text file"
                    extension="*.txt"
                },
                @{
                    description="Microsoft Works file"
                    extension="*.wks"
                },
                @{
                    description="Microsoft Works file"
                    extension="*.wps"
                },
                @{
                    description="WordPerfect document"
                    extension="*.wpd"
                }
            )
        }

        $ImageFileFormats=[ordered]@{
            Category="Image file formats"
            FileType=@(
                @{
                    description="Adobe Illustrator file"
                    extension="*.ai"    
                },
                @{
                    description="Bitmap image"
                    extension="*.bmp"    
                },
                @{
                    description="GIF image"
                    extension="*.gif"    
                },
                @{
                    description="Icon file"
                    extension="*.ico"    
                },
                @{
                    description="JPEG image"
                    extension="*.jpeg"    
                },
                @{
                    description="JPEG image"
                    extension="*.jpg"    
                },
                @{
                    description="PNG image"
                    extension="*.png"    
                },
                @{
                    description="PostScript file"
                    extension="*.ps"    
                },
                @{
                    description="PSD image"
                    extension="*.psd"    
                },
                @{
                    description="Scalable Vector Graphics file"
                    extension="*.svg"    
                },
                @{
                    description="TIFF image"
                    extension="*.tif"    
                },
                @{
                    description="TIFF image"
                    extension="*.tiff"    
                }
            
            )
        
    
        }
    }
    Process
    {
        if ($pscmdlet.ShouldProcess(""))
        {
            $DefaultCfg=$PresentationFileFormats,$AudioFileFormats,$SpreadsheetFileFormats,$VideoFileFormats,$TextFileFormats,$ImageFileFormats | ConvertTo-Json -Depth 3 
            $ModuleObj=Get-Module RemovePersonalFiles

            $DefaultCfg | Out-File "$($ModuleObj.ModuleBase)\PersonalFileTypes.json"

            if($Display)
            {
                Get-RemovePersonalFileConfig
            }
        }
    }
    End
    {
    }
}


<#
.Synopsis
   Get Remove Personal File current config.
.DESCRIPTION
   Get Remove Personal File current config. Returns PS custom object based on config file. 
   Config file is a json file which contains collection of object with category and filetype. 
   Filetype is also an object which has description and extension. JSON Config File Example:
   {
        "Category":  "Presentation file formats",
        "FileType":  [
                         
                         {
                             "extension":  "*.odp",
                             "description":  "OpenOffice Impress presentation file"
                         },
                      
                         {
                             "extension":  "*.pptx",
                             "description":  "PowerPoint Open XML presentation"
                         }
                     ]
    }

.EXAMPLE
   Get-RemovePersonalFileConfig

Category                             FileType                                                                                                                                        
--------                             --------                                                                                                                                        
Presentation file formats            {@{extension=*.key; description=Keynote presentation}, @{extension=*.odp; description=OpenOffice Impress presentation file}...
Audio file formats                   {@{extension=*.aif; description=AIF audio file}, @{extension=*.cda; description=CD audio track file}, @{extension=*.mid; de...
Spreadsheet file formats             {@{extension=*.ods; description=OpenOffice Calc spreadsheet file}, @{extension=*.xlr; description=Microsoft Works spreadshe...
Video file formats                   {@{extension=*.3g2; description=3GPP2 multimedia file}, @{extension=*.3gp; description=3GPP multimedia file}, @{extension=*...
Word processor and text file formats {@{extension=*.doc; description=Microsoft Word file}, @{extension=*.docx; description=Microsoft Word file}, @{extension=*.o...
Image file formats                   {@{extension=*.ai; description=Adobe Illustrator file}, @{extension=*.bmp; description=Bitmap image}, @{extension=*.gif; de...
 

#>
function Get-RemovePersonalFileConfig
{
    [CmdletBinding(SupportsShouldProcess=$true,
                  ConfirmImpact='Medium')]

    Param
    (
        
    )

    Begin
    {
        $CfgFileName="PersonalFileTypes.json"
    }
    Process
    {
        if ($pscmdlet.ShouldProcess(""))
        {
               
            $MOduleObj=Get-Module RemovePersonalFiles
            $CfgFilePath="$($MOduleObj.ModuleBase)\$CfgFileName"
            if(Test-Path $CfgFilePath){
                $CfgFile=Get-Content  $CfgFilePath | ConvertFrom-Json   
                $CfgFile
            }else{
                Write-Warning "Config file not found. Please run 'Create-RemovePersonalFileDefaultConfig' cmdlet first."
            }

            
        }
    }
    End
    {
    }
}


<#
.Synopsis
   Update config file by adding additonal category and file extensions.
.DESCRIPTION
   Update config file by adding additonal category and file extensions.
.EXAMPLE
   $ImageFileFormats=[ordered]@{
            Category="Image file formats"
            FileType=@(
                @{
                    description="Adobe Illustrator file"
                    extension="*.ai"    
                },
                @{
                    description="Bitmap image"
                    extension="*.bmp"    
                },
                @{
                    description="PNG image"
                    extension="*.png"    
                }
            
            )
        
    
        }

   Update-RemovePersonalFileConfig -ConfigObject $ImageFileFormats 

#>
function Update-RemovePersonalFileConfig
{
    [CmdletBinding(SupportsShouldProcess=$true,
                  ConfirmImpact='Medium')]

    Param
    (
        $ConfigObject
    )

    Begin
    {
        
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("$ConfigObject"))
        {
               
            if(Validate-RemovePersonalFileConfigObject -ConfigObject $ConfigObject){
                $Cfg=Get-RemovePersonalFileConfig
                $ConfigObject=New-Object -TypeName psobject -Property $ConfigObject
                
                $NewCfg=$Cfg+$ConfigObject | ConvertTo-Json -Depth 3 
                $ModuleObj=Get-Module RemovePersonalFiles

                $NewCfg | Out-File "$($ModuleObj.ModuleBase)\PersonalFileTypes.json"
            }

            
        }
    }
    End
    {
    }
}

<#
.Synopsis
   Validates if Object follow Config File Object standart.
.DESCRIPTION
   Validates if Object follow Config File Object standart. Returns $true if Object is compliant with the standard and $false otherwise.
.EXAMPLE
   Validate-RemovePersonalFileConfigObject -ConfigObject $ImageFileFormats

    True

.EXAMPLE
    Validate-RemovePersonalFileConfigObject -ConfigObject $null
    
    WARNING: Config Object do not comply with template.

    False
#>
function Validate-RemovePersonalFileConfigObject
{
    [CmdletBinding(SupportsShouldProcess=$true,
                  ConfirmImpact='Medium')]

    Param
    (
        $ConfigObject
    )

    Begin
    {
        
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("$ConfigObject"))
        {
               
            if($ConfigObject.Category -ne $null -and $ConfigObject.FileType -ne $null -and $ConfigObject.FileType.Description -ne $null -and $ConfigObject.FileType.Extension -ne $null){
                $true
            }else{
            
                Write-Warning "Config Object do not comply with template."
                $False
            }

            
        }
    }
    End
    {
    }
}



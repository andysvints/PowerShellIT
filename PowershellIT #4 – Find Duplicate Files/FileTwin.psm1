#region ModuleFunction(s)

<#
.Synopsis
    Find file duplicates.
.DESCRIPTION
    Find file duplicates in the specified folder or look for a duplicate of the provided file with the specific location.
.EXAMPLE
    Find-FileTwin -Path C:\Users\andys\Downloads\ -Verbose

    VERBOSE: Performing the operation "Find-FileTwin" on target "C:\Users\andys\Downloads\".
    VERBOSE: There are 61 file(s).
    VERBOSE: Generating hashes for all files at C:\Users\andys\Downloads\
    VERBOSE: There are 2 file(s) duplicates.

    Hash                                                             Name                                  Path
    ----                                                             ----                                  ----
    7A05107A61106C7FA8FBE9982111A32F9690E9E84D17A2DECE61938EF16FE1E7 KeePass-2.44-Setup(1).exe             C:\Users… 
    7A05107A61106C7FA8FBE9982111A32F9690E9E84D17A2DECE61938EF16FE1E7 KeePass-2.44-Setup.exe                C:\Users…
    8D271DB34475DDAA8732C1AFDF472C634E495A134EB37F3C79DFEBC86525AAD0 cpub-Terminal-Terminal-CmsRdsh(1).rdp C:\Users… 
    8D271DB34475DDAA8732C1AFDF472C634E495A134EB37F3C79DFEBC86525AAD0 cpub-Terminal-Terminal-CmsRdsh(2).rdp C:\Users… 
    8D271DB34475DDAA8732C1AFDF472C634E495A134EB37F3C79DFEBC86525AAD0 cpub-Terminal-Terminal-CmsRdsh(3).rdp C:\Users… 
    8D271DB34475DDAA8732C1AFDF472C634E495A134EB37F3C79DFEBC86525AAD0 cpub-Terminal-Terminal-CmsRdsh.rdp    C:\Users… 
.EXAMPLE
    $Path="C:\MigrationDestination\test2\Files\Downloads"
    Find-FileTwin -Path $Path -File C:\MigrationDestination\test2\Files\laptop.png

        Status           : BaseFile
    Name             : laptop.png
    Path             : C:\MigrationDestination\test2\Files\laptop.png
    Hash             : 432AF4B656BEE79264BC90683B05EC1BDB04CE355147A23060600A6E98EEFB14
    HashingAlgorithm : SHA256

    Status           : Duplicate
    Name             : laptop.png
    Path             : C:\MigrationDestination\test2\Files\Downloads\laptop.png
    Hash             : 432AF4B656BEE79264BC90683B05EC1BDB04CE355147A23060600A6E98EEFB14
    HashingAlgorithm : SHA256
#>
function Find-FileTwin {
    [CmdletBinding(SupportsShouldProcess=$true, 
    ConfirmImpact='Medium')]
    param (
        # Path where to find duplicates
        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("Location")] 
        $Path,

        # Source file full path which should be compared to files in $Path
        [Parameter(ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [Alias("Data")]
        $File

    )
    
    begin {
        $TargetMessage="$Path"
        if($File){
            $TargetMessage+="; Base file: $File"
        }
    }
    
    process {
        if ($pscmdlet.ShouldProcess("$TargetMessage"))
        {
            try {
                if(Test-Path $Path){
                    #Get list of all files
                    $AllFiles=Get-ChildItem -Recurse -Path $Path
                    #Filter folders from the list
                    $AllFiles=$AllFiles | Where-Object {$_.mode -notlike "d*"}
                    Write-Verbose "There are $($AllFiles.count) file(s)."
                    
                    #Generate Hashes for every File
                    Write-Verbose "Generating hashes for all files at $Path"
                    $FileHashArrList=New-Object "System.Collections.ArrayList"
                    foreach($f in $AllFiles){
                        $HashFileObj=Get-FileHash $f
                        $props=@{
                            Name=$f.name
                            Path=$HashFileObj.Path
                            Hash=$HashFileObj.Hash
                            HashingAlgorithm=$HashFileObj.Algorithm
                        }
                        $Obj=New-Object -TypeName psobject -Property $props
                        $FileHashArrList.Add($Obj)  | Out-Null
                    }
                    $FileDuplicatesArrList=New-Object "System.Collections.ArrayList"
                    if($File)
                    {
                        #Get Hash for the base file
                        $BaseFileHash=Get-FileHash $File
                        #Compare base file Hash to Allfiles hash table
                        $BaseFileHash | Add-Member -NotePropertyName Name -NotePropertyValue $($File.split('\')[-1])
                        $BaseFileHash | Add-Member -NotePropertyName Status -NotePropertyValue BaseFile
                        
                        $BaseFileHash =$BaseFileHash | Select-Object Hash, Name, path, @{l="HashingAlgorithm";e={$_.Algorithm}}, Status

                        $FileDuplicatesArrList.Add($BaseFileHash) | Out-Null
                        $FileDuplicates=$FileHashArrList | Where-Object {$_.hash -eq $BaseFileHash.Hash}
                        
                        foreach($fd in $FileDuplicates){
                            $fd | Add-Member -NotePropertyName Status -NotePropertyValue Duplicate
                        
                            $FileDuplicatesArrList.Add($fd) | Out-Null
                        }

                        $FileDuplicatesArrList | Select-Object status, Name, path, Hash,HashingAlgorithm

                    }else{
                        # Identify identical hashes in All Files has table
                        $FileDuplicates=$FileHashArrList | Group-Object Hash | Where-Object {$_.Group.count -gt 1} -OutVariable Duplicates | Select-Object -ExpandProperty Group
                        Write-Verbose "There are $($Duplicates.Count) file(s) duplicates."
                        $FileDuplicatesArrList.Add($($FileDuplicates | Select-Object   Hash,Name, path,HashingAlgorithm)) | Out-Null
                        $FileDuplicatesArrList
                    }
                    
                    
                }else{
                    Write-Verbose "Cannot find path $Path because it does not exist"
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

#endregion


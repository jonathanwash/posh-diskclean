<# 
.SYNOPSIS 
    Cleans the disk of files and fodlers that can be removed.
.DESCRIPTION 
    Optionally empties the recycle bin, user and Windows temporary folder, custom files and folders and run the Windows Disk Cleanup Tool.
.NOTES 
    Idea based on the Disk_Cleanup_Tool.ps1 by Aman Dhally from Microsoft Script Center 
    (https://gallery.technet.microsoft.com/scriptcenter/Disk-Cleanup-Using-98ad13bc) but script completely rewritten.
    
    Note that this script will pass on the -ErrorAction and the -Verbose argument passed to the script. 
    Without -Verbose no output other than errors will be displayed. To stop errors from being display call the script with -ErrorAction SilentlyContinue

    The Windows Disk Cleanup Tool window will display when this is run. There is no way to run this tool in the background that I have found. 

    File Name   : posh-diskclean.ps1  
    Author      : Paul Broadwith (paul@pauby.com)
	History     : 1.0 - 14/09/15 - Initial version
.LINK 
    Github - https://github.com/pauby
    Script Github - https://github.com/pauby/posh-diskclean
.PARAMETER EmptyRecycleBin
    Switch to empty the Recycle Bin.
.PARAMETER EmptyUserTemp 
    Switch to empty the users temporary folder.
.PARAMETER EmptyWinTemp
    Switch to empty the Windows Temporary folder.
.PARAMETER OtherFiles
    Array of files to remove - is passed directly to Remove-Item so wildcards can be used.
.PARAMETER OtherFolders   
    Array of folders to empty and remove.
.PARAMETER DiskCleanTool
    Specifies a SageRun value to run the Windows Disk Cleanup Tool with (see https://support.microsoft.com/en-us/kb/253597)  
.EXAMPLE 
    .\posh-diskclean.ps1 -EmptyRecycleBin -EmptyWinTemp -EmptyUserTemp

    Empty the Recycle Bin, the Windows TEMP folder and the users TEMP folder.
.EXAMPLE 
    .\posh-diskclean.ps1 -EmptyRecycleBin -OtherFiles @("c:\test*.txt","c:\video*.mp4") -OtherFolders @("c:\temp",c:\admintools") -DiskCleanTool 6          

    Empty the Recycle Bin, remove custom set of files and folders asnd run the Windows Disk Cleanup Tool with SageRun value of 6.
#> 
[CmdletBinding()]
 
Param (
    [switch]$EmptyRecycleBin,

    [switch]$EmptyUserTemp,

    [switch]$EmptyWinTemp,

    [ValidateNotNullOrEmpty()]
    [array]$OtherFiles,

    [ValidateNotNullOrEmpty()]
    [array]$OtherFolders,

    [ValidateRange(0,65535)]
    [int]$DiskCleanTool
)

# See http://baldwin-ps.blogspot.be/2013/07/empty-recycle-bin-with-retention-time.html for info on this code
$objShell = New-Object -ComObject Shell.Application 
$objFolder = $objShell.Namespace(0xA)  

if ($EmptyRecycleBin)
{
    # Empty Recycle Bin # http://demonictalkingskull.com/2010/06/empty-users-recycle-bin-with-powershell-and-gpo/ 
    Write-Verbose "Emptying Recycle Bin..."
    $objFolder.items() | foreach { Remove-Item $_.path -Recurse -Force -Confirm:$false -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference} 
}

if ($EmptyUserTemp)
{
    # Empty users temp directory
    Write-Verbose "Emptying users temp folder at $env:TEMP"
    Remove-Item -Recurse  (Join-Path $env:TEMP "*") -Force -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference
}

if ($EmptyWinTemp)           
{
    # Empty Windows Temp Directory  
    $windowsTemp = Join-Path $env:SystemRoot "TEMP"
    Write-Verbose "Emptying Windows TEMP folder at $windowsTemp ..."
    Remove-Item $windowsTemp -Recurse -Force -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference
}

if ($otherFiles)
{
    # Remove Item in c:\Swtools folder excluding Checkpoint,landesk,useradmin folder ... remove  -what if it if you want to do it .. 
    # write-Host "Emptying $swtools folder."
    $otherFiles | foreach { Remove-Item $_ -Verbose:$VerbosePreference -Force -ErrorAction:$ErrorActionPreference }
}

if ($otherFolders)
{
    foreach ($folder in $otherFolders)
    {
        Remove-Item (Join-Path $folder "*") -Recurse -Verbose:$VerbosePreference -ErrorAction:$ErrorActionPreference
        Remove-Item $folder -Force -ErrorAction SilentlyContinue
    }
}

if ($DiskCleanTool)
{     
    # Running Disk Clean up Tool  
    Write-Verbose "Running Windows disk Clean up Tool with SageSet $DiskCleanTool ..."
    cleanmgr /sagerun:$DiskCleanTool
}

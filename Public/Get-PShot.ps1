<#
.SYNOPSIS
Captures a PowerShell Screenshot

.DESCRIPTION
Captures a PowerShell Screenshot and saves the image in the -PATH $Env:TEMP\PShot by default

.LINK
https://osdeploy.com/module/functions/get-pshot

.NOTES
21.1.23 Initial Release
#>
function Get-PShot {
    [CmdletBinding()]
    Param (
        #Directory where the screenshots will be saved
        #Default = $Env:TEMP\PShots
        [string]$Path = "$Env:TEMP\PShot",

        #Saved files will have a PShot prefix in the filename
        [string]$Prefix = 'PShot',

        #Delay before taking a PShot in seconds
        #Default: 0 (1 Count)
        #Default: 1 (>1 Count)
        [uint32]$Delay = 0,

        #Total number of screenshots to capture
        #Default = 1
        [uint32]$Count = 1,

        #Additionally copies the PShot to the Clipboard
        [switch]$Clipboard = $false
    )
    #======================================================================================================
    #	Gather
    #======================================================================================================
    $PShotInfo = $(Invoke-Expression (Get-Content (Get-Module -List PShot).Path -Raw))
    #======================================================================================================
    #	Adjust Delay
    #======================================================================================================
    if ($Count -gt '1') {if ($Delay -eq 0) {$Delay = 1}}
    #======================================================================================================
    #	Usage
    #======================================================================================================
    Write-Verbose '======================================================================================================'
    Write-Verbose "PShot $($PShotInfo.ModuleVersion)"
    Write-Verbose "$($PShotInfo.Description)"
    Write-Verbose '======================================================================================================'
    Write-Verbose 'Get-PShot [[-Path] <String>] [[-Prefix] <String>] [[-Delay] <UInt32>] [[-Count] <UInt32>] [-Clipboard]'
    Write-Verbose ''
    Write-Verbose '-Path       Directory where the screenshots will be saved'
    if (!(Test-Path "$Path")) {
        Write-Verbose '            Directory does not exist and will be created'
    }
    Write-Verbose '            Default = $Env:TEMP\PShots'
    Write-Verbose "            Value = $Path"
    Write-Verbose ''
    $DateString = (Get-Date).ToString('yyyyMMdd_HHmmss')
    Write-Verbose "-Prefix     Pattern in the file name $($Prefix)_$($DateString).png"
    Write-Verbose "            Default = PShot"
    Write-Verbose "            Value = $Prefix"
    Write-Verbose ''
    Write-Verbose '-Count      Total number of screenshots to capture'
    Write-Verbose '            Default = 1'
    Write-Verbose "            Value = $Count"
    Write-Verbose ''
    Write-Verbose '-Delay      Delay before capturing the screenshots in seconds'
    Write-Verbose '            Default = 0 (Count = 1) | Default = 1 (Count > 1)'
    Write-Verbose "            Value = $Delay"
    Write-Verbose ''
    Write-Verbose '-Clipboard  Additionally copies the screenshot to the Clipboard'
    Write-Verbose "            Value = $Clipboard"
    Write-Verbose '======================================================================================================'
    #======================================================================================================
    #	DPI Scaling
    #======================================================================================================
    $PShotDpiScaling = Get-PShotDpiScaling
    Write-Verbose "Screen DPI Scaling is $([Math]::round($PShotDpiScaling, 0)) Percent"
    #======================================================================================================
    #	Screen Resolution
    #======================================================================================================
    $PShotVirtualScreen = Get-PShotVirtualScreen
    Write-Verbose "Virtual Screen resolution is $($PShotVirtualScreen.Width) x $($PShotVirtualScreen.Height)"

    # Get Physical Screen Resolution
    [int32]$PShotVirtualScreenWidth = [math]::round($(($PShotVirtualScreen.Width * $PShotDpiScaling) / 100), 0)
    [int32]$PShotVirtualScreenHeight = [math]::round($(($PShotVirtualScreen.Height * $PShotDpiScaling) / 100), 0)
    Write-Verbose "Physical Screen resolution is $($PShotVirtualScreenWidth) x $($PShotVirtualScreenHeight)"
    #======================================================================================================
    #	Create Folder
    #======================================================================================================
    if (!(Test-Path "$Path")) {
        Write-Verbose "Creating PShot directory at $Path"
        New-Item -Path "$Path" -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    #======================================================================================================
    #	Delay
    #======================================================================================================
    foreach ($i in 1..$Count) {
        #======================================================================================================
        #	Delay
        #======================================================================================================
        Write-Verbose "Delay $Delay Seconds"
        Start-Sleep -Seconds $Delay
        #======================================================================================================
        #	Generate Bitmap
        #======================================================================================================
        $PShotBitmap = New-PShotBitmap
        $PShotGraphics = [System.Drawing.Graphics]::FromImage($PShotBitmap)
        $PShotGraphics.CopyFromScreen($PShotVirtualScreen.Left, $PShotVirtualScreen.Top, 0, 0, $PShotBitmap.Size)
        #======================================================================================================
        #	Copy the PShot to the Clipboard
        #   https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.clipboard.setimage?view=net-5.0
        #======================================================================================================
        if ($Clipboard) {
            Write-Verbose "Copying PShot to the Clipboard"
            Add-Type -Assembly System.Drawing
            Add-Type -Assembly System.Windows.Forms
            [System.Windows.Forms.Clipboard]::SetImage($PShotBitmap)
        }
        #======================================================================================================
        #	Save the PShot to File
        #   https://docs.microsoft.com/en-us/dotnet/api/system.drawing.image.tag?view=dotnet-plat-ext-5.0
        #======================================================================================================
        $DateString = (Get-Date).ToString('yyyyMMdd_HHmmss')
        $FileName = "$($Prefix)_$($DateString).png"
        Write-Verbose "Saving PShot $i of $Count to to $Path\$FileName"
        $PShotBitmap.Save("$Path\$FileName")
    }
    #======================================================================================================
    #	Close
    #======================================================================================================
    $PShotGraphics.Dispose()
    $PShotBitmap.Dispose()
    #======================================================================================================
}
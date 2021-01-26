<#
.SYNOPSIS
Captures a PowerShell Screenshot

.DESCRIPTION
Captures a PowerShell Screenshot and saves the image in the -Directory $Env:TEMP\PShot by default

.LINK
https://www.osdeploy.com/modules/pshot/usage

.NOTES
21.1.23 Initial Release

#>
function Get-PShot {
    [CmdletBinding()]
    Param (
        #Directory where the screenshots will be saved
        #Default = $Env:TEMP\PShots
        [string]$Directory = $null,

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
        [switch]$Clipboard = $false,

        #Screenshot of the Primary Display only
        [switch]$Primary = $false
    )
    begin {
        #======================================================================================================
        #	Gather
        #======================================================================================================
        $GetCommandNoun = Get-Command -Name Get-PShot | Select-Object -ExpandProperty Noun
        $GetCommandVersion = Get-Command -Name Get-PShot | Select-Object -ExpandProperty Version
        $GetCommandHelpUri = Get-Command -Name Get-PShot | Select-Object -ExpandProperty HelpUri
        $GetCommandModule = Get-Command -Name Get-PShot | Select-Object -ExpandProperty Module
        $GetModuleDescription = Get-Module -Name $GetCommandModule | Select-Object -ExpandProperty Description
        $GetModuleProjectUri = Get-Module -Name $GetCommandModule | Select-Object -ExpandProperty ProjectUri
        $GetModulePath = Get-Module -Name $GetCommandModule | Select-Object -ExpandProperty Path
        $MyPictures = (New-Object -ComObject Shell.Application).NameSpace('shell:My Pictures').Self.Path
        #======================================================================================================
        #	Adjust Delay
        #======================================================================================================
        if ($Count -gt '1') {if ($Delay -eq 0) {$Delay = 1}}
        #======================================================================================================
        #	Determine Task Sequence
        #======================================================================================================
        $LogPath = ''
        $SMSTSLogPath = ''
        try {
            $TSEnv = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction SilentlyContinue
            $IsTaskSequence = $true
            $LogPath = $TSEnv.Value('LogPath')
            $SMSTSLogPath = $TSEnv.Value('_SMSTSLogPath')
        }
        catch [System.Exception] {
            $IsTaskSequence = $false
            $LogPath = ''
            $SMSTSLogPath = ''
        }
        #======================================================================================================
        #	Set AutoPath
        #======================================================================================================
        if ($Directory -eq '') {
            if ($IsTaskSequence -and (Test-Path $LogPath)) {
                $AutoPath = Join-Path -Path $LogPath -ChildPath "PShots"
            } elseif ($IsTaskSequence -and (Test-Path $SMSTSLogPath)) {
                $AutoPath = Join-Path -Path $SMSTSLogPath -ChildPath "PShots"
            } elseif ($env:SystemDrive -eq 'X:') {
                $AutoPath = 'X:\PShots'
            } elseif (Test-Path $MyPictures) {
                $AutoPath = Join-Path -Path $MyPictures -ChildPath "PShots"
            } else {
                $AutoPath = "$Env:TEMP\PShots"
            }
        } else {
            $AutoPath = $Directory
        }
        #======================================================================================================
        #	Usage
        #======================================================================================================
        Write-Verbose '======================================================================================================'
        Write-Verbose "$GetCommandNoun $GetCommandVersion $GetCommandHelpUri"
        Write-Verbose $GetModuleDescription
        Write-Verbose "Module Path: $GetModulePath"
        Write-Verbose '======================================================================================================'
        Write-Verbose 'Get-PShot [[-Directory] <String>] [[-Prefix] <String>] [[-Delay] <UInt32>] [[-Count] <UInt32>] [-Clipboard] [-Primary]'
        Write-Verbose ''
        Write-Verbose '-Directory   Directory where the screenshots will be saved'
        Write-Verbose '             If this value is not set, Path will be automatically set between the following:'
        Write-Verbose '             Defaults = [LogPath\PShots] [_SMSTSLogPath\PShots] [My Pictures\Pshots] [$Env:TEMP\PShots]'
        Write-Verbose "             Value = $AutoPath"
        Write-Verbose ''
        $DateString = (Get-Date).ToString('yyyyMMdd_HHmmss')
        Write-Verbose "-Prefix      Pattern in the file name $($Prefix)_$($DateString).png"
        Write-Verbose "             Default = PShot"
        Write-Verbose "             Value = $Prefix"
        Write-Verbose ''
        Write-Verbose '-Count       Total number of screenshots to capture'
        Write-Verbose '             Default = 1'
        Write-Verbose "             Value = $Count"
        Write-Verbose ''
        Write-Verbose '-Delay       Delay before capturing the screenshots in seconds'
        Write-Verbose '             Default = 0 (Count = 1) | Default = 1 (Count > 1)'
        Write-Verbose "             Value = $Delay"
        Write-Verbose ''
        Write-Verbose '-Clipboard   Additionally copies the screenshot to the Clipboard'
        Write-Verbose "             Value = $Clipboard"
        Write-Verbose ''
        Write-Verbose '-Primary     Captures screenshot from the Primary Display only for Multiple Displays'
        Write-Verbose "             Value = $Primary"
        Write-Verbose '======================================================================================================'
        #======================================================================================================
        #	Load Assemblies
        #======================================================================================================
        Add-Type -Assembly System.Drawing
        Add-Type -Assembly System.Windows.Forms
        #======================================================================================================
    }
    process {
        foreach ($i in 1..$Count) {
            #======================================================================================================
            #	Determine Task Sequence (Process Block)
            #======================================================================================================
            $LogPath = ''
            $SMSTSLogPath = ''
            try {
                $TSEnv = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction SilentlyContinue
                $IsTaskSequence = $true
                $LogPath = $TSEnv.Value('LogPath')
                $SMSTSLogPath = $TSEnv.Value('_SMSTSLogPath')
            }
            catch [System.Exception] {
                $IsTaskSequence = $false
                $LogPath = ''
                $SMSTSLogPath = ''
            }
            #======================================================================================================
            #	Set AutoPath (Process Block)
            #======================================================================================================
            $AutoPathBackup = $AutoPath
            if ($Directory -eq '') {
                if ($IsTaskSequence -and (Test-Path $LogPath)) {
                    $AutoPath = Join-Path -Path $LogPath -ChildPath "PShots"
                } elseif ($IsTaskSequence -and (Test-Path $SMSTSLogPath)) {
                    $AutoPath = Join-Path -Path $SMSTSLogPath -ChildPath "PShots"
                } elseif ($env:SystemDrive -eq 'X:') {
                    $AutoPath = 'X:\PShots'
                } elseif (Test-Path $MyPictures) {
                    $AutoPath = Join-Path -Path $MyPictures -ChildPath "PShots"
                } else {
                    $AutoPath = "$Env:TEMP\PShots"
                }
            } else {
                $AutoPath = $Directory
            }
            Write-Verbose "AutoPath is set to $AutoPath"
            #======================================================================================================
            #	AutoPathBackup
            #======================================================================================================
            if ($AutoPathBackup -ne $AutoPath) {
                #Path changed, so need to move the content from the previous AutoPath
            }
            #======================================================================================================
            #	Determine AutoPath
            #======================================================================================================
            if (!(Test-Path "$AutoPath")) {
                Write-Verbose "Creating snapshot directory at $AutoPath"
                New-Item -Path "$AutoPath" -ItemType Directory -Force -ErrorAction Stop | Out-Null
            }
            #======================================================================================================
            #	DPI Scaling
            #======================================================================================================
            $PShotDpiScaling = Get-PShotDpiScaling
            Write-Verbose "Screen DPI Scaling is $([Math]::round($PShotDpiScaling, 0)) Percent"
            #======================================================================================================
            #	Screen Resolution
            #======================================================================================================
            if ($Primary) {
                Write-Verbose "Gathering Primary Display only"
                $PShotScreen = Get-PShotPrimaryScreen  
            } else {
                $PShotScreen = Get-PShotVirtualScreen
            }
            Write-Verbose "Virtual Screen resolution is $($PShotScreen.Width) x $($PShotScreen.Height)"
    
            # Get Physical Screen Resolution
            [int32]$PShotScreenWidth = [math]::round($(($PShotScreen.Width * $PShotDpiScaling) / 100), 0)
            [int32]$PShotScreenHeight = [math]::round($(($PShotScreen.Height * $PShotDpiScaling) / 100), 0)
            Write-Verbose "Physical Screen resolution is $($PShotScreenWidth) x $($PShotScreenHeight)"
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
            $PShotGraphics.CopyFromScreen($PShotScreen.Left, $PShotScreen.Top, 0, 0, $PShotBitmap.Size)
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
            Write-Verbose "Saving PShot $i of $Count to to $AutoPath\$FileName"
            $PShotBitmap.Save("$AutoPath\$FileName")
            #======================================================================================================
            #	Close
            #======================================================================================================
            $PShotGraphics.Dispose()
            $PShotBitmap.Dispose()
            #======================================================================================================
            #	Return Get-Item
            #======================================================================================================
            Get-Item "$AutoPath\$FileName"
            #======================================================================================================
        }
    }
    End {}
}
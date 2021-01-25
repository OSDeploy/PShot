function Get-PShotDpiScaling {
  [CmdletBinding()]
  Param ()

  #Add-Type -Assembly System.Drawing
    # Get DPI Scaling
    #[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

  Add-Type @'
using System; 
using System.Runtime.InteropServices;
using System.Drawing;

public class DPI {  
  [DllImport("gdi32.dll")]
  static extern int GetDeviceCaps(IntPtr hdc, int nIndex);

  public enum DeviceCap {
  VERTRES = 10,
  DESKTOPVERTRES = 117
  } 

  public static float scaling() {
  Graphics g = Graphics.FromHwnd(IntPtr.Zero);
  IntPtr desktop = g.GetHdc();
  int LogicalScreenHeight = GetDeviceCaps(desktop, (int)DeviceCap.VERTRES);
  int PhysicalScreenHeight = GetDeviceCaps(desktop, (int)DeviceCap.DESKTOPVERTRES);

  return (float)PhysicalScreenHeight / (float)LogicalScreenHeight;
  }
}
'@ -ReferencedAssemblies 'System.Drawing.dll' -ErrorAction Stop
  Return [DPI]::scaling() * 100
}
function Get-PShotPrimaryScreen {
  [CmdletBinding()]
  Param ()

  Add-Type -Assembly System.Windows.Forms
  Return [System.Windows.Forms.SystemInformation]::PrimaryScreen
}
function Get-PShotVirtualScreen {
  [CmdletBinding()]
  Param ()

  Add-Type -Assembly System.Windows.Forms
  Return [System.Windows.Forms.SystemInformation]::VirtualScreen
}
function New-PShotBitmap {
  [CmdletBinding()]
  Param ()
  
  Return New-Object System.Drawing.Bitmap $PShotScreenWidth, $PShotScreenHeight
}
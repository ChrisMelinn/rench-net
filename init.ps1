# From http://docs.nuget.org/docs/creating-packages/creating-and-publishing-a-package


# Init.ps1 runs the first time a package is installed in a solution.
#    o If the same package is installed into additional projects in the solution, 
#      the script is not run during those installations.
#    o The script also runs every time the solution is opened. For example, 
#      if you install a package, close Visual Studio, and then start Visual Studio 
#      and open the solution, the Init.ps1 script runs again.
 
#    These are the parameters that NuGet will pass into the init.ps1 script 
#       $installPath is the path to the folder where the package is installed
#       $toolsPath is the path to the tools directory in the folder where the package is installed
#       $package is a reference to the package object

param($installPath, $toolsPath, $package)

Import-Module (Join-Path $toolsPath GetTools.psm1)
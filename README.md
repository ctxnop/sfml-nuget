# sfml-nuget
Create NuGet's package for SFML.

# Prerequisite

- The CoApp toolset (http://coapp.org/)

# How to

You just have to run the sfml-nuget.ps1 script in a powershell instance.
It will download each needed files and output nupkg files in the "repository" folder.

Optional :
You may want to modify some variables to select the sfml version, generate only specific modules, etc... (You should know what your are doing, I won't answer any question about custom packages).
You can remove the "delete.me" file from the sfml-system-[version].nupkg archive (located at \build\native\include\)

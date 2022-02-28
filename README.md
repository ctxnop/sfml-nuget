# Archived

The SFML team asked me to take ownership on nuget packages a long time ago. Unfortunately it seems that they gave up on releasing new packages.
[Kosmotema](https://github.com/kosmotema) [forked](https://github.com/kosmotema/sfml-nuget) this project and updated it up to 2.5.1's version.
Maybe, someday, I will take time to update it to last version.

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

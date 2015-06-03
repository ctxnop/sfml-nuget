# sfml-nuget
Create NuGet's package for SFML.

# How to
1 - Download every SFML packages (each Visual Studio versions for both x86 and x64).
2 - Extract every packages.
3 - Move files following the directory structure you can find in *.autopkg files.
4 - Add a "delete.me" file in the include directory. It's a bug workaround, you need it to prevent nuget to remove the "include/SFML" subdirectory.
4 - Run the create-nuget.ps1 script.
5 - Packages are generated in the repository folder.
6 - Optional: Remove the "delete.me" file from the system package.
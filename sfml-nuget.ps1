﻿#
# sfml-nuget.ps1
#
# SFML nuget packages generation variable
$sfml_module_list = "system", "window", "graphics", "audio", "network"
$sfml_dowbload_url = "http://www.sfml-dev.org/files/"
$sfml_msvc_versions = "vc11", "vc12", "vc14"
$sfml_platforms_bits = "32", "64"
$sfml_version = "2.4.0"
$platforms = "x86", "x64"
$toolchains = "v110", "v120", "v140"
$configurations = "debug", "release"
$linking = "static", "dynamic"
$dependencies = @{}
$dependencies.Add("window", "system")
$dependencies.Add("graphics", ("window", "system"))
$dependencies.Add("audio", "system")
$dependencies.Add("network", "system")

# SFML Packages variables
$sfml_authors = "Laurent Gomila"
$sfml_owners =  "Laurent Gomila"
$sfml_licence_url = "http://www.sfml-dev.org/license.php"
$sfml_project_url = "http://www.sfml-dev.org"
$sfml_icon_url = "http://www.sfml-dev.org/images/sfml-icon.png"
$sfml_require_license_acceptance = "false"
$sfml_summary = "SFML provides a simple interface to the various components of your PC, to ease the development of games and multimedia applications. It is composed of five modules: system, window, graphics, audio and network."
$sfml_description = "SFML provides a simple interface to the various components
		of your PC, to ease the development of games and multimedia applications.
		It is composed of five modules: system, window, graphics, audio and network.

        With SFML, your application can compile and run out of the box on the most
		common operating systems: Windows, Linux, Mac OS X and soon Android & iOS.

        SFML has official bindings for the C and .Net languages. And thanks to its
		active community, it is also available in many other languages such as Java,
		Ruby, Python, Go, and more."

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

function PackageHeader($pkgName)
{
	$currentYear = (Get-Date).Year
	return "configurations {
	UserPlatformToolset {
	    // Needed because autopackage lacks VS2015 support
        	key = ""PlatformToolset"";
        	choices: ""v100,v110,v120,v140"";
	};
}

nuget {
	nuspec {
		id = sfml-$pkgname;
		title: sfml-$pkgname;
		version: $sfml_version.0;
		authors: { $sfml_authors };
		owners: { $sfml_owners };
		licenseUrl: ""$sfml_licence_url"";
		projectUrl: ""$sfml_project_url"";
		iconUrl: ""$sfml_icon_url"";
		requireLicenseAcceptance:$sfml_require_license_acceptance;
		summary: ""$sfml_summary"";
		description: @""$sfml_description"";
		releaseNotes: ""Release of SFML $sfml_version libraries"";
		copyright: Copyright $currentYear;
		tags: { sfml, native, CoApp };
	}
	
	#output-packages {
		default : `${pkgname};
		redist : `${pkgname}.redist;
		symbols : `${pkgname}.symbols;
	}"
}

function AddMainFile()
{
	$datas = ""
	foreach($p in $platforms)
	{
		foreach($v in $toolchains)
		{
			foreach($c in $configurations)
			{
					$datas += "		[$p,$v,$c] {"
					$libfile = "			lib += `${SRC}bin\$p\$v\$c\lib\sfml-main"
					if ($c -eq "debug")
					{
						$libfile += "-d"
					}
					$libfile += ".lib;"
					$datas += "
$libfile
		}

"
			}
		}
	}
	return $datas
}

function AddFiles($pkgName)
{
	$datas = ""
	foreach($p in $platforms)
	{
		foreach($v in $toolchains)
		{
			foreach($c in $configurations)
			{
				foreach($l in $linking)
				{
					$datas += "		[$p,$v,$c,$l] {"
					$libfile = "			lib += `${SRC}bin\$p\$v\$c\lib\sfml-$pkgName"
					$binfile = "			bin += `${SRC}bin\$p\$v\$c\bin\sfml-$pkgName"
					if ($l -eq "static")
					{
						$libfile += "-s"
					}
					if ($c -eq "debug")
					{
						$libfile += "-d"
						$binfile += "-d"
					}
					$libfile += ".lib;"
					$binfile += "-2.dll;"
					$datas += "
$libfile"

					if ($l -eq "dynamic")
					{
						$datas += "
$binfile"
					}
					$datas += "
		}
"
				}
			}
		}
	}
	return $datas
}

function AddDependencies($pkgName)
{
	if (-not $dependencies.ContainsKey($pkgName))
	{
		return ""
	}
	$datas += "

	dependencies {
		packages : {"
	foreach($p in $dependencies[$pkgName])
	{
		$datas += "
			sfml-$p/$sfml_version.0,"
	}
	$datas = $datas.TrimEnd(",")
	$datas += "
		};
	}"
	return $datas
}

function GeneratePackage($pkgName)
{
	$autopkg = PackageHeader($pkgName)
	$autopkg += AddDependencies($pkgName)
	$autopkg += "

	files {
		#defines {
			SRC = sources\;
		}

"
	if ($pkgName -eq "system")
	{
		$autopkg += "		nestedInclude: {
			#destination = `${d_include};
			""`${SRC}include\**""
		};

"
		$autopkg += AddMainFile
	}
	$autopkg += AddFiles($pkgName)
	if($pkgName -eq "system")
	{
		$autopkg += "		[x86] {
			lib += `${SRC}ext\lib\x86\*.lib;
			bin += `${SRC}ext\bin\x86\*.dll;
		}

		[x64] {
			lib += `${SRC}ext\lib\x64\*.lib;
			bin += `${SRC}ext\bin\x64\*.dll;
		}
"
	}
	$autopkg += "	};

	targets {
		Defines += HAS_SFML;
		[static]
			Defines += SFML_STATIC;
	}
}"
	$autopkg | Out-File "sfml-$pkgName.autopkg"
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

function CreateDirectory($dirName)
{
	if (-not (Test-Path $dirName)){
		New-Item -ItemType Directory -Force -Path "$dirName" | Out-Null
	}
}

function CreateFile($fileName)
{
	if (-not (Test-Path $fileName)){
		New-Item -ItemType File -Force -Path "$fileName" | Out-Null
	}
}
########## Main ##########

foreach($m in $sfml_module_list)
{
	Write-Host "Generating sfml-$m.autopkg..."
	GeneratePackage($m)
}

CreateDirectory("$dir\temp")
CreateDirectory("$dir\sources")
CreateDirectory("$dir\sources\include")
#CreateDirectory("$dir\sources\doc")
CreateFile("$dir\sources\include\delete.me")
CreateDirectory("$dir\distfiles")
foreach($platform in $sfml_platforms_bits) {
	foreach ($msvc in $sfml_msvc_versions) {
		$p = "x86"
		if ($platform -eq "64") { $p = "x64" }
		$t = $msvc.Replace("c", "") + "0"

		$filename = "SFML-$sfml_version-windows-$msvc-$platform-bit.zip"
		$outfile = "$dir\distfiles\$filename"
		$fileuri = $sfml_dowbload_url + $filename
		if (-not (Test-Path $outfile)){
			Write-Host "Downloading $filename..."
			$webclient = New-Object System.Net.WebClient
			$webclient.DownloadFile($fileuri, $outfile)
		}
		Write-Host "Extracting $filename..."
		Unzip "$outfile" "$dir\temp"
		$zip = "$dir\temp\SFML-$sfml_version"
		
		CreateDirectory("$dir\sources\ext\lib\$p\")
		CreateDirectory("$dir\sources\ext\bin\$p\")
		CreateDirectory("$dir\sources\bin\$p\$t\debug\bin\")
		CreateDirectory("$dir\sources\bin\$p\$t\release\bin\")
		CreateDirectory("$dir\sources\bin\$p\$t\debug\lib\")
		CreateDirectory("$dir\sources\bin\$p\$t\release\lib\")

		Copy-Item "$zip\include\*" "$dir\sources\include" -Force -Recurse | Out-Null
		#Copy-Item "$zip\doc\*" "$dir\sources\doc" -Force -Recurse | Out-Null
		Move-Item "$zip\bin\sfml-*-d-2.dll" "$dir\sources\bin\$p\$t\debug\bin\" -Force | Out-Null
		Move-Item "$zip\bin\sfml-*.dll" "$dir\sources\bin\$p\$t\release\bin\" -Force | Out-Null
		Move-Item "$zip\bin\*.dll" "$dir\sources\ext\bin\$p\" -Force | Out-Null
		Move-Item "$zip\lib\sfml-*-d.lib" "$dir\sources\bin\$p\$t\debug\lib\" -Force | Out-Null
		Move-Item "$zip\lib\sfml-*.lib" "$dir\sources\bin\$p\$t\release\lib\" -Force | Out-Null
		Move-Item "$zip\lib\*.lib" "$dir\sources\ext\lib\$p\" -Force | Out-Null
		Remove-Item "$zip" -Recurse | Out-Null
	}
 }

New-Item -ItemType Directory -Force -Path "$dir\repository" | Out-Null
cd "$dir\repository"
Get-ChildItem "../" -Filter *.autopkg | `
Foreach-Object{
	Write-Host "Generating Nuget Package from $_"
	Write-NuGetPackage ..\$_ | Out-Null
	Remove-Item ..\$_ | Out-Null
}
Write-Host "Cleaning..."
Remove-Item *.symbols.* | Out-Null
cd ..
Remove-Item "$dir\temp" -Recurse | Out-Null
#Remove-Item "$dir\sources" -Recurse | Out-Null
Write-Host "Done!"

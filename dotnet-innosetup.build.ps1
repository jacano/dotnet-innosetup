<#
.Synopsis
	Build script, https://github.com/nightroman/Invoke-Build
#>

param(
	[ValidateSet('Debug', 'Release')]
	[string]$Configuration = 'Release'
)

task download {
	$installer = ".\obj\is.exe"
	if (-not (Test-Path $installer)) {
		$ProgressPreference = 'SilentlyContinue'
		Invoke-WebRequest "https://jrsoftware.org/download.php/is.exe" -OutFile $installer
		& $installer /silent /DIR=.\is /CURRENTUSER
	}

	$idpSetup = ".\download\idpsetup-1.5.1.exe"
	& $idpSetup /silent /DIR=.\idp /CURRENTUSER
}

task build {
	exec { dotnet build -c $Configuration }
}

task clean {
	remove bin, obj
}

task pack build, {
	exec { dotnet pack -c $Configuration --no-build }
}

task test pack, {
	pushd .\obj
	$testDir = "a test directory"
	rm $testDir -Force -Recurse -ErrorAction SilentlyContinue
	mkdir $testDir
	pushd $testDir
	exec { dotnet new tool-manifest }
	remove C:\Users\${env:Username}\.nuget\packages\dotnet-innosetup
	exec { dotnet tool install dotnet-innosetup --add-source ..\..\nupkg }
	dotnet iscc /?
	popd
	popd
}

# Synopsis: Default task.
task . build

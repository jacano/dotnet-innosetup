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

task getVersion {
	$script:Version = [string] (get-item .\is\unins000.exe).VersionInfo.ProductVersion
	Write-Host $script:Version
}

task build getVersion, {
	exec { dotnet build -c $Configuration "-p:Version=${script:version}" }
}

task clean {
	remove bin, obj
}

task pack build, {
	exec { dotnet pack -c $Configuration --no-build  "-p:Version=${script:version}" }
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

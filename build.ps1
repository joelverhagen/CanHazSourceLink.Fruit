$artifacts = Join-Path $PSScriptRoot "artifacts"
if (Test-Path $artifacts) {
    Remove-Item $artifacts -Recurse -Force
}
New-Item $artifacts -ItemType Directory | Out-Null

$nuget = Join-Path $artifacts "nuget.exe"
$ProgressPreference = "SilentlyContinue"
Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile $nuget

$packages = Join-Path $artifacts "packages"
& $nuget install CanHazSourceLink.Apples -Version 1.0.0 -OutputDirectory $packages -Source https://api.nuget.org/v3/index.json
& $nuget install CanHazSourceLink.Oranges -version 1.0.0 -OutputDirectory $packages -Source https://api.nuget.org/v3/index.json

$applesSnupkg = (Join-Path $artifacts "canhazsourcelink.apples.1.0.0.zip")
$orangesSnupkg = (Join-Path $artifacts "canhazsourcelink.oranges.1.0.0.zip")

$snupkgUrl = "https://globalcdn.nuget.org/symbol-packages"
Invoke-WebRequest "$snupkgUrl/canhazsourcelink.apples.1.0.0.snupkg" -OutFile $applesSnupkg
Invoke-WebRequest "$snupkgUrl/canhazsourcelink.oranges.1.0.0.snupkg" -OutFile $orangesSnupkg

$combinedSnupkg = Join-Path $artifacts "snupkg"
Expand-Archive $applesSnupkg -DestinationPath $combinedSnupkg -Force
Expand-Archive $orangesSnupkg -DestinationPath $combinedSnupkg -Force

$combinedNupkg = Join-Path $artifacts "nupkg/lib/net5.0"
if (!(Test-Path $combinedNupkg)) {
    New-Item $combinedNupkg -ItemType Directory | Out-Null
}
Copy-Item `
    -Path (Join-Path $packages "CanHazSourceLink.Apples.1.0.0/lib/net5.0/*.dll") `
    -Destination $combinedNupkg `
    -Recurse
Copy-Item `
    -Path (Join-Path $packages "CanHazSourceLink.Oranges.1.0.0/lib/net5.0/*.dll") `
    -Destination $combinedNupkg `
    -Recurse

& $nuget pack (Join-Path $PSScriptRoot "CanHazSourceLink.Fruit.nuspec") -OutputDirectory $artifacts
& $nuget pack (Join-Path $PSScriptRoot "CanHazSourceLink.Fruit.snupkg.nuspec") -OutputDirectory (Join-Path $artifacts "snupkg")
Move-Item `
    -Path (Join-Path $artifacts "snupkg/CanHazSourceLink.Fruit.1.0.0.nupkg") `
    -Destination (Join-Path $artifacts "CanHazSourceLink.Fruit.1.0.0.snupkg") `
    -Force

param ([string] $ApiKey, [string]$Suffix = "")

#versioning info
$VERSION = "$(Get-Date -UFormat "%Y.%m%d").$($env:GITHUB_RUN_NUMBER)$($Suffix)"
$WORKINGDIR = Get-Location

#Build files

Write-Output "Building Version $VERSION"
dotnet restore
dotnet build -c Release /p:PackageVersion=$VERSION /p:Version=$VERSION

#pack into nuget files with the suffix if we have one

Write-Output "Publishing Version $VERSION"
dotnet pack ".\DragonFruit.Common.Data.Html\DragonFruit.Common.Data.Html.csproj" -o $WORKINGDIR -c Release -p:PackageVersion=$VERSION -p:Version=$VERSION

#recursively push all nuget files created

Get-ChildItem -Path $WORKINGDIR -Filter *.nupkg -Recurse -File -Name | ForEach-Object {
    dotnet nuget push $_ --api-key $ApiKey --source https://api.nuget.org/v3/index.json --force-english-output
}
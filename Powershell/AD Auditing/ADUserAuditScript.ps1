<#
    .SYNOPSIS
        Checks to see a list of accounts that match a certain critera .
    .DESCRIPTION
        Script connects to the active directory and using the DSInternals module, attempts to find accounts that don't align to cyber security standards.
    .NOTES
    Created: L Webb - Redshift Cyber Security
    Revision Date: 2023
    Version: 0.4
    License: MIT License
#>
param([switch]$Full)

$fefile = "$env:TEMP\fdoutput.txt"
$ffile = "$env:TEMP\foutput.txt"
$bfile = "$env:TEMP\boutput.txt"
$certpath = "RS-ADA.cer"
$fzip = "$($ENV:USERProfile)\Desktop\fzip.zip"
$bzip = "$($ENV:USERProfile)\Desktop\bzip.zip"

$psver = powershell -command "(Get-Variable PSVersionTable -ValueOnly).PSVersion.Major" 
$psmin = 4
if ($psmin -lt $psver) {
    Write-Host "High enough version of powershell installed" -ForegroundColor Green
}
else {
    Write-Host "Version of powershell is to low, Powershell 5 or higher is required" -ForegroundColor Red
    Pause
    exit 1
}
if (Get-Module -ListAvailable -Name DSInternals) {
    Write-Host "DSInternals installed, Continuing....."
} 
else {
    Write-Host "DSInternals module is not installed."
    Write-Host
    Write-Host "Run powershell as administrator and run 'Install-Module DSInternals'"
    Pause
    exit 1
}
if (Get-Module -ListAvailable -Name ActiveDirectory) {
    Write-Host "ActiveDirectory confirmed, Continuing....."
} 
else {
    Write-Host "ActiveDirectory module is not installed."
    Write-Host
    Write-Host 'Ensure the relevant RSAT tools are deployed or that this is run on a domain controller'
    Pause
    exit 1
}
do {
    $Pathcheck = Test-Path -Path $certpath
    if ($Pathcheck -eq $true) {
        Write-host "Certificate found" -ForegroundColor Green
    }else {
        Write-host "Wrong path to certificate" -ForegroundColor Red
        $certpath = Read-Host -Prompt 'Input the file path'
    }
} until ($Pathcheck -eq $true)

$ADControllerlister = (Get-ADDomainController -filter *).ComputerObjectDN -split ","
$DefaultPartition = (Get-ADDomainController -filter *).DefaultPartition
$HostDC = ($ADControllerlister | Select-String CN=) -replace '^CN='

function Convert-FromBinaryFileToBase64
{
[CmdletBinding()]
Param
(
[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)] $Path,
[Switch] $InsertLineBreaks
)

if ($InsertLineBreaks){ $option = [System.Base64FormattingOptions]::InsertLineBreaks }
else { $option = [System.Base64FormattingOptions]::None } 

[System.Convert]::ToBase64String( $(Get-Content -ReadCount 0 -Encoding Byte -Path $Path) , $option )
}    

if ($Full)
{
     write-host "Caution: Can take large amount of time to finish on large AD and can potentially generate a few hundread MB size file" -ForegroundColor Red
     Start-Sleep 2
     write-host "Starting to gather full audit data" -ForegroundColor Green
     Get-ADReplAccount -All -Server $HostDC -NamingContext $DefaultPartition | Out-File $fefile
     Get-ChildItem $fefile | Convert-FromBinaryFileToBase64 | Protect-CmsMessage -To $certpath -OutFile $ffile
     write-host "Audit data collected" -ForegroundColor Green
     Compress-Archive -Path $ffile -DestinationPath $fzip
     write-host "Audit data compressed" -ForegroundColor Green
     write-host "Doing house keeping...." -ForegroundColor Blue
     foreach ($i in 1..10) {
        $out = New-Object byte[] 1mb; 
        (New-Object Random).NextBytes($out); 
        [IO.File]::WriteAllBytes($fefile, $out)
        Clear-Content $ffile
        }
     foreach ($i in 1..10) {
        $out = New-Object byte[] 1mb; 
        (New-Object Random).NextBytes($out); 
        [IO.File]::WriteAllBytes($ffile, $out)
        Clear-Content $ffile
        }
     Remove-Item $ffile
     write-host "Location: $fzip" -ForegroundColor Yellow
     exit 0
}  else {
     write-host "Starting to gather basic audit data" -ForegroundColor Green
     Get-ADReplAccount -all -server $HostDC | format-custom -View pwdump | Protect-CmsMessage -To $certpath -Outfile $bfile 
     write-host "Audit data collected" -ForegroundColor Green
     Compress-Archive -Path $bfile -DestinationPath $bzip
     write-host "Audit data compressed" -ForegroundColor Green
     write-host "Doing house keeping...." -ForegroundColor Blue
     foreach ($i in 1..10) {
        $out = New-Object byte[] 1mb; 
        (New-Object Random).NextBytes($out); 
        [IO.File]::WriteAllBytes($bfile, $out)
        Clear-Content $bfile
        }
     Remove-Item $bfile
     write-host "Location: $bzip" -ForegroundColor Yellow
     exit 0
}
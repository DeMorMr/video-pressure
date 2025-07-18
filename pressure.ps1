$currentPath = $MyInvocation.MyCommand.Path | Split-Path -Parent
$inputFolder = Join-Path -Path $currentPath -ChildPath 'input'
$outputFolder = Join-Path -Path $currentPath -ChildPath 'output'
$ffmpeg = Join-Path -Path $currentPath -ChildPath 'ffmpeg\ffmpeg.exe'

$videoFiles = Get-ChildItem -Path $inputFolder -Recurse -File | Where-Object {
    $_.Extension -match '\.(mp4|mov|avi|mkv|flv|wmv|mpg|mpeg)$'
}

foreach ($file in $videoFiles) {
    Write-Host "------------Started next------------"
    Write-Host "Processing: $($file.FullName)"
    
    $relativePath = $file.FullName.Substring($inputFolder.Length)
    
    $outputPath = Join-Path -Path $outputFolder -ChildPath $relativePath
    
    $outputDirectory = [System.IO.Path]::GetDirectoryName($outputPath)
    if (-not (Test-Path -Path $outputDirectory)) {
        New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
    }

    $arg = '-hwaccel cuda -hwaccel_output_format cuda -i "' + $file.FullName + '" -c:v hevc_nvenc -preset p7 -b_ref_mode 1 -c:a copy "' + $outputPath + '"'
    
    Invoke-Expression "& `"$ffmpeg`" $arg"
}

Read-Host -Prompt "Press any key to exit..."
Write-Output "Remove all Python paths from environment"
$arrPath = $env:Path -split ";" | Where-Object {$_ -notMatch "Python"}

Write-Output "Add KiCad's python to environment"
$addPaths = "C:\scoop\apps\kicad\current\bin","C:\scoop\apps\kicad\current\bin\Scripts"
$env:Path = ($arrPath + $addPaths) -join ";"

python -c "import pcbnew; print(pcbnew.Version())"

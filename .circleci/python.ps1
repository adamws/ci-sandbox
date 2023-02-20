$removePath = 'Python'
$arrPath = $env:Path -split ';' | Where-Object {$_ -notMatch "$removePath"}

$addPath = 'C:\scoop\apps\kicad\current\bin'
$env:Path = ($arrPath + $addPath) -join ';'

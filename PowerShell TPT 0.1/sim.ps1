# sim_elements.ps1
# 10x10 sandbox using variables pXY for each pixel
# Element IDs: 0=EMPTY, 1=DUST, 2=SOLID, 3=WATER
# Commands: DRAW id x y | id x y | step | run N | print | var pXY | clear | help | quit

$width = 10
$height = 10

$EMPTY = 0
$DUST  = 1
$SOLID = 2
$WATER = 3

$rand = New-Object System.Random

# Initialize pXY and tempXY variables
for ($y=0; $y -lt $height; $y++) {
  for ($x=0; $x -lt $width; $x++) {
    $name = "p{0}{1}" -f $x,$y
    New-Variable -Name $name -Value $EMPTY -Scope Script -Force
    $tname = "temp{0}{1}" -f $x,$y
    New-Variable -Name $tname -Value $EMPTY -Scope Script -Force
  }
}

# Helpers
function Get-Cell([int]$x, [int]$y) {
  if ($x -lt 0 -or $x -ge $width -or $y -lt 0 -or $y -ge $height) { return $null }
  return (Get-Variable -Name ("p{0}{1}" -f $x,$y) -Scope Script -ValueOnly)
}
function Set-Cell([int]$x, [int]$y, [int]$val) {
  if ($x -lt 0 -or $x -ge $width -or $y -lt 0 -or $y -ge $height) { return $false }
  Set-Variable -Name ("p{0}{1}" -f $x,$y) -Value $val -Scope Script -Force
  return $true
}
function Get-Temp([int]$x, [int]$y) {
  return (Get-Variable -Name ("temp{0}{1}" -f $x,$y) -Scope Script -ValueOnly)
}
function Set-Temp([int]$x, [int]$y, [int]$val) {
  Set-Variable -Name ("temp{0}{1}" -f $x,$y) -Value $val -Scope Script -Force
}

# Render
function Render {
  cls
  for ($y=0; $y -lt $height; $y++) {
    $line = ""
    for ($x=0; $x -lt $width; $x++) {
      $v = Get-Cell $x $y
      switch ($v) {
        $EMPTY { $ch = "." }
        $DUST  { $ch = "D" }
        $SOLID { $ch = "S" }
        $WATER { $ch = "W" }
        default { $ch = "?" }
      }
      $line += $ch
      if ($x -lt $width-1) { $line += " " }
    }
    Write-Host $line
  }
  Write-Host ""
}

# Temp buffer helpers
function Init-Temp {
  for ($y=0; $y -lt $height; $y++) {
    for ($x=0; $x -lt $width; $x++) {
      Set-Temp $x $y $EMPTY
    }
  }
}
function Commit-Temp {
  for ($y=0; $y -lt $height; $y++) {
    for ($x=0; $x -lt $width; $x++) {
      $v = Get-Temp $x $y
      Set-Cell $x $y $v
    }
  }
}

# Element update functions

function Update-Solid([int]$x,[int]$y) {
  Set-Temp $x $y $SOLID
}

function Update-Dust([int]$x,[int]$y) {
  # Dust becomes stationary if it hits the ground row
  if ($y -eq $height - 1) {
    Set-Temp $x $y $DUST
    return
  }

  $by = $y + 1
  # 1) fall straight down
  if ($by -lt $height -and (Get-Cell $x $by) -eq $EMPTY -and (Get-Temp $x $by) -eq $EMPTY) {
    Set-Temp $x $by $DUST; return
  }

  # 2) diagonals (random order)
  $dirs = if ($rand.Next(0,2) -eq 0) { @(-1,1) } else { @(1,-1) }
  foreach ($d in $dirs) {
    $nx = $x + $d; $ny = $y + 1
    if ($nx -ge 0 -and $nx -lt $width -and $ny -lt $height) {
      if ((Get-Cell $nx $ny) -eq $EMPTY -and (Get-Temp $nx $ny) -eq $EMPTY) {
        Set-Temp $nx $ny $DUST; return
      }
    }
  }

  # 3) slide down slope: move into side cell only if the cell below that side is occupied
  foreach ($d in @(-1,1)) {
    $sx = $x + $d; $sy = $y
    $belowSideY = $y + 1
    if ($sx -ge 0 -and $sx -lt $width) {
      $belowSide = Get-Cell $sx $belowSideY
      if ($belowSide -ne $EMPTY -and (Get-Cell $sx $sy) -eq $EMPTY -and (Get-Temp $sx $sy) -eq $EMPTY) {
        Set-Temp $sx $sy $DUST; return
      }
    }
  }

  # 4) small random lateral single-step
  $dir = if ($rand.Next(0,2) -eq 0) { -1 } else { 1 }
  $nx = $x + $dir
  if ($nx -ge 0 -and $nx -lt $width -and (Get-Cell $nx $y) -eq $EMPTY -and (Get-Temp $nx $y) -eq $EMPTY) {
    Set-Temp $nx $y $DUST; return
  }
  $nx2 = $x - $dir
  if ($nx2 -ge 0 -and $nx2 -lt $width -and (Get-Cell $nx2 $y) -eq $EMPTY -and (Get-Temp $nx2 $y) -eq $EMPTY) {
    Set-Temp $nx2 $y $DUST; return
  }

  Set-Temp $x $y $DUST
}

function Update-Water([int]$x,[int]$y) {
  $by = $y + 1
  if ($by -lt $height -and (Get-Cell $x $by) -eq $EMPTY -and (Get-Temp $x $by) -eq $EMPTY) {
    Set-Temp $x $by $WATER; return
  }

  $dirs = if ($rand.Next(0,2) -eq 0) { @(-1,1) } else { @(1,-1) }
  foreach ($d in $dirs) {
    $nx = $x + $d; $ny = $y + 1
    if ($nx -ge 0 -and $nx -lt $width -and $ny -lt $height) {
      if ((Get-Cell $nx $ny) -eq $EMPTY -and (Get-Temp $nx $ny) -eq $EMPTY) {
        Set-Temp $nx $ny $WATER; return
      }
    }
  }

  for ($a=0; $a -lt 3; $a++) {
    $dir = if ($rand.Next(0,2) -eq 0) { -1 } else { 1 }
    $nx = $x + $dir
    if ($nx -ge 0 -and $nx -lt $width -and (Get-Cell $nx $y) -eq $EMPTY -and (Get-Temp $nx $y) -eq $EMPTY) {
      Set-Temp $nx $y $WATER; return
    }
  }

  Set-Temp $x $y $WATER
}

# Dispatcher
function Update-Frame {
  Init-Temp
  for ($y = $height - 1; $y -ge 0; $y--) {
    for ($x = 0; $x -lt $width; $x++) {
      $val = Get-Cell $x $y
      if ($val -eq $EMPTY) { continue }
      switch ($val) {
        $SOLID { Update-Solid $x $y }
        $DUST  { Update-Dust  $x $y }
        $WATER { Update-Water $x $y }
        default { Set-Temp $x $y $val }
      }
    }
  }
  Commit-Temp
}

# Commands
function Place-At($id,$x,$y) {
  if ($x -lt 0 -or $x -ge $width -or $y -lt 0 -or $y -ge $height) {
    Write-Host "Out of bounds. Use 0..$($width-1) for x and 0..$($height-1) for y."
    return
  }
  switch ($id) {
    1 { Set-Cell $x $y $DUST; Write-Host "Placed DUST at ($x,$y)." }
    2 { Set-Cell $x $y $SOLID; Write-Host "Placed SOLID at ($x,$y)." }
    3 { Set-Cell $x $y $WATER; Write-Host "Placed WATER at ($x,$y)." }
    0 { Set-Cell $x $y $EMPTY; Write-Host "Cleared ($x,$y)." }
    default { Write-Host "Unknown id. Use 0=EMPTY,1=DUST,2=SOLID,3=WATER." }
  }
}

function Show-Help {
  Write-Host "Commands:"
  Write-Host "  DRAW id x y  -> place element (example: DRAW 1 2 2 places DUST at x=2,y=2)"
  Write-Host "  id x y       -> shorthand to place element (example: 1 2 2)"
  Write-Host "  step         -> advance one frame"
  Write-Host "  run N        -> advance N frames"
  Write-Host "  print        -> render grid"
  Write-Host "  var pXY      -> show variable pXY value (example: var p22)"
  Write-Host "  clear        -> clear grid"
  Write-Host "  help         -> show this help"
  Write-Host "  quit         -> exit"
}

# Demo seed
Place-At 1 4 0
Place-At 1 5 0
Place-At 1 6 0
Place-At 2 7 7
Place-At 3 2 0
Render
Show-Help

while ($true) {
  $cmd = Read-Host -Prompt "cmd"
  if ([string]::IsNullOrWhiteSpace($cmd)) { continue }

  # split on whitespace (handles multiple spaces/tabs)
  $parts = $cmd.Trim() -split '\s+'
  if ($parts.Length -eq 0) { continue }

  $first = $parts[0].ToLower()

  if ($first -eq "quit") { break }
  elseif ($first -eq "help") { Show-Help; continue }
  elseif ($first -eq "print") { Render; continue }
  elseif ($first -eq "clear") {
    for ($y=0; $y -lt $height; $y++) { for ($x=0; $x -lt $width; $x++) { Set-Cell $x $y $EMPTY } }
    Write-Host "Grid cleared."
    continue
  } elseif ($first -eq "step") {
    Update-Frame; Render; continue
  } elseif ($first -eq "run") {
    # ensure $n exists before TryParse
    $n = 0
    if ($parts.Length -ge 2 -and [int]::TryParse($parts[1],[ref]$n)) {
      for ($i=0; $i -lt $n; $i++) { Update-Frame }
      Render
    } else { Write-Host "Usage: run N" }
    continue
  } elseif ($first -eq "var" -and $parts.Length -eq 2) {
    $vname = $parts[1]
    $gv = Get-Variable -Name $vname -Scope Script -ErrorAction SilentlyContinue
    if ($gv) { Write-Host "$vname = $($gv.Value)" } else { Write-Host "Variable $vname not found." }
    continue
  }

  # Accept "DRAW id x y"
  if ($first -eq "draw" -and $parts.Length -eq 4) {
    $id = 0; $x = 0; $y = 0
    $ok1 = [int]::TryParse($parts[1],[ref]$id)
    $ok2 = [int]::TryParse($parts[2],[ref]$x)
    $ok3 = [int]::TryParse($parts[3],[ref]$y)
    if ($ok1 -and $ok2 -and $ok3) {
      Place-At $id $x $y
      Render
      continue
    } else {
      Write-Host "Usage: DRAW id x y"
      continue
    }
  }

  # try shorthand "id x y"
  if ($parts.Length -eq 3) {
    $id = 0; $x = 0; $y = 0
    $ok1 = [int]::TryParse($parts[0],[ref]$id)
    $ok2 = [int]::TryParse($parts[1],[ref]$x)
    $ok3 = [int]::TryParse($parts[2],[ref]$y)
    if ($ok1 -and $ok2 -and $ok3) {
      Place-At $id $x $y
      Render
      continue
    }
  }

  Write-Host "Unknown command. Type 'help' for usage."
}

Write-Host "Exiting simulation."
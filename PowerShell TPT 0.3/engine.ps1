# Grid size
$W = 40
$H = 20

# Create grid
$grid = @(for ($y=0; $y -lt $H; $y++) {
    ,@(for ($x=0; $x -lt $W; $x++) { 0 })
})

$Paused = $false

function Render {
    Clear-Host
    for ($y=0; $y -lt $H; $y++) {
        $line = ""
        for ($x=0; $x -lt $W; $x++) {
            switch ($grid[$y][$x]) {
                0 { $line += " " }  # empty
                1 { $line += "*" }  # powder
                2 { $line += "~" }  # water
                3 { $line += "#" }  # solid
                4 { $line += ":" }  # gas
            }
        }
        $line
    }
    ""
    "Commands:"
    "  DRAW ID X Y"
    "  STEP"
    "  PAUSE"
    "  ? (help)"
    "  Or old format: ID X Y"
}

function Show-Help {
    Clear-Host
    "=== HELP ==="
    "Element IDs:"
    " 0 = Empty"
    " 1 = Powder  (*)"
    " 2 = Water   (~)"
    " 3 = Solid   (#)"
    " 4 = Gas     (:)"
    ""
    "Commands:"
    "  DRAW ID X Y   - place element"
    "  ID X Y        - old format"
    "  STEP          - run one tick"
    "  PAUSE         - toggle pause"
    "  ?             - show this menu"
    ""
    Read-Host "Press ENTER to return"
}

function Update {
    for ($y = $H-2; $y -ge 0; $y--) {
        for ($x = 0; $x -lt $W; $x++) {

            $cell = $grid[$y][$x]

            switch ($cell) {

                1 { # Powder (falls straight down)
                    if ($grid[$y+1][$x] -eq 0) {
                        $grid[$y+1][$x] = 1
                        $grid[$y][$x] = 0
                    }
                }

                2 { # Water (falls, then flows sideways)
                    $dirs = @(-1,0,1) | Get-Random
                    $nx = $x + $dirs

                    if ($grid[$y+1][$x] -eq 0) {
                        $grid[$y+1][$x] = 2
                        $grid[$y][$x] = 0
                    }
                    elseif ($nx -ge 0 -and $nx -lt $W -and $grid[$y][$nx] -eq 0) {
                        $grid[$y][$nx] = 2
                        $grid[$y][$x] = 0
                    }
                }

                3 { } # Solid

                4 { # Gas (rises upward, drifts sideways)
                    $dirs = @(-1,0,1) | Get-Random
                    $nx = $x + $dirs

                    if ($y -gt 0 -and $grid[$y-1][$x] -eq 0) {
                        $grid[$y-1][$x] = 4
                        $grid[$y][$x] = 0
                    }
                    elseif ($nx -ge 0 -and $nx -lt $W -and $grid[$y][$nx] -eq 0) {
                        $grid[$y][$nx] = 4
                        $grid[$y][$x] = 0
                    }
                }
            }
        }
    }
}

# Main loop
while ($true) {

    Render
    $input = Read-Host "Command"

    # HELP
    if ($input -eq "?") {
        Show-Help
        continue
    }

    # PAUSE toggle
    if ($input -eq "PAUSE") {
        $Paused = -not $Paused
        continue
    }

    # STEP
    if ($input -eq "STEP") {
        Update
        continue
    }

    # DRAW ID X Y
    if ($input -match "^DRAW\s+(\d+)\s+(\d+)\s+(\d+)$") {
        $id = [int]$Matches[1]
        $x  = [int]$Matches[2]
        $y  = [int]$Matches[3]

        if ($x -ge 0 -and $x -lt $W -and $y -ge 0 -and $y -lt $H) {
            $grid[$y][$x] = $id
        }
        continue
    }

    # OLD FORMAT: ID X Y
    if ($input -match "^\d+ \d+ \d+$") {
        $parts = $input -split " "
        $id = [int]$parts[0]
        $x  = [int]$parts[1]
        $y  = [int]$parts[2]

        if ($x -ge 0 -and $x -lt $W -and $y -ge 0 -and $y -lt $H) {
            $grid[$y][$x] = $id
        }
    }

    # Only update if NOT paused
    if (-not $Paused) {
        Update
    }
}
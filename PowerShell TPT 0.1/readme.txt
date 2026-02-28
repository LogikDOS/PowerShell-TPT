Made by LogikDOS 2026 PowerShell-TPT 0.1 > DO NOT JUST MOD AND PUBLISH ASK ME FIRST 
Tiktok: LogikDOS @worstbatchcodeguy





Simple Project Description — Falling Sand Sandbox (pure text)
What this is A tiny 10x10 falling-sand sandbox written in PowerShell and started with a small Batch file.
You control it by typing commands in the console. Each grid cell is a variable named pXY (for example p22 is x=2, y=2). The simulation updates in discrete frames.
How to run
1. 	Put start_sim.bat and sim_elements.ps1 in the same folder.
2. 	Double-click start_sim.bat or run it from a command prompt.
3. 	The script shows the grid and a prompt. Type commands and press Enter.
Coordinate system
• 	Zero-based coordinates: top-left is 0 0, bottom-right is 9 9.
• 	Use x then y (for example: DRAW 1 4 0 places an element at x=4, y=0).
Commands (simple)
• 	DRAW id x y    — place one cell (example: DRAW 1 2 2)
• 	id x y         — shorthand (example: 1 2 2)
• 	step           — advance one frame
• 	run N          — advance N frames (example: run 10)
• 	print          — show the grid now
• 	var pXY        — show the numeric value of variable pXY (example: var p22)
• 	clear          — clear the whole grid
• 	help           — show commands
• 	quit           — exit
Element IDs
• 	0 = EMPTY (.)
• 	1 = DUST (D)
• 	2 = SOLID (S)
• 	3 = WATER (W)
How the grid is stored
• 	Each cell is a script variable named pXY (x then y). Example: p00, p01, ..., p99.
• 	Values are small integers matching the element IDs above.
• 	A temporary buffer tempXY is used each frame to build the next state. After all cells are processed, temp becomes the new grid. This prevents mid-frame interference.
Update order and why it matters
• 	The engine updates cells from bottom row to top row.
• 	Bottom-to-top order lets particles fall in a single frame without immediately being processed again in the same frame. This produces natural gravity behavior.
Dust behavior (detailed)
• 	Goal: dust should fall and form pyramids when it piles up.
• 	Rules applied in Update-Dust:
1. 	If the cell below is empty, dust moves straight down into that cell.
2. 	If blocked, dust tries down-left or down-right in random order (this creates natural spreading).
3. 	If diagonals are blocked, dust attempts to slide onto a side cell only if the cell below that side is occupied. This rule encourages stable slopes and pyramid shapes: dust moves onto a side cell when that side has support beneath it.
4. 	If none of the above moves are possible, dust may perform a small random lateral single-step to reduce deadlocks.
5. 	If dust reaches the bottom row (y = 9), it becomes stationary and stays there.
• 	Why this forms pyramids: step 3 prevents dust from sliding off unsupported edges; dust only moves sideways onto cells that have support below, so piles build slopes instead of collapsing flat.
Water behavior (detailed)
• 	Water is more fluid and spreads:
1. 	If the cell below is empty, water falls straight down.
2. 	If blocked, water tries down-left or down-right (random order).
3. 	If still blocked, water attempts several lateral moves in random directions to spread horizontally.
4. 	Water does not become permanently fixed on the ground; it keeps moving if space is available.
Solid behavior
• 	Solid cells are immovable blocks. They are copied unchanged into the next frame.
Double buffering (temp buffer)
• 	During a frame, the script writes results into tempXY variables, not directly into pXY.
• 	After all cells are processed, tempXY values replace pXY values.
• 	This avoids conflicts where a particle moves and then is processed again in the same frame.
Why randomness is used
• 	Randomizing diagonal order and lateral choices removes directional bias (left vs right) and produces more natural, varied piles and flows.
Example session (quick)
• 	DRAW 1 4 0   (place dust at x=4,y=0)
• 	DRAW 1 5 0   (place dust at x=5,y=0)
• 	run 10       (advance 10 frames)
• 	DRAW 3 2 0   (place water at x=2,y=0)
• 	run 5
What it can do (short)
• 	Place single cells by command.
• 	Simulate gravity, diagonal moves, dust pyramid formation, and water spreading.
• 	Let you inspect individual cell variables (pXY).
What it cannot do (short)
• 	No mouse or GUI input; console only.
• 	No save/load or undo.
• 	Fixed 10x10 grid (small).
• 	No advanced physics (pressure, heat, reactions).
• 	No colored graphics (text characters only).
Tips for editing or extending
• 	To change behavior of an element, edit its Update- function (Update-Dust, Update-Water, Update-Solid). Each element is isolated so changes are easy.
• 	To make dust lock on top of solid blocks, add a rule: if the cell below is SOLID, set dust to stay.
• 	To add a brush or rectangle draw, extend the Place-At function to accept width/height and loop over the target area.
• 	To scale up the grid, replace per-cell variables with arrays for much better performance.
Simple internal flow (step-by-step)
1. 	Read command from user.
2. 	If command places cells, set pXY accordingly.
3. 	If command is step/run: for each frame do:
a. 	Initialize temp buffer to empty.
b. 	For y from bottom to top, for x left to right:
• 	Read pXY, call the element-specific update function which writes into tempXY.
c. 	After all cells processed, copy tempXY into pXY (commit).
4. 	Render the grid to the console (characters . D S W).
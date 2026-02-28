========================================
           POWDER TOY — GUIDE
========================================

1. THE PLANE
------------
The simulation runs on a 2D plane made of cells.
Each cell contains an element ID.

Element IDs:
0 = Empty   (nothing)
1 = Powder  (*)
2 = Water   (~)
3 = Solid   (#)
4 = Gas     (:)

The plane updates every cycle to simulate physics.


2. ELEMENT BEHAVIOR
-------------------

Powder (1)
- Falls straight down if the cell below is empty.

Water (2)
- Falls down if possible.
- If blocked, it randomly moves left or right.

Solid (3)
- Does not move at all.

Gas (4)
- Rises upward if possible.
- If blocked, it drifts left or right.


3. DRAWING ELEMENTS
-------------------

To place elements on the plane, use:

DRAW ID X Y

Examples:
DRAW 1 10 5   → place powder at (10,5)
DRAW 3 0 0    → place solid at top-left
DRAW 2 20 10  → place water at (20,10)

Old format also works:
ID X Y
Example:
1 10 5


4. SIMULATION CONTROLS
----------------------

STEP
- Runs one single physics update.

PAUSE
- Toggles pause on/off.
- When paused, the plane stops updating.
- You can still draw while paused.

?
- Shows the help menu with element IDs and commands.


5. COORDINATES
--------------

X = left to right
Y = top to bottom
(0,0) is the top-left corner.

Example:
DRAW 1 5 3
Places powder at:
- 5 cells from the left
- 3 cells from the top


6. LOOP SUMMARY
---------------

Each cycle:
1. The plane is drawn.
2. You type a command.
3. The command is processed.
4. If not paused, the physics update runs.
5. The cycle repeats.


7. QUICK SUMMARY
----------------

DRAW ID X Y  → place element
STEP         → update once
PAUSE        → toggle pause
?            → help menu

Powder falls.
Water flows.
Gas rises.
Solid stays still.
========================================
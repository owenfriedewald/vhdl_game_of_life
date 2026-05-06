# FPGA Conway's Game of Life

VHDL implementation of Conway's Game of Life for the Digilent Nexys 4 DDR board
using the onboard 100 MHz clock and VGA output. The displayed game area is a
40 by 30 cell grid, with each cell drawn as a 16 by 16 pixel square in a
640 by 480 VGA frame.

Authors: Owen Friedewald, Thomas Joswiak, Silas Barton

## Hardware

- Board: Digilent Nexys 4 DDR
- FPGA: Xilinx Artix-7
- Clock input: 100 MHz onboard clock
- Display output: VGA
- Tested display path: VGA output through a VGA-to-HDMI adapter to a monitor

## Repository Layout

- `src/` - synthesizable VHDL source files
- `constraints/` - XDC constraint files for the Nexys 4 DDR
- `sim/` - GHDL simulation testbenches
- `legacy/` - earlier VGA/reference files kept for comparison
- `docs/` - local notes, ignored by git

## Source Files

Use `vga_top_life` as the top-level entity.

Required VHDL files:

- `src/clock_gen.vhd` - divides the 100 MHz board clock to a 25 MHz VGA pixel clock
- `src/vga_timing.vhd` - generates VGA sync, visible-area flag, and pixel coordinates
- `src/tick_generator.vhd` - generates a slow Game of Life update pulse
- `src/game_of_life.vhd` - stores and updates the 40 by 30 Life grid
- `src/life_vga_pattern.vhd` - maps cells to VGA colors
- `src/vga_top_life.vhd` - top-level integration

Required XDC files:

- `constraints/Nexys-4-DDR-Master.xdc`
- `constraints/nexys4ddr_life_controls.xdc`

## Board Controls

- `SW[2:0]` selects update speed.
- `SW[3]` resets/reloads the Game of Life grid.
- `SW[5:4]` selects which seed pattern is loaded while reset is active.

Seed selection:

- `00` - mixed demo with a glider, blinker, block, and small ship
- `01` - oscillator demo
- `10` - fixed random-looking soup
- `11` - multiple gliders

The reset signal is driven from `SW[3]` instead of a pushbutton. The switch input
is registered before being used by the Game of Life logic, which avoids the
reset instability seen during board testing with the raw pushbutton input.

## Vivado Build Instructions

1. Open Vivado and create a new RTL project.
2. Select the Nexys 4 DDR target part/board. For the course board, the target
   part is the Artix-7 `xc7a100tcsg324` package.
3. Add all VHDL files from `src/` as design sources.
4. Add both files from `constraints/` as constraint sources.
5. Set `vga_top_life` as the top module.
6. Run synthesis.
7. Run implementation.
8. Generate the bitstream.
9. Open Hardware Manager, connect to the Nexys 4 DDR, and program the board.

Expected output after programming:

- VGA sync should lock on the monitor.
- A black background with gray grid lines should appear.
- Live cells should be drawn in green.
- Changing `SW[5:4]` and toggling reset with `SW[3]` should reload a different
  starting pattern.
- Changing `SW[2:0]` should change the update speed.

## Simulation

The design was also checked with testbenches. Simulation is not required to run the
project on the board, but the testbenches are included to verify the main logic
without rebuilding a bitstream.

## Notes

The final design was tested in Vivado through synthesis, implementation,
bitstream generation, and programming on the Nexys 4 DDR board. During hardware
testing, the reset input was changed from the center pushbutton to `SW[3]`
because the raw button input caused unreliable reload behavior on the displayed
grid, after which the switch input needed to be synchronized with the clock anyway.

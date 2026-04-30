# FPGA Conway's Game of Life

VHDL implementation of Conway's Game of Life for the Digilent Nexys 4 DDR board
with a Xilinx Artix-7 FPGA. The design uses an existing 640x480 VGA timing path
and renders a 40 by 30 Life grid with 16 by 16 pixel cells.

Authors: Owen Friedewald, Thomas Joswiak, Silas Barton

## Project Layout

- `src/` - synthesizable VHDL sources
- `constraints/` - Nexys 4 DDR XDC constraints
- `sim/` - GHDL testbenches
- `legacy/` - original/reference VGA files and old project artifacts
- `docs/` - local scratch notes, ignored by git

## Top Level

Use `vga_top_life` as the top-level entity.

Required source files:

- `src/clock_gen.vhd`
- `src/vga_timing.vhd`
- `src/tick_generator.vhd`
- `src/game_of_life.vhd`
- `src/life_vga_pattern.vhd`
- `src/vga_top_life.vhd`

Required constraints:

- `constraints/Nexys-4-DDR-Master.xdc`
- `constraints/nexys4ddr_life_controls.xdc`

## Board Controls

- `SW[2:0]` selects update speed.
- `SW[3]` resets the Game of Life grid and reloads the selected seed.
- `SW[5:4]` selects the seed pattern.

Seed selection:

- `00` - mixed demo with glider, blinker, block, and small ship
- `01` - oscillator demo
- `10` - fixed random-looking soup
- `11` - multiple gliders

## Simulation

The design was checked end-to-end with synthesis, implementation, bitstream, and FPGA output onto a VGA using a VGA to HDMI adapter on a monitor in the lab.
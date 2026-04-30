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

- `BTNC` resets the Game of Life grid and reloads the selected seed.
- `SW[2:0]` selects update speed.
- `SW[3]` pauses the simulation.
- `SW[5:4]` selects the seed pattern.

Seed selection:

- `00` - mixed demo with glider, blinker, block, and small ship
- `01` - oscillator demo
- `10` - fixed random-looking soup
- `11` - multiple gliders

## Simulation

The design was checked with GHDL using VHDL-2008. The existing `clock_gen.vhd`
uses older Synopsys arithmetic packages, so top-level elaboration uses
`-fsynopsys`.

Analyze and run the semantic tests:

```bash
ghdl -a --std=08 src/game_of_life.vhd
ghdl -a --std=08 src/tick_generator.vhd
ghdl -a --std=08 src/life_vga_pattern.vhd
ghdl -a --std=08 src/vga_timing.vhd

ghdl -a --std=08 sim/tb_game_of_life.vhd
ghdl -e --std=08 tb_game_of_life
ghdl -r --std=08 tb_game_of_life --assert-level=error

ghdl -a --std=08 sim/tb_life_vga_pattern.vhd
ghdl -e --std=08 tb_life_vga_pattern
ghdl -r --std=08 tb_life_vga_pattern --assert-level=error

ghdl -a --std=08 sim/tb_vga_timing.vhd
ghdl -e --std=08 tb_vga_timing
ghdl -r --std=08 tb_vga_timing --assert-level=error
```

Top-level elaboration check from the project root:

```bash
ghdl -a --std=08 src/game_of_life.vhd
ghdl -a --std=08 src/tick_generator.vhd
ghdl -a --std=08 src/life_vga_pattern.vhd
ghdl -a --std=08 src/vga_timing.vhd
ghdl -a --std=08 -fsynopsys src/clock_gen.vhd
ghdl -a --std=08 -fsynopsys src/vga_top_life.vhd
ghdl -e --std=08 -fsynopsys vga_top_life
```

## Vivado Notes

In Vivado, add the VHDL files from `src/`, add both XDC files from
`constraints/`, and set `vga_top_life` as the top module. The old grid-only VGA
files are kept under `legacy/` for reference.

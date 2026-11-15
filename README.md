# Sync FIFO – UVM Verification

UVM verification environment for a synchronous FIFO, built for the *Digital Verification using SystemVerilog & UVM* course (DUT by Kareem Waseem).

## Contents
- `FIFO.sv` – DUT (with the bug fixes documented inline)
- `FIFO_if.sv` – interface
- `FIFO_sva.sv` – SVA assertions module (bound in the top)
- `FIFO_sequence_item / sequence / sequencer / driver / mon / agent / config .sv` – UVM agent
- `FIFO_scoreboard.sv`, `FIFO_coverage.sv`, `FIFO_env.sv`, `FIFO_tb.sv`, `FIFO_top.sv`
- `run.do`, `src_files.list` – QuestaSim run script and file list
- `docs/Sync_FIFO_UVM_Verification_Report.pdf` – full verification report

## Run (QuestaSim)
```tcl
do run.do
```

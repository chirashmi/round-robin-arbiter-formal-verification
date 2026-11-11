# Formal Verification Results

## 1. Overview

This document summarizes the simulation and formal verification results of the parameterized handshake-based Round-Robin Arbiter.

The design was verified using SystemVerilog Assertions (SVA), SymbiYosys (SBY), Yosys, and Z3.

## 2. Properties Verified

| Property | Description |
|---|---|
| P1 | Grant is one-hot or zero |
| P2 | `grant_valid` correctly indicates whether a grant exists |
| P3 | Grant remains stable during backpressure |
| P4 | Round-robin pointer advances after an accepted transaction |
| P5 | Pointer remains unchanged when no transaction is accepted |
| P6 | Held grant is cleared after acceptance |
| P7 | Round-robin pointer remains within the valid requester range |

P1–P3 are implemented in the formal verification harness. P4–P7 are implemented inside the RTL under the `FORMAL` compilation condition.

## 3. Formal Verification Results

| Requesters | Formal Status | Remarks |
|---|---|---|
| 3 | PASS | Base case and induction successful |
| 4 | PASS | Formal proof successful |
| 5 | PASS | Base case and temporal induction successful |
| 6 | Inconclusive | Z3 terminated due to memory exhaustion |
| 10 | Inconclusive | Z3 terminated due to memory exhaustion |
| 16 | Inconclusive | Z3 terminated due to memory exhaustion |

### Verified configurations

- N = 3: Formal verification passed.
- N = 4: Formal verification passed.
- N = 5: Formal verification passed using sequential k-induction with Z3.
- The N = 5 proof completed with `DONE (PASS, rc=0)`.

### Inconclusive configurations

Formal verification attempts for N = 6, 10, and 16 encountered system memory limitations. Z3 processes were terminated by the operating system's out-of-memory mechanism.

These configurations are not classified as formal PASS or design failures. Their complete formal correctness remains unproven.

## 4. Simulation Results

Directed simulation:
- 13 checks passed.
- 0 checks failed.

Randomized simulation:

| Requesters | Cycles | Accepted Transfers | Backpressure Cycles | Stable-Grant Checks | Errors |
|---|---:|---:|---:|---:|---:|
| 3 | 200 | 99 | 101 | 101 | 0 |
| 4 | 200 | 99 | 101 | 101 | 0 |
| 5 | 200 | 99 | 101 | 101 | 0 |
| 16 | 200 | 99 | 101 | 101 | 0 |

Note: Simulation results are not a substitute for formal proof.

## 5. Tools Used

- SystemVerilog
- SymbiYosys (SBY)
- Yosys
- Z3 SMT Solver
- Ubuntu 22.04 on WSL

## 6. Conclusion

The parameterized Round-Robin Arbiter successfully passed formal verification for 3, 4, and 5 requesters.

Simulation testing also passed for 3, 4, 5, and 16 requesters under the recorded test conditions.

Formal verification for larger configurations remains an area for further investigation due to solver memory limitations.

The project demonstrates parameterized RTL design, handshake-based arbitration, assertion-based verification, simulation testing, and formal property checking.

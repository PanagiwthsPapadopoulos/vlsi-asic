# PicoRV32 RISC-V ASIC Implementation (45nm) 🛠️

This repository contains the complete **RTL-to-GDSII** physical design flow for a **PicoRV32 RISC-V** processor core. The project was developed as part of the "Digital Integrated Circuits VLSI-ASIC" course at the **Aristotle University of Thessaloniki (AUTH)**.

## 📑 Project Overview
The goal was to implement a 32-bit RISC-V CPU using professional EDA tools and the **GPDK 45nm** (Generic Process Design Kit) technology node. The implementation explores the trade-offs between **Power, Performance, and Area (PPA)** across multiple design scenarios.

### 🛠️ Toolstack
* **Synthesis:** Cadence Genus ⚡ 
* **Physical Design:** Cadence Innovus 🏗️ 
* **Formal Verification:** Cadence Conformal LEC ✅ 
* **Technology:** GPDK 45nm (gsclib45 standard cells, giolib45 I/O) 

---

## 🔄 General Design Flow
The project followed a standard industry ASIC design flow:
1. **Logic Synthesis:** Converting Verilog RTL into a gate-level netlist using timing constraints (Baseline: 250 MHz).
2. **Floorplanning:** Defining the die boundaries ($250 \times 250$ μm) and managing core utilization.
3. **Power Planning (PDN):** Creating a robust power grid using M8-M11 layers to minimize voltage drop.
4. **Placement:** Strategically positioning standard cells with high-effort timing-driven optimization.
5. **Clock Tree Synthesis (CTS):** Building the clock distribution network with Non-Default Rules (NDR) and shielding to minimize skew.
6. **Routing:** Finalizing metal interconnects with Signal Integrity (SI) and Antenna fix settings.
7. **Sign-off:** Running Design Rule Checks (DRC) and filler insertion to ensure manufacturability.

---

## 🧪 Detailed Task Breakdown
* **Task 1: Baseline Design** – Successfully closed timing at 250 MHz with a core utilization of 75% after power ring allocation.
* **Task 2: Low Power Optimization** – Reduced total power by approximately 13.1% post-routing by prioritizing dynamic power reduction in the synthesis engine.
* **Task 3: High-Performance Scaling** – Pushed the clock frequency to **400 MHz**, resulting in a ~51.7% increase in total power compared to the baseline.
* **Task 4: Worst-Case Analysis** – Verified the design using **Slow-Corner** libraries (1.08V) to ensure operation under adverse conditions.
* **Task 5: Clock Gating** – Inserted 60 Integrated Clock Gating (ICG) cells, gating **83.94%** of flip-flops and reducing total power by 25.1%.
* **Task 6: Design for Test (DFT)** – Replaced standard cells with **Scan Flip-Flops (SDFF)** to form a scan chain of 2399 bits for post-fabrication testing.
* **Task 7: Formal Verification** – Confirmed logical equivalence between RTL and the final netlist (2656 equivalent points) using Conformal LEC.
* **Task 8: Pad Integration** – Implemented a full chip with a **Pad Ring**; the design became "Pad Limited," with the total area increasing 220x to 7.66 $mm^2$.

---

### 🎓 Acknowledgments
Developed for the Laboratory of Electronics, Department of Electrical & Computer Engineering, AUTh.

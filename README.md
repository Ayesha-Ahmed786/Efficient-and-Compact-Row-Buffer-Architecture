# Efficient and Compact Row Buffer Architecture
## Real-Time Neighbourhood Image Processing using Compact Row Buffers (CRB)
---
##  Project Overview

This project implements a **Compact Row Buffer (CRB) architecture** for real-time **Neighbourhood Image Processing (NIP)** on FPGA.

The implementation is based on the research paper:

> **“Design and Implementation of an Efficient Row Buffer Architecture on FPGA for Real-Time Neighbourhood Image Processing”**

The objective of this project is to reproduce, analyze, and validate the proposed row buffer architecture described in the paper, and evaluate its efficiency on FPGA hardware.

##  Problem Statement

Neighbourhood Image Processing (NIP) applies a **K×K sliding window kernel** across an image.

To implement this on FPGA in real time, the system must:

- Continuously stream pixels
- Store K−1 previous rows
- Provide simultaneous multi-row access
- Maintain high clock frequency
- Use minimal on-chip memory

###  Issue with Conventional Architecture

In traditional FPGA designs:

- Each image row is stored in one BRAM36
- Only a fraction of the BRAM capacity is utilized
- Large amounts of memory remain unused

For example, a 5×5 kernel requires:
- 4 separate BRAM36 blocks  
- Poor memory utilization  
- Unnecessary hardware cost  

---

##  Proposed Solution – Compact Row Buffer (CRB)

The CRB architecture:

- Uses **1 BRAM18 instead of 4 BRAM36**
- Stores 4 row buffers inside one memory block
- Uses asymmetric dual-port configuration:
  - 8-bit write port (1 pixel per clock)
  - 32-bit read port (4 pixels per clock)
- Implements intelligent address mapping
- Adds minimal steering logic

---

##  System Architecture

The design is divided into four major modules:

---

### 1️ Memory Module (MM)

- Implements BRAM18 dual-port memory
- Port A: 8-bit write (1 pixel/clock)
- Port B: 32-bit read (4 pixels/clock)
- Stores pixels column-wise
- Packs vertically aligned pixels into 32-bit words

---

### 2️ Address Generator Module (AGM)

Generates:

- External memory read addresses  
- BRAM write addresses  
- BRAM read addresses  

Implements:

- Column-wise storage pattern  
- Cyclic row overwrite mechanism  
- Continuous streaming support  

---

### 3️ Steer Module

- Reorders vertically grouped pixels
- Maintains correct row alignment
- Uses lightweight multiplexing logic
- Very low slice utilization

---

### 4️ Control Module

- Handles synchronization
- Manages initial buffer filling
- Prevents read/write conflicts
- Controls steering selection
- Generates end-of-frame signal

---

## Operational Behavior

### Initial Latency

For a 5×5 kernel:

Initial Latency = 4 × Image Width  

For 512 width image → 2048 clock cycles  

After initial filling:

- Read and write operate in parallel
- 1 pixel input per clock
- 4 vertically aligned pixels output per clock
- Continuous row overwrite mechanism

---

##  Resource Comparison

### 5×5 Kernel

| Architecture | BRAM Used | Throughput |
|--------------|------------|------------|
| Conventional | 4 BRAM36 | 1 pixel/clock |
| Optimized Traditional | 2 BRAM36 | 1 pixel/clock |
| **Proposed CRB** | **1 BRAM18** | **1 pixel/clock** |

###  87.5% BRAM Reduction

---

## Scalability

BRAM usage formula:

BRAM18 Count = ceil((K − 1) / 4)

| Kernel Size | BRAM36 Equivalent | Slice Equivalent |
|-------------|------------------|------------------|
| 5×5 | 0.5 | 96 |
| 9×9 | 1 | 168 |
| 13×13 | 1.5 | 241 |
| 41×41 | 5 | 752 |

The architecture scales predictably and efficiently for large kernel sizes.

---

## Handling Large Images – Vertical Banding

BRAM18 supports up to 512-pixel row depth.

For wider images (e.g., 1920 pixels):

- Divide image into vertical bands (≤ 480 pixels)
- Add overlap of K−1 pixels
- Process bands sequentially
- Maintain ~1.02 cycles/pixel effective throughput

No structural modification to architecture is required.

---

---

## 🧪 Testbench

File: `tb_top.v`

The testbench:

- Generates clock and reset
- Simulates raster-scan pixel input
- Verifies:
  - Write address progression
  - Read alignment
  - Steering logic
  - Frame completion behavior

---

## 🔍 Key Contributions

- 87.5% BRAM reduction (5×5 kernel)
- Maintains ideal streaming throughput
- Minimal control overhead (~32 slices)
- Fully modular architecture
- Scalable for large K×K kernels
- Supports HD and Full HD resolutions

---

## Applications

- Real-time convolution
- Edge detection
- Biomedical imaging
- Industrial inspection
- Embedded vision systems
- Video analytics

---
## Conclusion

The Compact Row Buffer (CRB) architecture provides a highly resource-efficient and high-performance solution for FPGA-based neighbourhood image processing.

By optimizing BRAM configuration and minimizing control overhead, the design achieves:

- Maximum memory efficiency  
- Full-speed streaming performance  
- Clean modular scalability  

This architecture can be reused as a soft IP core for advanced FPGA-based real-time image processing systems.

## 📄 Documentation

A detailed technical report, including:

- Architecture diagrams  
- Timing analysis  
- Resource utilization  
- Performance evaluation  

is available in this repository.

📘 **Report:** [Project Report](./docs/)



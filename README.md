# 🧩 Reuleaux via Vga

## Overview

In this project, I implemented digital circuits to draw geometric shapes — including circles and a **Reuleaux triangle** — on a VGA display using the FPGA board DE1-SoC.  
This project provided experience with **datapath design**, **state machines**, and **hardware-level graphics generation**.

---

## 🟢 The Reuleaux Triangle

The **Reuleaux triangle** is a unique geometric shape formed by the intersection of three circles whose centers lie on each other’s perimeters.  
It maintains a constant width, meaning the distance between two parallel supporting lines is the same in every orientation — a fascinating property used in mechanical design and rotary motion systems.

### Construction
It can be visualized as:
- Three circles of equal radius, each centered at a vertex of an equilateral triangle  
- The **Reuleaux triangle** is formed by the overlapping boundary of these arcs

Mathematically, for a given center `(centre_x, centre_y)` and diameter `D`, the corner coordinates are:

```
c_x = centre_x
c_y = centre_y
c_x1 = c_x + D/2
c_y1 = c_y + D * sqrt(3)/6
c_x2 = c_x - D/2
c_y2 = c_y + D * sqrt(3)/6
c_x3 = c_x
c_y3 = c_y - D * sqrt(3)/3
```

The Verilog module draws this figure using pixel plotting logic derived from the **Bresenham circle algorithm**, reusing the circle module with clipping and coordinate control.  
Only pixels within the visible VGA area are drawn to ensure correct rendering.

---

## ⚙️ Implementation Highlights

- Designed synthesizable Verilog modules for **circle** and **Reuleaux triangle** generation  
- Verified pixel-accurate rendering through **simulation and visualization**  
- Used fixed-point math for geometric coordinate computation  
- Ensured the design met **clock cycle budgets** and signal timing constraints  

---

## 💡 Additional Work Done

### Python-Assisted Testbench Verification 🐍

Beyond the required SystemVerilog testbenches, I developed an **external Python verification and visualization script** to improve debugging and validation efficiency.

#### ✨ Features
- **Automated Checking:**  
  The script parses testbench output files and automatically compares them against expected geometric patterns (circle or Reuleaux triangle).  

- **Visual Verification:**  
  Using `matplotlib`, it plots both the expected and actual pixel coordinates — helping spot any off-by-one errors, missing points, or clipping mistakes instantly.  

- **Flexible Usage:**  
  Supports batch testing with configurable parameters such as radius, diameter, and center coordinates.

#### 🚀 Example Usage
```bash
python3 verify_shape.py output_circle.txt --expected circle --radius 40 --center 80 60
python3 verify_shape.py output_reuleaux.txt --expected reuleaux --diameter 80 --center 80 60
```

#### ✅ Benefits
- Faster and more accurate debugging  
- Visual confirmation of geometric correctness  
- Less reliance on ModelSim waveform inspection  
- Mimics professional **hardware–software co-verification** practices

---

⭐ *This extra Python-based visualization made the testing process not only faster but also more intuitive — turning debugging into something almost fun!*

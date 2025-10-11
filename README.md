## Additional Work Done

### External Python Integration for Testbench Verification

In addition to the required SystemVerilog testbenches, I implemented an **external Python-based verification and visualization system** to enhance testing and debugging efficiency.

#### Features
- **Automated Output Checking:**  
  The Python script reads the testbench output files (e.g., pixel coordinates and colours) and automatically compares them against the expected shapes such as circles or Reuleaux triangles.  
  This allows for fast regression testing without manual waveform inspection.

- **Shape Visualization:**  
  Using `matplotlib`, the script plots both the expected and actual pixel coordinates, providing a visual confirmation of the correctness of the drawn shapes.  
  This makes it easy to identify misplaced or missing pixels, clipping errors, and rounding artifacts.

- **Flexible Input Handling:**  
  The Python tool supports multiple input files, enabling batch verification for different radii, diameters, and centre coordinates.

#### Benefits
- Greatly improves **testing accuracy and speed**  
- Provides **intuitive visual confirmation** of the geometry  
- Reduces reliance on ModelSim waveform inspection  
- Encourages a **software–hardware co-verification workflow** similar to professional FPGA development environments

#### Example Usage
```bash
python3 verify_shape.py output_circle.txt --expected circle --radius 40 --center 80 60
python3 verify_shape.py output_reuleaux.txt --expected reuleaux --diameter 80 --center 80 60

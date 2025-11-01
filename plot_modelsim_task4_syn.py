import matplotlib.pyplot as plt
import matplotlib
import subprocess
import os
import argparse

import numpy as np
def bresenham_circle(cx, cy, r, x_min=0, x_max=159, y_min=0, y_max=119):
    points = []
    offset_x = r
    offset_y = 0
    crit = 1 - r
    index = 0

    while offset_y <= offset_x:
        pts = [
            (cx + offset_x, cy + offset_y),
            (cx + offset_y, cy + offset_x),
            (cx - offset_x, cy + offset_y),
            (cx - offset_y, cy + offset_x),
            (cx - offset_x, cy - offset_y),
            (cx - offset_y, cy - offset_x),
            (cx + offset_x, cy - offset_y),
            (cx + offset_y, cy - offset_x)
        ]
        index += 8
        for x, y in pts:
            points.append((x, y))
        offset_y += 1
        if crit <= 0:
            crit += 2 * offset_y + 1
        else:
            offset_x -= 1
            crit += 2 * (offset_y - offset_x) + 1
    return [points, index]

def reuleaux_triangle_to_txt(color, centre_x, centre_y, diameter, filename="../task4_syn_python.txt"):
    x_min, x_max = 0, 159
    y_min, y_max = 0, 119

    clk_budget_reu = 0

    c_x, c_y = centre_x, centre_y
    c_x1 = c_x + diameter//2
    c_y1 = int(c_y + diameter * np.sqrt(3)/6)
    c_x2 = c_x - diameter//2
    c_y2 = int(c_y + diameter * np.sqrt(3)/6)
    c_x3 = c_x
    c_y3 = int(c_y - diameter * np.sqrt(3)/3)

    circles = [
        ((c_x1, c_y1), diameter, (c_x2, c_x3), (c_y3, c_y2)),  
        ((c_x2, c_y2), diameter, (c_x3, c_x1), (c_y3, c_y2)),  
        ((c_x3, c_y3), diameter, (c_x2, c_x1), (c_y1, c_y3 + diameter))   
    ]

    with open(filename, "w") as f:
        for center, r, (x_min_arc, x_max_arc), (y_min_arc, y_max_arc) in circles:
            [pts, idx] = bresenham_circle(center[0], center[1], r)
            clk_budget_reu += idx
            for x, y in pts:

                if x_min <= x <= x_max and y_min <= y <= y_max:
                    if x_min_arc <= x <= x_max_arc and y_min_arc <= y <= y_max_arc:
                        f.write(f"X={x:3d}, Y={y:3d}, color={color:3b}\n")
    clk_budget_reu += 19200
    return clk_budget_reu

def read_points_from_txt(filename):
    points = []
    black_count = 0
    clk = 0
    with open(filename, "r") as f: 
        for line in f:
            line = line.strip()
            if line.startswith("X=") and "Y=" in line:
                parts = line.replace(" ", "").split(",")
                x = int(parts[0].split("=")[1])
                y = int(parts[1].split("=")[1])
                color = int(parts[2].split("=")[1])
                if color == 0:
                    black_count += 1  
                else:
                    points.append((x, y, color))
            elif line.startswith("clk"):
                parts = line.replace(" ", "").split(",")
                clk = int(parts[0].split("=")[1])
    return [points, black_count, clk]

def plot_results(color, centre_x, centre_y, diameter):

    clk_budget = reuleaux_triangle_to_txt(color,centre_x, centre_y, diameter)
    matplotlib.use('Agg') 

    [points1, black_count, clk] = read_points_from_txt("../task4_syn_verilog.txt")
    [points2, hhh, hhhh] = read_points_from_txt("../task4_syn_python.txt")

    if points1 == points2:
        result = 1
        msg = 'System Verilog matches Python'
    else:
        result = 0
        msg = 'System Verilog NOT matches Python'

    X1, Y1, C1 = zip(*points1)
    X2, Y2, C2 = zip(*points2)

    fig, ax = plt.subplots(figsize=(16, 11))

    scatter1 = ax.scatter(X1, Y1, color='yellow', s=15, marker='s', label='Verilog', alpha=1)
    scatter2 = ax.scatter(X2, Y2, color='cyan', s=15, marker='s', label='Python', alpha=0.8)


    ax.set_xlim(0, 159)
    ax.set_ylim(0, 119)
    ax.invert_yaxis()
    ax.set_title(f"{msg}", fontsize=25)
    ax.set_xlabel("X", fontsize=16)
    ax.set_ylabel("Y", fontsize=16)
    ax.grid(True)
    ax.legend(fontsize=20, markerscale=2.0)

    plt.savefig("./Result_task4_syn.png")  

    image_path = os.path.abspath("./Result_task4_syn.png")
    subprocess.Popen(["start", image_path], shell=True)
    return [result, black_count, clk_budget, clk]

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Plot points from txt files")
    parser.add_argument("c", help="color", default=2)
    parser.add_argument("x", help="x_centre", default=80)
    parser.add_argument("y", help="y_centre", default=60)
    parser.add_argument("d", help="diameter", default=40)
    args = parser.parse_args()

    [result, black_count, clk_budget, clk] = plot_results(int(args.c), int(args.x), int(args.y), int(args.d))
    if result == 1:
        message = 'OK......'
    else:
        message = "NOT OK..."
    print(f"** Python: check is done!")
    print(f"           clear screen: {black_count}/19200")
    print(f"           clk used:      {clk}/{clk_budget + 15}")
    if clk > clk_budget:
        print(f"           clk err:    Too many cycles")
    print(f"           consistency: {message}")
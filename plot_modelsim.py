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

def reuleaux_triangle_to_txt(centre_x, centre_y, diameter, filename="../reuleaux_python.txt"):
    x_min, x_max = 0, 159
    y_min, y_max = 0, 119

    clk_budget_reu = 0

    # 顶点坐标（整数近似）
    c_x, c_y = centre_x, centre_y
    c_x1 = c_x + diameter//2
    c_y1 = int(c_y + diameter * np.sqrt(3)/6)
    c_x2 = c_x - diameter//2
    c_y2 = int(c_y + diameter * np.sqrt(3)/6)
    c_x3 = c_x
    c_y3 = int(c_y - diameter * np.sqrt(3)/3)

    # 三个圆: (圆心, 半径, x_range, y_range)
    circles = [
        ((c_x1, c_y1), diameter, (c_x2, c_x3), (c_y3, c_y2)),  # 圆1有效区域
        ((c_x2, c_y2), diameter, (c_x3, c_x1), (c_y3, c_y2)),  # 圆2有效区域
        ((c_x3, c_y3), diameter, (c_x2, c_x1), (c_y1, c_y3 + diameter))   # 圆3有效区域
    ]

    with open(filename, "w") as f:
        for center, r, (x_min_arc, x_max_arc), (y_min_arc, y_max_arc) in circles:
            [pts, idx] = bresenham_circle(center[0], center[1], r)
            clk_budget_reu += idx
            for x, y in pts:
                # 直接用 x, y 范围判断是否画这个像素
                if x_min <= x <= x_max and y_min <= y <= y_max:
                    if x_min_arc <= x <= x_max_arc and y_min_arc <= y <= y_max_arc:
                        f.write(f"X={x:3d}, Y={y:3d}, vga_plot=1\n")
    clk_budget_reu += 19200
    return clk_budget_reu

def read_points_from_txt(filename):
    points = []
    clk = 0
    with open(filename, "r") as f: 
        for line in f:
            line = line.strip()
            if line.startswith("X=") and "Y=" in line:
                parts = line.replace(" ", "").split(",")
                x = int(parts[0].split("=")[1])
                y = int(parts[1].split("=")[1])
                points.append((x, y))
            elif line.startswith("clk"):
                parts = line.replace(" ", "").split(",")
                clk = int(parts[0].split("=")[1])
    return [points, clk]

def plot_results(centre_x, centre_y, diameter):

    clk_budget = reuleaux_triangle_to_txt(centre_x, centre_y, diameter)
    matplotlib.use('Agg') 
    # 读取两个文件
    [points1, clk] = read_points_from_txt("../reuleaux_verilog.txt")
    [points2, hhh]= read_points_from_txt("../reuleaux_python.txt")

    if points1 == points2:
        result = 1
        msg = 'System Verilog matches Python'
    else:
        result = 0
        msg = 'System Verilog NOT matches Python'

    X1, Y1 = zip(*points1)
    X2, Y2 = zip(*points2)

    # 创建 figure 和主坐标轴
    fig, ax = plt.subplots(figsize=(16, 11))

    # 绘制两个点集
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

    plt.savefig("../Result.png")  

    image_path = os.path.abspath("../Result.png")
    subprocess.Popen(["start", image_path], shell=True)
    return [result, clk_budget, clk]

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Plot points from txt files")
    parser.add_argument("x", help="x_centre", default=80)
    parser.add_argument("y", help="y_centre", default=60)
    parser.add_argument("d", help="diameter", default=40)
    args = parser.parse_args()

    [result, clk_budget, clk] = plot_results(int(args.x), int(args.y), int(args.d))
    if result == 1:
        message = 'OK......'
    else:
        message = "NOT OK..."
    print(f"** Python: check is done!")
    print(f"           clk used:    {clk} / {clk_budget + 15}")
    print(f"           consistency: {message}")
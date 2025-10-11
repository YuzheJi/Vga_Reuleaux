import matplotlib.pyplot as plt
import tkinter as tk
from tkinter import messagebox
from matplotlib.widgets import CheckButtons

def read_points_from_txt(filename):
    points = []
    with open(filename, "r") as f: 
        for line in f:
            line = line.strip()
            if line.startswith("X=") and "Y=" in line:
                parts = line.replace(" ", "").split(",")
                x = int(parts[0].split("=")[1])
                y = int(parts[1].split("=")[1])
                points.append((x, y))
    return points

root = tk.Tk()
root.withdraw()  

points1 = read_points_from_txt("reuleaux_verilog.txt")
points2 = read_points_from_txt("reuleaux_python.txt")

if points1 == points2:
    result = "System Verilog is consistent with Python!"
else:
    result = "System Verilog NOT consistent with Python......"

X1, Y1 = zip(*points1)
X2, Y2 = zip(*points2)

fig, ax = plt.subplots(figsize=(16, 11))
plt.subplots_adjust(left=0.2) 

scatter2 = ax.scatter(X2, Y2, color='blue', s=15, label='Python', marker='s')
scatter1 = ax.scatter(X1, Y1, color='red', s=15, label='Verilog', marker='s')

ax.set_xlim(0, 159)
ax.set_ylim(0, 119)
ax.invert_yaxis()
ax.set_title("Python Test", fontsize=20)
ax.set_xlabel("X", fontsize=16)
ax.set_ylabel("Y", fontsize=16)
ax.grid(True)
ax.legend(fontsize=20, markerscale=2.0)

rax = plt.axes([0.05, 0.4, 0.1, 0.15])  # [left, bottom, width, height]
check = CheckButtons(rax, ['Verilog', 'Python'], [True, True])
for label in check.labels:
    label.set_fontsize(20)


def func(label):
    if label == 'Verilog':
        scatter1.set_visible(not scatter1.get_visible())
    elif label == 'Python':
        scatter2.set_visible(not scatter2.get_visible())
    plt.draw()

check.on_clicked(func)

plt.show(block=False)

messagebox.showinfo("Consistency Check", result)
plt.show()

root.destroy()

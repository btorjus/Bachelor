"""
Clean overview of the crane multibody topology.

The figure shows the closed-loop mechanical structure:
ground, arm, cylinder housing, cylinder rod, three revolute joints,
and one hydraulically driven prismatic joint.
"""

from pathlib import Path

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import rcParams
from matplotlib.patches import Circle, FancyArrowPatch, FancyBboxPatch, Rectangle
from matplotlib.transforms import Affine2D

# ============================================================
# Style
# ============================================================
USE_LATEX = False

rcParams.update({
    "font.family": "serif",
    "font.size": 11,
    "text.usetex": USE_LATEX,
    "mathtext.fontset": "cm",
    "pdf.fonttype": 42,
    "ps.fonttype": 42,
})

C_BLACK = "#29211F"
C_GREY = "#D9D9D9"
C_BLUE = "#9AC7D8"
C_RED = "#E85C4A"
C_GREEN = "#8DBA72"
C_PURPLE = "#C9A7E8"
C_NOTE = "#F7F3EA"

LW_BODY = 1.2
LW_LINK = 1.5

# ============================================================
# Geometry
# ============================================================
A = np.array([2.0, 4.4])     # ground-arm revolute
B = np.array([2.0, 1.6])     # ground-cylinder revolute
C = np.array([7.2, 5.7])     # arm-rod revolute
D = np.array([5.4, 2.25])    # cylinder housing/rod prismatic location

ground_top = np.array([2.0, 5.2])
ground_bot = np.array([2.0, 0.85])

arm_start = A
arm_end = np.array([8.2, 6.25])

housing_start = B
housing_end = D

rod_start = D
rod_end = C

hyd_pos = np.array([8.9, 2.7])

# ============================================================
# Helpers
# ============================================================
def draw_bar(ax, p0, p1, color, lw=13, zorder=2):
    """Draw a thick rounded mechanical link."""
    ax.plot(
        [p0[0], p1[0]],
        [p0[1], p1[1]],
        color=color,
        linewidth=lw,
        solid_capstyle="round",
        zorder=zorder,
    )
    ax.plot(
        [p0[0], p1[0]],
        [p0[1], p1[1]],
        color=C_BLACK,
        linewidth=1.0,
        solid_capstyle="round",
        zorder=zorder + 1,
    )


def draw_joint(ax, p, label, offset):
    """Draw a revolute joint."""
    ax.add_patch(Circle(
        p,
        0.22,
        facecolor=C_RED,
        edgecolor=C_BLACK,
        linewidth=1.1,
        zorder=8,
    ))
    ax.add_patch(Circle(
        p,
        0.07,
        facecolor=C_BLACK,
        edgecolor="none",
        zorder=9,
    ))

    ax.text(
        p[0] + offset[0],
        p[1] + offset[1],
        label,
        ha="center",
        va="center",
        fontsize=10,
        color=C_BLACK,
        zorder=10,
    )


def draw_prismatic(ax, p, angle, label_offset=(0.0, -0.55)):
    """Draw the prismatic joint symbol aligned with the cylinder."""
    w, h = 0.72, 0.30
    tr = Affine2D().rotate(angle).translate(p[0], p[1]) + ax.transData

    ax.add_patch(Rectangle(
        (-w / 2, -h / 2),
        w,
        h,
        transform=tr,
        facecolor=C_GREEN,
        edgecolor=C_BLACK,
        linewidth=1.1,
        zorder=9,
    ))

    for yy in (-0.28, 0.28):
        ax.plot(
            [-0.45, 0.45],
            [yy, yy],
            transform=tr,
            color=C_BLACK,
            linewidth=0.9,
            zorder=10,
        )

    ax.text(
        p[0] + label_offset[0],
        p[1] + label_offset[1],
        "Prismatic joint",
        ha="center",
        va="center",
        fontsize=10,
        color=C_BLACK,
        zorder=10,
    )


def add_label(ax, x, y, text, ha="center", va="center"):
    ax.text(
        x,
        y,
        text,
        ha=ha,
        va=va,
        fontsize=10,
        color=C_BLACK,
        zorder=10,
    )


def add_note(ax, x, y, text):
    ax.text(
        x,
        y,
        text,
        ha="left",
        va="top",
        fontsize=10,
        color=C_BLACK,
        bbox=dict(
            boxstyle="round,pad=0.35",
            facecolor=C_NOTE,
            edgecolor="#B0B0B0",
            linewidth=0.8,
        ),
        zorder=20,
    )


def arrow(ax, start, end, color=C_BLACK, both=False):
    style = "<->" if both else "-|>"
    ax.add_patch(FancyArrowPatch(
        start,
        end,
        arrowstyle=style,
        mutation_scale=12,
        linewidth=1.2,
        color=color,
        zorder=6,
    ))


# ============================================================
# Figure
# ============================================================
fig, ax = plt.subplots(figsize=(10.5, 6.5))

# Ground/base
ax.plot(
    [ground_top[0], ground_bot[0]],
    [ground_top[1], ground_bot[1]],
    color=C_GREY,
    linewidth=18,
    solid_capstyle="round",
    zorder=1,
)
ax.plot(
    [ground_top[0], ground_bot[0]],
    [ground_top[1], ground_bot[1]],
    color=C_BLACK,
    linewidth=1.1,
    solid_capstyle="round",
    zorder=2,
)
add_label(ax, 1.25, 3.0, "Ground\nfixed", ha="center")

# Mechanical links
draw_bar(ax, arm_start, arm_end, C_BLUE, lw=13, zorder=3)
draw_bar(ax, housing_start, housing_end, C_BLUE, lw=12, zorder=3)
draw_bar(ax, rod_start, rod_end, C_BLUE, lw=9, zorder=4)

# Link labels
add_label(ax, 5.4, 5.65, "Arm + payload")
add_label(ax, 3.6, 1.7, "Cylinder housing")
add_label(ax, 6.55, 4.15, "Cylinder rod")

# Payload direction
arrow(ax, arm_end + np.array([0.15, 0.0]), arm_end + np.array([0.95, 0.0]))
add_label(ax, arm_end[0] + 1.2, arm_end[1], "payload\nworking end", ha="left")

# Joints
draw_joint(ax, A, "$A$", offset=(-0.42, 0.33))
draw_joint(ax, B, "$B$", offset=(-0.42, -0.33))
draw_joint(ax, C, "$C$", offset=(0.35, 0.35))

# Prismatic joint
cyl_vec = rod_end - housing_start
cyl_angle = np.arctan2(cyl_vec[1], cyl_vec[0])
draw_prismatic(ax, D, cyl_angle, label_offset=(0.25, -0.65))

# Hydraulic subsystem
hyd_w, hyd_h = 2.0, 1.05
ax.add_patch(FancyBboxPatch(
    (hyd_pos[0] - hyd_w / 2, hyd_pos[1] - hyd_h / 2),
    hyd_w,
    hyd_h,
    boxstyle="round,pad=0.04,rounding_size=0.12",
    facecolor=C_PURPLE,
    edgecolor=C_BLACK,
    linewidth=1.1,
    linestyle="--",
    zorder=5,
))
ax.text(
    hyd_pos[0],
    hyd_pos[1] + 0.16,
    "Hydraulic\nsubsystem",
    ha="center",
    va="center",
    fontsize=10,
    color=C_BLACK,
    zorder=6,
)
ax.text(
    hyd_pos[0],
    hyd_pos[1] - 0.32,
    "valves, pump, CBV",
    ha="center",
    va="center",
    fontsize=9,
    color="#555555",
    zorder=6,
)

arrow(
    ax,
    hyd_pos + np.array([-1.0, 0.0]),
    D + np.array([0.42, -0.02]),
    color="#555555",
    both=True,
)
add_label(ax, 7.25, 2.35, "$p_A, p_B$")

# Notes
add_note(
    ax,
    0.45,
    6.55,
    "Closed kinematic loop\n"
    "$\\rightarrow$ one independent motion coordinate\n"
    "$\\rightarrow$ actuator stroke drives arm angle $\\theta$",
)

# Legend
legend_x, legend_y = 0.55, 0.65

ax.add_patch(Circle(
    (legend_x, legend_y + 0.78),
    0.11,
    facecolor=C_RED,
    edgecolor=C_BLACK,
    linewidth=0.8,
    zorder=10,
))
ax.text(
    legend_x + 0.25,
    legend_y + 0.78,
    "Revolute joint",
    ha="left",
    va="center",
    fontsize=9,
)

ax.add_patch(Rectangle(
    (legend_x - 0.13, legend_y + 0.35),
    0.26,
    0.14,
    facecolor=C_GREEN,
    edgecolor=C_BLACK,
    linewidth=0.8,
    zorder=10,
))
ax.text(
    legend_x + 0.25,
    legend_y + 0.42,
    "Prismatic joint",
    ha="left",
    va="center",
    fontsize=9,
)

ax.plot(
    [legend_x - 0.12, legend_x + 0.12],
    [legend_y, legend_y],
    color=C_BLUE,
    linewidth=7,
    solid_capstyle="round",
)
ax.plot(
    [legend_x - 0.12, legend_x + 0.12],
    [legend_y, legend_y],
    color=C_BLACK,
    linewidth=0.8,
    solid_capstyle="round",
)
ax.text(
    legend_x + 0.25,
    legend_y,
    "Rigid body/link",
    ha="left",
    va="center",
    fontsize=9,
)

# Final layout
ax.set_xlim(0.0, 10.6)
ax.set_ylim(0.2, 6.9)
ax.set_aspect("equal")
ax.axis("off")

plt.tight_layout()

output = Path(__file__).with_name("simulink_overview.pdf")
fig.savefig(output, bbox_inches="tight", pad_inches=0.05)
plt.show()

print(f"Wrote {output}")
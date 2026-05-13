import numpy as np
import matplotlib.pyplot as plt
from matplotlib import rcParams

# Vector-friendly fonts, serif to match LaTeX body
rcParams['pdf.fonttype'] = 42
rcParams['ps.fonttype'] = 42
rcParams['font.family'] = 'serif'
rcParams['font.size'] = 11

# User's color palette
C_red    = (0.9490, 0.0196, 0.0196)
C_blue   = (0.3725, 0.7608, 0.8510)
C_lblue  = (0.0118, 0.6510, 0.5333)
C_yellow = (0.9490, 0.6235, 0.0196)
C_orange = (0.9490, 0.4549, 0.0196)
C_black  = (0.1608, 0.1294, 0.1216)

# Trajectory parameters
center = 0.250      # m
amplitude = 0.150   # m
phase = np.linspace(0, 1.0, 1000)
x_ref = center + amplitude * np.sin(2*np.pi*phase)

fig, ax = plt.subplots(figsize=(8, 4))

# Trajectory
ax.plot(phase, x_ref, linewidth=2.0, color=C_blue, zorder=2)

# Reference lines
ax.axhline(center, color=C_black, linewidth=0.5, linestyle='--', alpha=0.35, zorder=1)
ax.axhline(center + amplitude, color=C_black, linewidth=0.4, linestyle=':', alpha=0.3, zorder=1)
ax.axhline(center - amplitude, color=C_black, linewidth=0.4, linestyle=':', alpha=0.3, zorder=1)

# Four characteristic points with single-line labels
points = [
    (0.00, center,             'Peak extension velocity',  (8, -18)),
    (0.25, center + amplitude, 'Upper turnaround',         (0, 12)),
    (0.50, center,             'Peak retraction velocity', (-8, 18)),
    (0.75, center - amplitude, 'Lower turnaround',         (0, -12)),
]

for x, y, label, offset in points:
    ax.plot(x, y, 'o', markersize=8, color=C_red, markeredgecolor='white',
            markeredgewidth=1.2, zorder=5)
    dx, dy = offset
    ha = 'left' if dx > 0 else ('right' if dx < 0 else 'center')
    va = 'bottom' if dy > 0 else ('top' if dy < 0 else 'center')
    ax.annotate(label, (x, y), xytext=offset, textcoords='offset points',
                fontsize=10, ha=ha, va=va, color=C_black)

# Axes
ax.set_xlabel('Time (one cycle)', color=C_black)
ax.set_ylabel('Cylinder position [m]', color=C_black)

ax.set_xticks([0, 0.25, 0.5, 0.75, 1.0])
ax.set_xticklabels(['0', r'$T/4$', r'$T/2$', r'$3T/4$', r'$T$'])

ax.set_yticks([center - amplitude, center, center + amplitude])
ax.set_yticklabels([f'{center-amplitude:.3f}', f'{center:.3f}', f'{center+amplitude:.3f}'])

ax.set_xlim(-0.03, 1.03)
ax.set_ylim(center - amplitude - 0.08, center + amplitude + 0.08)

ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['left'].set_color(C_black)
ax.spines['bottom'].set_color(C_black)
ax.tick_params(direction='out', length=4, colors=C_black)

plt.tight_layout()

out = '/mnt/user-data/outputs/robustness_reference_trajectory.pdf'
plt.savefig(out, format='pdf', bbox_inches='tight')
plt.close()

print(f'Wrote {out}')

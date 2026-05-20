"""Conceptual position control block diagram.

The figure illustrates the control-loop structure using plain-language labels:
feed-forward control, feedback control, pressure feedback, position correction,
and the final control signal applied to the system.
"""
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch, Circle

# %% Style
plt.rcParams.update({
    'font.family':      'serif',
    'text.usetex':      True,
    'font.size':        17,
    'mathtext.fontset': 'cm',
    'pdf.fonttype':     42,
    'ps.fonttype':      42,
})

# %% Tunables
hw_ratio = 0.40
fig_w_in = 14
lw       = 1.35

C_LINE = '#1f1f1f'
C_FILL = '#fbfaf7'
C_NODE = '#1f1f1f'

# %% Drawing helpers
def add_block(ax, cx, cy, w, h, label=None, lines=None):
    ax.add_patch(FancyBboxPatch(
        (cx - w/2, cy - h/2), w, h,
        boxstyle='round,pad=0.06,rounding_size=0.08',
        facecolor=C_FILL,
        edgecolor=C_LINE,
        linewidth=lw,
        zorder=2
    ))
    if lines:
        n = len(lines)
        for i, ln in enumerate(lines):
            dy = ((n - 1)/2 - i) * 0.50
            ax.text(cx, cy + dy, ln, ha='center', va='center', zorder=3)
    elif label is not None:
        ax.text(cx, cy, label, ha='center', va='center', zorder=3)

def add_sum(ax, cx, cy, signs, r=0.30):
    """Draw a summing junction with small signs aligned to incoming branches."""
    ax.add_patch(Circle(
        (cx, cy), r,
        facecolor='white',
        edgecolor=C_LINE,
        linewidth=lw,
        zorder=2
    ))

    offset = 0.17
    pos = {
        'left':   (cx - offset, cy),
        'right':  (cx + offset, cy),
        'top':    (cx, cy + offset),
        'bottom': (cx, cy - offset),
    }

    for side, sym in signs.items():
        ax.text(
            *pos[side],
            sym,
            ha='center',
            va='center',
            fontsize=10,
            fontweight='bold',
            color=C_LINE,
            zorder=3,
            usetex=False
        )

def arrow(ax, x0, y0, x1, y1):
    ax.add_patch(FancyArrowPatch(
        (x0, y0), (x1, y1),
        arrowstyle='-|>',
        mutation_scale=15,
        lw=lw,
        color=C_LINE,
        shrinkA=0,
        shrinkB=0,
        zorder=1,
        joinstyle='round',
        capstyle='round'
    ))

def line(ax, xs, ys):
    ax.plot(xs, ys, color=C_LINE, lw=lw, solid_capstyle='round', zorder=1)

# %% Canvas
fig, ax = plt.subplots(figsize=(fig_w_in, fig_w_in * hw_ratio))
ax.set_xlim(0, 20)
ax.set_ylim(0, 8.5)
ax.set_aspect('equal')
ax.axis('off')

# %% Geometry
y_top, y_mid, y_bot = 6.8, 4.2, 1.2

x_in      = 0.6
x_err     = 3.2
x_ctrl    = 5.2
x_comb    = 7.8
x_psum    = 10.6
x_sys     = 13.7
x_tap     = 17.2
x_meas    = 18.55
x_comp    = 11.0
x_pfb_blk = 12.85

W_ctrl, H_ctrl = 1.65, 1.0
W_sys,  H_sys  = 2.7, 1.35
W_pfb,  H_pfb  = 2.75, 1.15
W_comp, H_comp = 2.20, 1.0
r_sum = 0.30

# %% Top path: reference velocity -> feed-forward model -> feed-forward contribution
ax.text(x_in - 0.2, y_top, 'Reference\nvelocity',
        ha='right', va='center')
arrow(ax, x_in, y_top, x_ctrl - W_ctrl/2, y_top)
add_block(ax, x_ctrl, y_top, W_ctrl, H_ctrl,
          lines=['Feed-forward', 'model'])
line(ax, [x_ctrl + W_ctrl/2, x_comb], [y_top, y_top])
ax.text((x_ctrl + W_ctrl/2 + x_comb)/2, y_top + 0.32,
        'Feed-forward\ncontribution', ha='center', va='bottom')
arrow(ax, x_comb, y_top, x_comb, y_mid + r_sum)

# %% Reference & error summer
ax.text(x_in - 0.2, y_mid, 'Reference\nposition',
        ha='right', va='center')
arrow(ax, x_in, y_mid, x_err - r_sum, y_mid)
add_sum(ax, x_err, y_mid, signs={'left': '+', 'bottom': '−'})

# %% Feedback controller -> feedback contribution -> combiner
arrow(ax, x_err + r_sum, y_mid, x_ctrl - W_ctrl/2, y_mid)
ax.text((x_err + r_sum + x_ctrl - W_ctrl/2)/2, y_mid + 0.32,
        'Position\nerror', ha='center', va='bottom')
add_block(ax, x_ctrl, y_mid, W_ctrl, H_ctrl,
          lines=['Feedback', 'controller'])
arrow(ax, x_ctrl + W_ctrl/2, y_mid, x_comb - r_sum, y_mid)
ax.text((x_ctrl + W_ctrl/2 + x_comb)/2, y_mid + 0.32,
        'Feedback\ncontribution', ha='center', va='bottom')
add_sum(ax, x_comb, y_mid, signs={'left': '+', 'top': '+'})

# %% Combiner -> pressure-feedback subtractor -> System
arrow(ax, x_comb + r_sum, y_mid, x_psum - r_sum, y_mid)
add_sum(ax, x_psum, y_mid, signs={'left': '+', 'top': '−'})
arrow(ax, x_psum + r_sum, y_mid, x_sys - W_sys/2, y_mid)
ax.text((x_psum + r_sum + x_sys - W_sys/2)/2, y_mid + 0.32,
        'Control\nsignal', ha='center', va='bottom')
add_block(ax, x_sys, y_mid, W_sys, H_sys, label='System')

# %% System output -> tap -> measured position
line(ax, [x_sys + W_sys/2, x_tap], [y_mid, y_mid])
ax.plot(x_tap, y_mid, 'o', color=C_NODE, markersize=4.5, zorder=3)
arrow(ax, x_tap, y_mid, x_meas - 0.05, y_mid)

# %% Pressure-feedback branch
x_px_out = x_sys + W_sys/2
y_px_out = y_mid + 0.22

x_pfb_in = x_pfb_blk + W_pfb/2
y_pfb_in = y_top

x_pfb_bend1 = x_px_out + 1.20
y_pfb_bend1 = y_mid + 0.75

x_pfb_bend2 = x_pfb_bend1
y_pfb_bend2 = y_pfb_in

line(ax,
     [x_px_out, x_pfb_bend1, x_pfb_bend2],
     [y_px_out, y_pfb_bend1, y_pfb_bend2])

ax.text(x_pfb_bend1 + 0.18, (y_pfb_bend1 + y_pfb_bend2)/2,
        'Measured\npressure', ha='left', va='center')

arrow(ax, x_pfb_bend2, y_pfb_bend2, x_pfb_in, y_pfb_in)

add_block(ax, x_pfb_blk, y_top, W_pfb, H_pfb,
          lines=['Pressure', 'feedback'])
line(ax, [x_pfb_blk - W_pfb/2, x_psum], [y_top, y_top])
ax.text((x_pfb_blk - W_pfb/2 + x_psum)/2 - 0.25, y_top + 0.34,
        'Pressure-feedback\ncontribution', ha='center', va='bottom')
arrow(ax, x_psum, y_top, x_psum, y_mid + r_sum)

# %% Position correction feedback: measured position -> correction -> error summer
line(ax, [x_tap, x_tap], [y_mid, y_bot])
arrow(ax, x_tap, y_bot, x_comp + W_comp/2, y_bot)
ax.text((x_tap + x_comp + W_comp/2)/2, y_bot + 0.34,
        'Measured\nposition', ha='center', va='bottom')
add_block(ax, x_comp, y_bot, W_comp, H_comp,
          lines=['Position', 'correction'])
line(ax, [x_comp - W_comp/2, x_err], [y_bot, y_bot])
ax.text((x_comp - W_comp/2 + x_err)/2, y_bot + 0.34,
        'Corrected\nposition', ha='center', va='bottom')
arrow(ax, x_err, y_bot, x_err, y_mid - r_sum)

# %% Save
fig.savefig('control_loop_concept.pdf', bbox_inches='tight', pad_inches=0.04)
plt.show()
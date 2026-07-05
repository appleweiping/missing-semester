#!/usr/bin/env python3
"""Generate plot.png from data.dat — the figure that paper.tex includes.

This is the build-dependency the Makefile tracks: plot.png depends on both this
script and data.dat, and paper.pdf depends on plot.png.
"""
import sys
import matplotlib
matplotlib.use("Agg")  # headless backend, no display needed
import matplotlib.pyplot as plt


def main(data_path="data.dat", out_path="plot.png"):
    xs, ys = [], []
    with open(data_path) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            x, y = line.split()
            xs.append(float(x))
            ys.append(float(y))

    fig, ax = plt.subplots(figsize=(5, 3))
    ax.plot(xs, ys, marker="o", color="#2c6fbb")
    ax.set_title("Measured data")
    ax.set_xlabel("x")
    ax.set_ylabel("y")
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(out_path, dpi=120)
    print(f"wrote {out_path} from {data_path} ({len(xs)} points)")


if __name__ == "__main__":
    main(*sys.argv[1:])

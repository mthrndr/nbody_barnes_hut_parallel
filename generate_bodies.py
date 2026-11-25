import csv
import random
import sys


def generate_bodies(
    filename: str = "bodies.csv",
    num_bodies: int = 1000,
    box_radius: float = 100.0,
    max_vel: float = 1.0,
    min_mass: float = 1.0,
    max_mass: float = 100.0,
    seed: int = 42,
) -> None:
    rng = random.Random(seed)
    with open(filename, mode="w", newline="") as f:
        writer = csv.writer(f)
        for _ in range(num_bodies):
            x = rng.uniform(-box_radius, box_radius)
            y = rng.uniform(-box_radius, box_radius)
            z = rng.uniform(-box_radius, box_radius)
            vx = rng.uniform(-max_vel, max_vel)
            vy = rng.uniform(-max_vel, max_vel)
            vz = rng.uniform(-max_vel, max_vel)
            mass = rng.uniform(min_mass, max_mass)
            writer.writerow([f"{v:.6f}" for v in (x, y, z, vx, vy, vz, mass)])
    print(f"Wrote {num_bodies} bodies to {filename}")


if __name__ == "__main__":
    count = int(sys.argv[1]) if len(sys.argv) > 1 else 1000
    out_file = sys.argv[2] if len(sys.argv) > 2 else "bodies.csv"
    generate_bodies(filename=out_file, num_bodies=count)

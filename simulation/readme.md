# simulation

- `openrocket/`: openrocket models (`..._v1.0.ork` is the old 3 in airframe, `..._v1.1.ork` is the current 4 in airframe) and the data exports each team uses.
- `pid/`: two-axis matlab pid simulation of the tvc loop during the motor burn (`pid_sim.m`), the moment of inertia data from openrocket, and the test vectors for the firmware.

Run `pid_sim.m` from inside `simulation/pid/` so it finds the moment of inertia csv. It writes `pid_test_vectors.csv`.

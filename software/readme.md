# software

- Flight firmware (stm32f405, c99): state machine, sensor drivers, pid controller, servo output
- Ground station software (python): packet decoding, live plots, logging
- `tests/`: unit tests. The pid port is checked against `simulation/pid/pid_test_vectors.csv`.

Columns of `pid_test_vectors.csv`: time (s), pitch error (deg), yaw error (deg), pitch deflection out (deg), yaw deflection out (deg).

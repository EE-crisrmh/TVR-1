# tvr-1

tvr-1 is a student-built, thrust-vector-controlled (tvc) model rocket with its own custom flight computer. This page explains what it is, how it started, where it is going and how the pieces fit. Who is responsible for what is in [ownership.md](ownership.md).
<img width="1328" height="388" alt="Screenshot 2026-10-26 at 12 36 31 AM" src="https://github.com/user-attachments/assets/0754afb0-c499-42f7-9e8b-cb059344621b" />

## what it is

Most model rockets steer with fins. tvr-1 steers by tilting its motor a few degrees (the "gimbal") to keep itself pointed straight up. A small computer on board reads its sensors, works out which way the rocket is leaning, and moves two servos to correct it many times a second. The team designs and builds every part of this itself: the airframe, the gimbal, the circuit boards, the radio link, the flight software and the ground station.

**mission:** launch it, recover it, and prove that a student team can build every system safely and properly.

**what comes next:** tvr-2 will aim to land by itself, and later vehicles build on what each rocket teaches us.

## where it stands

- Airframe: 4 in fiberglass tube, about 101 cm long.
- Motor: G61W-6 solid motor, about 2 seconds of burn.
- Simulated flight: about 266 m apogee, stable at 1.29 calibers (OpenRocket v1.1).
- Control: a two-axis PID controller, tested in simulation (MATLAB) before it goes into the firmware.
- Design phase: simulations, schematics and CAD are in progress.

## how it started

tvr-1 began in September 2026 as an independent project by Project Lead Cris R. Martinez Hernandez, an electrical engineering student at UW Bothell. He recruited students from electrical, mechanical and software backgrounds with the goal of turning this independent project into a bigger organization, the team currently has ten active members. 

## joining Proxima Rocketry

In winter quarter 2027 (start of January), tvr-1 joins Proxima Rocketry, the rocketry club at UW Bothell, as its flagship project. The two keep their own leadership: Proxima's officers keep running the club and its beginner-friendly events, and tvr-1 gets a seat on Proxima's executive board plus its own team leads. The new structure will be written into Proxima's updated constitution. If you are joining through Proxima or just want to build a rocket, you are welcome on tvr-1!

## timeline

| when | what happens |
| --- | --- |
| fall 2026 | finish the 4 in redesign, update the simulations, finish schematics, set up the team |
| winter 2027 | join Proxima, lock the design, order the first circuit boards, design review |
| spring 2027 | build and bench-test each part on its own, integration review |
| summer 2027 | put it all together, test the whole system, flight readiness review, launch in mid-summer |
| after launch | recover, study the data, write up what we learned, start planning tvr-2 |

Dates are a plan and may move. Safety comes before schedule.

## the subsystems

| subsystem | what it does |
| --- | --- |
| flight computer pcb | the main circuit board: processor, motion sensors and altitude sensor |
| power and battery | battery, voltage regulation, arming switch and wiring |
| rocket radio link | sends data from the rocket to the ground |
| ground station hardware | the radio dongle and antenna that receive the data |
| flight firmware | the code on the rocket that tracks the flight phase and steers the motor |
| ground station software | the program that shows and records live data on a laptop |
| test and data logging | automated tests, and a record of every flight for later study |
| airframe and structure | the body tube, fins, nose and motor mount |
| tvc gimbal | the mechanism that tilts the motor |
| electronics bay | the compartment that holds and protects the electronics |
| recovery hardware | parachute, cords and the ejection system |
| flight and control simulation | predicts the flight and tunes the PID controller |
| sensor fusion | combines sensor readings into a reliable estimate of position and tilt |
| recovery simulation | predicts the descent and where the rocket will land |

## repository layout

| folder | what is in it |
| --- | --- |
| `hardware/` | kicad projects, bill of materials, gerbers, assembly files |
| `mechanical/` | cad, calculations, drawings |
| `simulation/` | openrocket models and the matlab pid simulation (see [simulation/readme.md](simulation/readme.md)) |
| `software/` | flight firmware, ground station software and tests |
| `docs/` | design documents and reports |

## contributing

See [contributing.md](contributing.md). New to the team? Say hi in the team Discord and ask a lead where to start.

## safety

This is a model rocket project. Build, test and launch only under the rules of the launch site and with a designated safety owner present.

## license

See [LICENSE](LICENSE).

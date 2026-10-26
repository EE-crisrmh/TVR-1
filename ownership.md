# tvr-1 lead roles and subsystem ownership

tvr-1 runs on five leads + project lead, who together own 14 subsystems between winter 2027 and a launch targeted for mid-summer 2027. For what tvr-1 is, see [readme.md](readme.md).

## who owns what

| lead | subsystems they own | works most with |
| --- | --- | --- |
| project lead | systems integration, safety and launch, exec board and budget | all leads, Proxima executive board |
| electrical | flight computer pcb; power, battery and arming | software, comms, mechanical |
| comms | rocket radio link; ground station hardware | electrical, software |
| software | flight firmware and state machine; ground station software; test, ci and data logging | electrical, comms, simulations |
| mechanical | airframe and structure; tvc gimbal; electronics bay; recovery hardware | electrical, simulations |
| simulations | flight and control sim; sensor fusion; recovery sim | software, mechanical |

Any member of TVR-1 can work on the different subsystems. The lead is accountable for the subsystem on schedule, splitting up work between their teams and sending updates to the project lead.

## what every lead does

Plan on 10 to 15 hours a week, including your own building, and more in the weeks before a gate or a launch.

- Run a weekly sync with your subsystem owners and keep a short written status.
- Attend the weekly leads sync with the project lead.
- Keep your team's files, drawings and notes in this repo so anyone can pick them up.
- Review other teams' interfaces that touch yours before each gate.
- Flag a slip as soon as you see it, not at the gate.
- Onboard new members into your area and give each a first task.

## path to launch

These gates are a proposed starting point. Each lead's milestones below are built to land on them.

1. **winter 2027 (jan to mar): design and prototype.** Design freeze by the end of March, with a design review that every lead signs.
2. **spring 2027 (apr to jun): build and test parts on their own.** Finished flight computer, gimbal, airframe and software, each bench-tested alone. Integration review in june.
3. **summer 2027 (jul to aug): integrate, test the whole system, launch.** Full-system ground tests and a flight readiness review in early july, then launch in mid-july to august.
4. **after launch:** recover, review the data, and document what tvr-1 taught us for tvr-2.

## project lead

The project lead holds tvr-1's seat on the Proxima executive board and keeps the five teams on track.

### systems integration

- **owns:** the master requirements and interface list (mass, cg, stability, power draw, packet format, mounting), and the single source of truth for current vehicle numbers.
- **winter 2027:** publish the interface list, run full design review on every subsystem, and freeze the design by the end of March.
- **spring 2027:** track every interface as parts get built, and settle conflicts between teams.
- **summer 2027:** run integration and the full-system tests, then the flight readiness review.
- **works with:** all leads.

### safety and launch

- **owns:** launch site rules, the pre-flight and recovery checklists, and who is allowed to arm and fire.
- **winter 2027:** pick the launch site and date, and write the first draft of the checklists.
- **spring 2027:** test the checklists on every ground test and fix gaps.
- **summer 2027:** hold the go or no-go call on launch day. Name a second person who can say no.
- **works with:** mechanical (recovery), electrical (arming), the faculty advisor.

### exec board, budget and advisor

- **owns:** the tvr-1 budget request, reporting to the Proxima executive board, and the faculty advisor.
- **winter 2027:** present the lead structure and the budget plan, and keep the parts list matched to the budget.
- **spring 2027:** report progress at gates and request any budget changes early.
- **summer 2027:** launch approval paperwork and the post-launch report to the board.
- **works with:** Proxima president, vp and treasurer.

## electrical lead

Electrical owns the board in the rocket and the power that keeps it running

### flight computer pcb

- **owns:** schematic, layout, ordering and bring-up of the stm32f405 board, including the sensors, servo outputs, pyro channel and connectors. The board must fit the electronics bay.
- **winter 2027:** finish the schematic review, lay out the board, and order revision a by mid-march.
- **spring 2027:** assemble and bring up revision a with software, fix issues, and order revision b if needed.
- **summer 2027:** install the final board, run vibration and ground tests, and keep a flight spare.
- **works with:** software, comms, mechanical.

### power, battery and arming

- **owns:** the power budget, battery choice, regulation and protection, the arming switch, and the wiring harness with labelled connectors.
- **winter 2027:** finish the power budget with real current numbers, pick the battery and regulators, and draw the power schematic.
- **spring 2027:** build and test the power section and harness, and run a battery test long enough to cover pad wait plus flight.
- **summer 2027:** final harness, arming procedure written into the checklist, and spare batteries.
- **works with:** software, mechanical, project lead for safety.

## comms lead

Comms owns everything between the rocket's antenna and the laptop on the ground.

### rocket radio link

- **owns:** the lora module on the rocket (rylr998), its antenna and placement, the data rate and airtime budget, and the range test plan.
- **winter 2027:** agree the packet format with software, choose the antenna, and estimate the link budget.
- **spring 2027:** bench link test, then a ground range test with the antenna inside an airframe mockup.
- **summer 2027:** range test at launch-site distances, frequency and legal check, and spare modules.
- **works with:** electrical, software, mechanical for antenna placement.
- **to confirm:** whether tvr-1 carries a gps tracker for recovery. If so, it belongs here.

### ground station hardware

- **owns:** the usb dongle (mcp2200 usb-uart, rylr998, 3.3 v regulator, usb-c), its enclosure, the ground antenna and mount, and the field kit.
- **winter 2027:** finish the dongle schematic review and order the first boards.
- **spring 2027:** build the dongles and test them against the flight computer and the ground software.
- **summer 2027:** assemble the field kit (power, cables, antenna, spare dongle) and rehearse a full pad setup.
- **works with:** software, electrical.

## software lead

Software owns the code that flies the rocket, the code that watches it fly, and the tests that prove both work.

### flight firmware and state machine

- **owns:** the c99 firmware on the stm32f405: sensor drivers, the state machine (pad, boost, coast, apogee, descent, landed) with debouncing, the pid controller, servo output and pyro control.
- **winter 2027:** state machine and pid port passing desktop tests against the matlab test vectors in `simulation/pid/`, with drivers running on a dev board.
- **spring 2027:** run on the real flight computer, add hardware-in-the-loop tests, and handle sensor loss and bad data.
- **summer 2027:** freeze the firmware, review the flight configuration, and run the final checks.
- **works with:** electrical, simulations.

### ground station software

- **owns:** the python app that decodes packets, plots live data, logs everything, and replays flights.
- **winter 2027:** packet spec locked with comms, and a decoder tested on fake packets.
- **spring 2027:** live plots with the real dongle, plus replay of logged flights.
- **summer 2027:** pad-ready screen, a clear health display for go or no-go, and fast post-flight data export.
- **works with:** comms, simulations.

### test, ci and data logging

- **owns:** unit tests, github actions, onboard flash logging, and the post-flight analysis scripts.
- **winter 2027:** ci running on every push, with tests for the state machine and pid.
- **spring 2027:** regression tests on logged and simulated flights, and a stable log format.
- **summer 2027:** pre-flight self-test and post-flight analysis scripts ready before launch day.
- **works with:** simulations, electrical.

## mechanical lead

Mechanical owns every physical part of the rocket and how it fits together.

### airframe and structure

- **owns:** the 4 in fiberglass airframe (101 cm), fins, nose and ballast, couplers and motor retention. It keeps the mass and cg matching the simulation (stability about 1.29 cal today).
- **winter 2027:** finish cad, fin design and the mass layout, and send the final numbers to simulations.
- **spring 2027:** build or buy parts, fit-check everything, and attach the fins.
- **summer 2027:** final assembly, then weigh and balance against the sim.
- **works with:** simulations, electrical.

### tvc gimbal

- **owns:** the motor mount gimbal, servos, linkage and pivot. It must stay within the sim's 5 degree deflection limit unless simulations agrees to a new one.
- **winter 2027:** design the gimbal, pick the servos, and give simulations the real pivot location and servo limits.
- **spring 2027:** build it and bench-test deflection, speed, play and load.
- **summer 2027:** integrate with the airframe and run a motion test with a dummy motor mass.
- **works with:** simulations, electrical, software.

### electronics bay

- **owns:** the sled, mounting, access, vibration protection and cable routing for the flight computer, battery and radio.
- **winter 2027:** set the bay size from electrical's board and battery dimensions.
- **spring 2027:** build the bay and test-fit the real boards.
- **summer 2027:** final install, with the arming switch reachable from outside.
- **works with:** electrical, comms.

### recovery hardware

- **owns:** the parachute, shock cord, attachment points, packing method and ejection setup.
- **winter 2027:** choose the parachute and cord using the recovery sim's numbers.
- **spring 2027:** build it, write the packing procedure, and run a ground ejection test with the safety owner present.
- **summer 2027:** final packing procedure added to the launch checklist.
- **works with:** simulations, project lead for safety.

## simulations lead

Simulations predicts how the rocket will fly so the other teams can build to real numbers.

### flight and control sim

- **owns:** the openrocket model and the matlab two-axis pid sim. Current model: 1.29 cal stability, 266 m predicted apogee, and gains that still hold on the 4 in airframe.
- **winter 2027:** keep openrocket matched to cad, add servo lag, rate limits, sensor noise and the real loop rate, then retune. Export test vectors for software.
- **spring 2027:** update with built masses and measured gimbal limits, and support hardware-in-the-loop runs.
- **summer 2027:** final launch-day predictions (apogee, wind limits), then compare them against the flight.
- **works with:** software, mechanical.

### sensor fusion

- **owns:** the estimator that turns imu and barometer readings into attitude and altitude, and its noise models.
- **winter 2027:** a simulated estimator tested against noisy sensor models.
- **spring 2027:** run it on logged bench data and hand software a clear spec to implement.
- **summer 2027:** tune it with real sensor data and verify the firmware version against the sim.
- **works with:** software, electrical.

### recovery sim

- **owns:** descent rate, drift and landing speed under the parachute, and deployment timing. This sets the parachute size and the recovery plan.
- **winter 2027:** build the sim from the real parachute and mass numbers.
- **spring 2027:** check it against a drop test.
- **summer 2027:** predicted drift for launch-day winds, and a recovery plan for the landing area.
- **works with:** mechanical, project lead.

# electrical and simulations plan

Ethan Coliz leads electrical and simulations through winter, spring and summer 2027 and owns the technical build. The project lead (Cris) covers schedule, budget, orders and outside communication. For the full lead structure, see [ownership.md](ownership.md). For the flight computer parts and connections, see the flight controller spec.

## how the work is split

Ethan works mostly in writing: a short written update each week, and his designs and results in this repo. Cris is the first contact for new members, other leads and the Proxima board, and asks Ethan in writing when a technical answer is needed.

## who owns what

| area | owner | what that means |
| --- | --- | --- |
| flight computer board | Ethan | spec, schematic, layout, ordering, bring-up and test results |
| power, battery and arming | Ethan | power budget, regulators, battery choice, arming design, battery endurance test |
| flight and control sim | Ethan | OpenRocket model, PID sim, retuning, test vectors for software |
| sensor fusion | Ethan | estimator, noise models, tests on real sensor data |
| recovery sim and drop test | Ethan, with Terry | descent rate, drift and landing speed from Terry's parachute and mass numbers. Terry supplies the inputs and runs the drop test. This is the first thing to slip if time runs short. |
| schedule and gates | Cris | tracker, gate dates, weekly written status |
| budget and parts orders | Cris | prices Ethan's parts list, fits it to the Proxima budget request, places the orders |
| recruiting and first tasks | Cris, with Ethan | open invitation and onboarding by Cris. Ethan writes the first task for any member who joins electrical or sims. |
| reviews | Cris runs, Ethan writes | Cris sets the agenda and keeps notes and actions, Ethan writes a short technical summary for each review |
| outside world | Cris | Proxima board updates, sponsors, launch-site paperwork |

## how they work together

- Ethan posts a short written update each week in the team channel: done, blocked, next. This is the technical status, so no meeting is needed for it.
- Ethan attends the weekly leads sync with the project lead when he can. If he cannot, the written update stands in for him.
- Ethan has the final say on technical choices: parts, sim methods and designs. The project lead has the final say on schedule priorities and on what goes out to the Proxima board and the public.
- If a technical choice changes cost, the schedule or another team's interface, Ethan tells the project lead in writing first.
- These go to the project lead right away: a slip of more than a week against a gate, a budget overrun, any change to arming or flight-critical logic, and any interface change.
- Anything marked proposed or decided in the flight controller spec can be changed, as long as the reason is written down for the whole team.

## time

- **Ethan:** plan on 10 to 15 hours a week, the same as every lead.
- **Cris:** the schedule, orders and outreach work in this plan is part of the project lead role. If a gate week needs more than Ethan can give, the work moves to other members instead of stretching him.

## roadmap

The gates match [ownership.md](ownership.md).

### winter 2027 (jan to mar)

- **Ethan:** finish the flight computer spec and block diagram, then the schematic review, layout, and revision A order by mid-March. Finish the power budget with real current numbers and pick the battery and regulators. Update the sims with the real thrust curve, servo lag, rate limits, sensor noise and loop rate, then retune. Build sensor fusion v2 with accelerometer and gyro input, and export test vectors for software.
- **Cris:** set up the tracker and the weekly rhythm. Turn Ethan's parts list into a priced order list that fits the Proxima budget request. Post an open invitation for electrical and sims members. Run the electrical and sims design review before the freeze.
- **gate:** design freeze by the end of March, signed by every lead.

### spring 2027 (apr to jun)

- **Ethan:** assemble and bring up revision A with software (power rails, IMU, servos), fix issues and order revision B if needed. Run the tilt-table and battery endurance tests and write up the results. Run the estimator on logged bench data and hand software a clear spec. Update the sims with built masses and measured gimbal limits. Build the recovery sim from Terry's numbers and check it against the drop test.
- **Cris:** keep every order on schedule, with lead times tracked against the gate. Send a monthly update to the Proxima board. Start launch-site and approval paperwork. Set the agenda and notes for the June integration review.
- **gate:** integration review in june, each subsystem bench-tested alone.

### summer 2027 (jul to aug)

- **Ethan:** install the final board, run vibration and ground tests, and keep a flight spare. Tune the estimator on real sensor data and check the firmware against the sim. Produce final launch-day predictions: apogee and wind limits, plus predicted drift from the recovery sim. After the flight, pull the data and compare predicted against actual.
- **Cris:** write the recovery plan for the landing area with Terry and Ethan's drift numbers. Run the team retro and write handoff notes for recruiting for tvr-2. The flight report author is open: any member can take it, with the numbers from Ethan.
- **gate:** flight readiness review in early july, then launch in mid-july to august.

## if time runs short

- **Ethan:** keep the revision A date and the power design first, then the estimator, then the recovery sim and other sim extras.
- **Cris:** the weekly status and the orders come first. Outreach posts and the flight report text can slip.

# electrical and simulations plan

Abraham Yin Chen and Ethan Coliz co-lead electrical and simulations through winter, spring and summer 2027. Ethan owns the technical build. Abraham is the pm, plus works on a hands-on project of his own. For the full lead structure, see [ownership.md](ownership.md). For the flight computer parts and connections, see the flight controller spec.

## how the work is split

Ethan works mostly in writing: a short written update each week, and his designs and results in this repo. Abraham is the first contact for everyone else. New members, other leads and the Proxima board talk to Abraham, and Abraham asks Ethan in writing when a technical answer is needed.

## who owns what

| area | owner | what that means |
| --- | --- | --- |
| flight computer board | Ethan | spec, schematic, layout, ordering, bring-up and test results |
| power, battery and arming | Ethan | power budget, regulators, battery choice, arming design, battery endurance test |
| flight and control sim | Ethan | OpenRocket model, PID sim, retuning, test vectors for software |
| sensor fusion | Ethan | estimator, noise models, tests on real sensor data |
| recovery sim and drop test | Abraham | descent rate, drift and landing speed from Terry's parachute and mass numbers (see abraham's hands-on project) |
| schedule and gates | Abraham | tracker, gate dates, weekly written status |
| budget and parts orders | Abraham | prices Ethan's parts list, fits it to the Proxima budget request, places the orders |
| recruiting and first tasks | Abraham | open invitation, first task for each new member, onboarding |
| reviews | Abraham runs, Ethan writes | Abraham sets the agenda and keeps notes and actions, Ethan writes a short technical summary for each review |
| outside world | Abraham | Proxima board updates, sponsors, launch-site paperwork with Cris |

## how they work together

- Ethan posts a short written update each week in the team channel: done, blocked, next. This is the technical status, so no meeting is needed for it.
- Abraham runs the weekly electrical and sims meeting. He sends the agenda the day before and posts notes and action items within 24 hours. Ethan joins when he can.
- Abraham attends the weekly leads sync with the project lead and speaks for both. Ethan is welcome but not required.
- Ethan has the final say on technical choices: parts, sim methods and designs. Abraham has the final say on schedule priorities and on what goes out to the Proxima board and the public.
- If a technical choice changes cost, the schedule or another team's interface, Ethan tells Abraham in writing first. If they cannot settle something within a day, the project lead decides.
- These go to the project lead right away: a slip of more than a week against a gate, a budget overrun, any change to arming or flight-critical logic, and any interface change.
- Anything marked proposed or decided in the flight controller spec can be changed, as long as the reason is written down for the whole team.

## time

- **Ethan:** plan on 10 to 15 hours a week, the same as every lead.
- **Abraham:** about 5 hours a week at most. That is roughly 3 hours for project management and outreach and 2 hours for his hands-on project. If a gate week needs more than that, the work moves to the project lead or Ethan instead of stretching Abraham.

## abraham's hands-on project

Abraham picks one of these by the end of january. Each has a real result that other people use.

1. **recovery sim and drop test (recommended).** Build the sim for descent rate, drift and landing speed from Terry's parachute and mass numbers, then check it with a drop test. The result is the parachute choice and a predicted landing area for launch day. It has a clear finish and fits in about 2 hours a week.
2. **bench test helper.** Run the tilt-table and battery tests that Ethan sets up, and log the results.
3. **flight report.** After launch, write up predicted against actual with the numbers Ethan pulls, with photos and video.

## roadmap

The gates match [ownership.md](ownership.md).

### winter 2027 (jan to mar)

- **Ethan:** finish the flight computer spec and block diagram, then the schematic review, layout, and revision A order by mid-March. Finish the power budget with real current numbers and pick the battery and regulators. Update the sims with the real thrust curve, servo lag, rate limits, sensor noise and loop rate, then retune. Build sensor fusion v2 with accelerometer and gyro input, and export test vectors for software.
- **Abraham:** set up the tracker and the weekly rhythm. Turn Ethan's parts list into a priced order list that fits the Proxima budget request. Post an open invitation for electrical and sims members and write a first task for each person who joins, written so they can start from the doc alone. Pick his project and start the recovery sim. Run the electrical and sims design review before the freeze.
- **gate:** design freeze by the end of March, signed by every lead.

### spring 2027 (apr to jun)

- **Ethan:** assemble and bring up revision A with software (power rails, IMU, servos), fix issues and order revision B if needed. Run the tilt-table and battery endurance tests and write up the results. Run the estimator on logged bench data and hand software a clear spec. Update the sims with built masses and measured gimbal limits.
- **Abraham:** keep every order on schedule, with lead times tracked against the gate. Finish the recovery sim and run the drop test with Terry. Send a monthly update to the Proxima board. Start launch-site and approval paperwork with the project lead. Set the agenda and notes for the June integration review.
- **gate:** integration review in june, each subsystem bench-tested alone.

### summer 2027 (jul to aug)

- **Ethan:** install the final board, run vibration and ground tests, and keep a flight spare. Tune the estimator on real sensor data and check the firmware against the sim. Produce final launch-day predictions: apogee and wind limits. After the flight, pull the data and compare predicted against actual.
- **Abraham:** turn the recovery sim into a predicted drift and a recovery plan for the landing area. Write the flight report with the numbers from Ethan. Run the team retro and write handoff notes for recruiting for tvr-2.
- **gate:** flight readiness review in early july, then launch in mid-july to august.

## if time runs short

- **Ethan:** keep the revision A date and the power design first, then the estimator, then sim extras.
- **Abraham:** the weekly status and the orders come first. Outreach posts and the flight report text can slip.

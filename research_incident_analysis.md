# Incident Analysis and Learning Loops — NASA Mishap Investigation Applied to Software Engineering

## Research Reference Document

---

## 1. NASA's Mishap Investigation Framework

### 1.1 Governing Document: NPR 8621.1

NASA's mishap investigation and reporting requirements are codified in **NASA Procedural Requirements (NPR) 8621.1**, titled *"Mishap and Close Call Reporting, Investigating, and Recordkeeping."* This document establishes the agency-wide framework for how NASA identifies, reports, investigates, and learns from mishaps and close calls. It applies to all NASA centers, programs, and contractors operating under NASA oversight.

Key elements of NPR 8621.1B:

- **Mandatory reporting**: All mishaps and close calls must be reported, regardless of severity. The standard creates a reporting obligation that extends from the individual employee level up through center directors to the NASA Chief Safety Officer.
- **Timeliness requirements**: Initial notification must occur within specific timeframes depending on severity — Type A mishaps require notification to NASA HQ within 1 hour. Type B mishaps require notification within 24 hours.
- **Investigation proportional to severity**: The depth and formality of investigation scales with the mishap classification (Type A through D).
- **Corrective action tracking**: All investigations must result in documented corrective actions, with assigned owners and completion deadlines. These are tracked to closure.
- **Integration with OSHA and other regulatory requirements**: NPR 8621.1B aligns NASA's internal mishap process with Occupational Safety and Health Administration (OSHA) reporting requirements and Department of Defense standards where applicable.

**Source**: NASA Procedural Requirements NPR 8621.1B, "Mishap and Close Call Reporting, Investigating, and Recordkeeping," NASA Office of Safety and Mission Assurance. Available via NASA's Standards and Technical Publications system (standards.nasa.gov).

### 1.2 Mishap Investigation Board (MIB) Structure

For significant mishaps (Type A and B), NASA convenes a **Mishap Investigation Board (MIB)**. The structure is deliberately designed to ensure independence, technical rigor, and organizational authority.

**MIB Composition**:

| Role | Responsibility |
|------|---------------|
| **Chairperson** | Senior official, typically from outside the program that experienced the mishap. Appointed by the NASA Administrator or Center Director depending on severity. Has full authority over investigation scope and findings. |
| **Board Members** | Subject matter experts drawn from relevant engineering disciplines, safety, quality assurance, and operations. Typically 5–12 members. |
| **Ex Officio Members** | Representatives from the Office of the Chief Engineer, Office of Safety and Mission Assurance, and legal counsel. Participate but do not vote on findings. |
| **Technical Advisors** | Additional experts brought in for specific technical analysis (e.g., materials science, software, propulsion). |
| **Recorder/Administrative Support** | Manages evidence collection, witness interviews, documentation, and report preparation. |

**Key principles of MIB operation**:

- **Independence**: The MIB must be independent of the organization that experienced the mishap. This prevents conflicts of interest and ensures objectivity.
- **Privilege**: Investigation communications and deliberations are typically conducted under a "privilege" framework to encourage candid disclosure without fear of punitive use.
- **Evidence preservation**: Formal evidence impoundment procedures are initiated immediately upon mishap occurrence. Physical evidence, telemetry data, logs, communications records, and procedural documents are all preserved.
- **Witness interviews**: Conducted formally, often with legal counsel present. Interview records become part of the privileged investigation file.

For less severe mishaps (Type C and D), a **Mishap Investigation Team (MIT)** or **Investigating Official** may be appointed instead of a full board, following a streamlined but still structured process.

**Source**: NPR 8621.1B, Chapter 5; NASA Safety Center resources on mishap investigation methodology.

### 1.3 Mishap Classification: Type A through D

NASA classifies mishaps into four severity types based on consequence:

| Type | Criteria | Investigation Authority |
|------|----------|----------------------|
| **Type A** | Death or permanently disabling injury; destruction of a crewed flight system; property damage ≥ $2 million; or full loss of a major mission. | NASA Administrator appoints MIB. Reported to Congress and the public. |
| **Type B** | Hospitalization of 3+ people; significant injury/illness; property damage ≥ $500,000 but < $2 million; major but not total mission impact. | Center Director appoints MIB. Reported to NASA HQ. |
| **Type C** | Lost-time occupational injury/illness; property damage ≥ $50,000 but < $500,000; some mission impact. | Center-level investigation team. |
| **Type D** | First-aid-treatable injury; property damage < $50,000; minimal impact. | Local investigation or documented review. |

Additionally, NASA recognizes **"Close Calls"** (also called "near misses") — events that did not result in a mishap but had the potential to do so. Close calls are reported and analyzed using the same root cause methodology, recognizing that the difference between a close call and a Type A mishap is often a matter of luck rather than design.

**Relevance to software engineering**: This graduated classification system maps directly to incident severity levels used in software operations (SEV-1 through SEV-4 or P0 through P3). The key insight is that investigation rigor should scale with impact, and that "close calls" (near-misses, caught-in-time bugs, narrowly avoided outages) deserve the same analytical attention as actual incidents.

**Source**: NPR 8621.1B, Chapter 3, "Mishap Classification"; NASA Safety Center, "Mishap Investigation" training materials.

### 1.4 Root Cause Analysis Methodology

NASA's root cause analysis (RCA) framework distinguishes between three categories of causal factors:

**Proximate Cause**: The event or condition that directly resulted in the mishap. This is the immediate, observable trigger. Example: a valve failed to close, causing a propellant leak.

**Root Cause**: The fundamental, underlying reason the proximate cause occurred. Eliminating the root cause would prevent recurrence of this specific mishap and similar mishaps. Example: the valve failed because a design review did not evaluate the valve's performance under the actual thermal cycling conditions it would experience, due to an incomplete requirements flowdown process.

**Contributing Factors**: Conditions or events that, while not directly causal, increased the likelihood or severity of the mishap. Example: schedule pressure led to reduced testing, maintenance procedures were ambiguous, or previous anomalies with similar valves were not effectively communicated across programs.

**NASA's RCA tools and methods include**:

1. **5-Why Analysis**: Iterative questioning to drill from symptoms to root causes. Simple but effective for straightforward causal chains.

2. **Causal Factor Charting**: A timeline-based technique that maps events and conditions leading to the mishap. Each event is analyzed for causal factors, and the chart traces causal chains from the mishap backward through proximate causes to root causes.

3. **Barrier Analysis**: Identifies what barriers (physical, procedural, administrative) should have prevented the mishap, and why each barrier failed. This is particularly powerful for understanding defense-in-depth failures.

4. **Change Analysis**: Compares the mishap situation to a baseline "normal" situation to identify what changed. Useful when systems that previously worked correctly begin to fail.

5. **Management Oversight and Risk Tree (MORT)**: A comprehensive analytical technique that evaluates both the specific technical failure and the management system failures that allowed it. MORT is particularly valuable because it forces investigation of organizational and programmatic factors, not just technical ones.

6. **Fault Tree Analysis** and **Event Tree Analysis**: Described in detail in Sections 2 and 3 below.

**The critical distinction**: NASA's framework insists that identifying only the proximate cause is insufficient. An investigation that stops at "the software had a bug" or "the operator made an error" has not reached the root cause. The root cause is *why* the bug was introduced and not caught, or *why* the operating conditions allowed human error to propagate to a system failure.

**Source**: NASA Root Cause Analysis guidance documents; NASA-GB-A302, "NASA Root Cause Analysis (RCA) Overview"; DOE-NE-STD-1004-92, "Root Cause Analysis Guidance Document" (used as reference across federal agencies including NASA).

### 1.5 Corrective Action Verification and Close-out

NASA's process does not end with the investigation report. Corrective actions must be:

1. **Documented**: Each corrective action is formally described, including what it addresses (which root cause or contributing factor), who is responsible, and the deadline.

2. **Classified**: Corrective actions are categorized as:
   - **Corrective actions**: Fix the specific issue that caused this mishap.
   - **Preventive actions**: Address systemic issues to prevent similar mishaps in other systems or programs.

3. **Tracked**: Actions are entered into NASA's corrective action tracking system and monitored by the Office of Safety and Mission Assurance.

4. **Verified**: Before an action can be closed, independent verification must confirm that the action was actually implemented and that it effectively addresses the identified cause.

5. **Closed out**: Formal close-out requires sign-off from the investigating authority (MIB chair or equivalent) and the responsible safety organization.

**The close-out gap**: One of the most common failure modes in incident management — in NASA and in software organizations alike — is that corrective actions are identified but never completed, or are completed in a weakened form that doesn't actually address the root cause. NASA's formal tracking and verification process is designed to prevent this. The analogy in software engineering is the difference between "we created a Jira ticket" and "we verified the fix is deployed, tested, and effective."

**Source**: NPR 8621.1B, Chapter 7, "Corrective Action Process"; NASA Safety Center, "Corrective Action/Preventive Action (CAPA) Process."

---

## 2. Fault Tree Analysis (FTA)

### 2.1 Definition and Purpose

**Fault Tree Analysis (FTA)** is a top-down, deductive failure analysis technique that uses Boolean logic to model how combinations of lower-level events can lead to an undesired top-level event (the "top event"). FTA was originally developed at Bell Telephone Laboratories in 1962 for the Minuteman missile program, and was subsequently adopted by NASA, the nuclear industry, and aerospace as a primary hazard analysis method.

FTA answers the question: **"What combinations of component failures, human errors, and external events could cause this specific system failure?"**

**Source**: NASA Fault Tree Handbook with Aerospace Applications (NASA Publication), 2002; W.E. Vesely et al., "Fault Tree Handbook," NUREG-0492, U.S. Nuclear Regulatory Commission, 1981.

### 2.2 Structure and Logic Gates

A fault tree is a graphical model consisting of:

**Top Event**: The undesired system-level failure being analyzed (e.g., "Loss of vehicle," "Complete API outage," "Unauthorized data exposure").

**Intermediate Events**: Failures or conditions at subsystem or component levels that contribute to the top event.

**Basic Events**: The lowest-level failures in the model — individual component failures, human errors, or environmental conditions that cannot be further decomposed.

**Logic Gates**:

- **OR Gate**: The output event occurs if **any one** of the input events occurs. OR gates model situations where there is no redundancy — any single failure path independently causes the higher-level event. A system with good redundancy would use AND gates instead.

  ```
       [System Failure]
            |
         [OR Gate]
        /    |    \
   [Fail A] [Fail B] [Fail C]
  ```

- **AND Gate**: The output event occurs only if **all** input events occur simultaneously. Represents defense-in-depth — all defenses must fail for the higher-level event to occur.

  ```
       [System Failure]
            |
        [AND Gate]
        /        \
   [Fail A]    [Fail B]
  ```

- **Inhibit Gate**: A special AND gate where one input is a conditional event (a condition that must be present for the other input to propagate).

- **Transfer Gates**: Used to connect sub-trees, managing complexity in large fault trees.

**Undeveloped Events**: Events that are not further analyzed, either because they are outside the scope or because insufficient information is available.

### 2.3 Minimal Cut Sets

A **cut set** is a combination of basic events that, if all occur, will cause the top event. A **minimal cut set (MCS)** is a cut set where removing any single event would prevent the top event — it is the smallest necessary combination.

The analysis of minimal cut sets reveals:

- **Single-point failures**: Minimal cut sets of size 1 — a single basic event that alone causes the top event. These represent the most critical vulnerabilities and highest-priority items for mitigation.
- **Common cause failures**: When the same underlying condition appears in multiple minimal cut sets, indicating systemic vulnerability.
- **Defense-in-depth effectiveness**: The size of minimal cut sets indicates how many independent failures must co-occur. Larger cut sets indicate more robust defense-in-depth.

**Quantitative FTA**: When probability data is available for basic events, the fault tree can be evaluated quantitatively to estimate the probability of the top event. This uses the inclusion-exclusion principle for OR gates and simple multiplication for AND gates (assuming independence).

### 2.4 How NASA Uses FTA

NASA applies FTA extensively in:

- **Probabilistic Risk Assessment (PRA)**: FTA is a core component of NASA's PRA methodology, used to quantify mission and safety risk. NASA-STD-8719.13A, "NASA Software Safety Standard," specifically requires fault tree analysis for safety-critical software.
- **Hazard analysis**: FTA is used during design to identify potential failure modes and verify that adequate controls exist.
- **Mishap investigation**: After an incident, FTA is used to systematically map the failure logic and identify all contributing paths.
- **Requirements verification**: FTA can verify that safety requirements adequately address identified hazards.

**Source**: NASA, "Fault Tree Handbook with Aerospace Applications," 2002 (prepared by NASA Office of Safety and Mission Assurance); NASA-STD-8719.13A, "NASA Software Safety Standard."

### 2.5 FTA Applied to Software Failure Analysis

Software systems differ from hardware in that software doesn't "wear out" — software failures are fundamentally design defects or interaction failures. However, FTA remains highly applicable:

**Example: Fault Tree for "Complete API Gateway Outage"**

```
                    [Complete API Gateway Outage]
                              |
                           [OR Gate]
                   /          |           \
    [All instances      [Upstream DNS    [Configuration
     simultaneously      resolution       error causes
     crash]              failure]         all routes to
        |                    |            reject traffic]
     [OR Gate]           [AND Gate]           |
      /      \           /       \        [OR Gate]
[OOM Kill] [Panic   [Primary  [Secondary  /        \
 due to    due to    DNS       DNS      [Bad deploy [Config
 memory    unhandled fails]    fails]    propagated]  store
 leak]     error]                                  corrupted]
```

Key insights from this fault tree:

1. The DNS failure path has an **AND gate** — both primary and secondary DNS must fail — indicating defense-in-depth.
2. The configuration error paths are **OR gates** — either a bad deploy or config store corruption alone causes the outage — indicating single-point-of-failure risk.
3. The OOM and panic paths are also single-point failures within the "all instances crash" branch.

This analysis immediately identifies where to invest in additional defenses: the configuration paths need AND gates (e.g., canary deployments, config validation, rollback mechanisms).

### 2.6 Practical Steps for Software FTA

1. **Define the top event precisely**: Not "system is slow" but "API response latency exceeds 5 seconds for >50% of requests for >5 minutes."
2. **Decompose using OR and AND gates**: Ask "what could cause this?" at each level. If multiple things must fail simultaneously, use AND. If any single failure suffices, use OR.
3. **Identify basic events**: Continue decomposition until you reach events that are atomic and can be assigned probability estimates or mitigation strategies.
4. **Find minimal cut sets**: Identify the smallest combinations of failures that cause the top event. Single-point failures are highest priority.
5. **Assign mitigations**: For each minimal cut set, identify existing controls and gaps. Convert OR gates to AND gates by adding independent defenses.

**Source**: Ericson, C.A., "Hazard Analysis Techniques for System Safety," Wiley, 2005; Stamatelatos, M. et al., "Fault Tree Handbook with Aerospace Applications," NASA, 2002.

---

## 3. Event Tree Analysis (ETA)

### 3.1 Definition and Forward-Looking Analysis

**Event Tree Analysis (ETA)** is an inductive, forward-looking analysis technique that models the possible outcomes following an **initiating event**. While fault trees work backward from a failure ("what could cause this?"), event trees work forward from a trigger ("given this happened, what are the possible outcomes?").

An event tree begins with an initiating event (e.g., "a request spike occurs," "a disk fills up," "an authentication service becomes unavailable") and then traces the sequence of subsequent events, safety barriers, and system responses that determine the final outcome.

### 3.2 Structure

An event tree is structured as a horizontal branching diagram:

```
Initiating     Barrier 1:      Barrier 2:       Barrier 3:
Event          Auto-scaling    Circuit Breaker  Alerting &
               triggers        activates        Manual Response    Outcome
    |              |                |                |
    |---[Success]--|---[Success]----|---[N/A]--------|---> Graceful handling (no impact)
    |              |                |
    |              |                |---[Failure]----|---> Degraded but functional
    |              |
    |              |---[Failure]----|---[Success]----|---> Brief outage, fast recovery
    |                               |
    |                               |---[Failure]----|---> Extended outage
    |
    |---[Failure]--|---[Success]----|---[N/A]--------|---> Partial degradation
                   |
                   |---[Failure]----|---[Success]----|---> Outage with slow recovery
                                    |
                                    |---[Failure]----|---> Cascading failure, major outage
```

Each branching point represents a **safety barrier** or **system response**, with branches for success (barrier works) and failure (barrier doesn't work). The rightmost column lists the possible outcomes with their associated severity.

### 3.3 How Event Trees Complement Fault Trees

FTA and ETA are complementary techniques:

| Aspect | Fault Tree Analysis | Event Tree Analysis |
|--------|-------------------|-------------------|
| **Direction** | Backward (deductive): starts from failure, works back to causes | Forward (inductive): starts from initiating event, works forward to outcomes |
| **Question answered** | "What could cause this failure?" | "If this event occurs, what happens next?" |
| **Best used for** | Identifying root causes and failure combinations | Evaluating barrier effectiveness and outcome scenarios |
| **Output** | Minimal cut sets, failure probability | Outcome probabilities, barrier importance |

**Combined use (Bow-Tie Analysis)**: NASA and the process safety industry often combine FTA and ETA in a "bow-tie" model. The fault tree forms the left side (causes leading to the initiating event), and the event tree forms the right side (outcomes following the initiating event). The initiating event is the "knot" of the bow-tie. This provides a complete picture: what causes the event, and what happens after it occurs.

### 3.4 Application to Incident Scenarios

**Example: Initiating Event — Database Primary Fails Over**

```
DB Failover   App handles    Connection     Retry storm    Monitoring     Outcome
Occurs        reconnection   pool recovers  prevented      detects &
              gracefully                                    alerts
   |
   |-[Yes]----|---[Yes]-------|---[N/A]------|---[N/A]------|--> No user impact
   |          |
   |          |---[No]--------|---[Yes]------|---[N/A]------|--> Brief errors, auto-recovery
   |                          |
   |                          |---[No]-------|---[Yes]------|--> Degraded, manual intervention
   |                                         |
   |                                         |---[No]------|--> Cascading failure
   |
   |-[No]-----|---[Yes]-------|---[N/A]------|---[N/A]------|--> Errors during reconnect, recovery
              |
              |---[No]--------|---[Yes]------|---[Yes]------|--> Extended degradation, contained
                              |              |
                              |              |---[No]------|--> Full outage
                              |
                              |---[No]-------|-------------|--> Catastrophic cascading failure
```

This event tree immediately reveals which barriers are most critical. If the application doesn't handle reconnection gracefully (first barrier fails), the downstream consequences branch into increasingly severe scenarios. It also shows that monitoring/alerting is the "last line of defense" — if all automated barriers fail, human response is the final barrier.

**Source**: NASA Systems Engineering Handbook (NASA/SP-2016-6105 Rev2), Section 6.4; IEC 62502:2010, "Analysis techniques for dependability — Event tree analysis (ETA)."

---

## 4. Automotive Failure Analysis

### 4.1 ISO 26262 HARA (Hazard Analysis and Risk Assessment)

**ISO 26262** is the international standard for functional safety of electrical and electronic systems in road vehicles. Its Hazard Analysis and Risk Assessment (HARA) process, defined in Part 3 of the standard, is one of the most rigorous and systematic approaches to identifying and classifying hazards.

**HARA Process Steps**:

1. **Situation Analysis**: Define the item (system under analysis) and its operational situations. For a vehicle, this means considering all driving scenarios (highway, city, parking, etc.). For an API platform, this maps to all operational contexts (peak load, deployment, failover, etc.).

2. **Hazard Identification**: Systematically identify malfunctioning behaviors and their effects. What happens if the system provides incorrect output? What if it fails to respond? What if it responds too slowly?

3. **Hazard Classification**: Each hazard is classified using three parameters:

   - **Severity (S0–S3)**: How bad is the consequence?
     - S0: No injuries
     - S1: Light and moderate injuries
     - S2: Severe and life-threatening injuries (survival probable)
     - S3: Life-threatening injuries (survival uncertain) or fatal

   - **Exposure (E0–E4)**: How likely is the operational situation?
     - E0: Incredible
     - E1: Very low probability
     - E2: Low probability
     - E3: Medium probability
     - E4: High probability

   - **Controllability (C0–C3)**: Can the driver/user control the situation?
     - C0: Controllable in general
     - C1: Simply controllable
     - C2: Normally controllable
     - C3: Difficult to control or uncontrollable

4. **ASIL Determination**: The combination of S, E, and C determines the **Automotive Safety Integrity Level (ASIL)**, ranging from ASIL A (lowest) to ASIL D (highest), or QM (quality management — no specific safety requirements).

   ASIL D requires the most rigorous development, verification, and validation processes. It maps conceptually to the highest levels of software system criticality.

**Source**: ISO 26262:2018, "Road vehicles — Functional safety," Parts 1–12, International Organization for Standardization.

### 4.2 FMEA and FMEDA

**Failure Mode and Effects Analysis (FMEA)** is a bottom-up analysis technique that systematically evaluates each component's potential failure modes, their effects on the system, and the existing controls to detect or prevent them.

**FMEA Process**:

1. **Identify functions**: List every function the system/component performs.
2. **Identify failure modes**: For each function, identify how it could fail (e.g., fails to perform, performs incorrectly, performs at wrong time, performs when not required).
3. **Identify effects**: What is the consequence of each failure mode at the local, subsystem, and system level?
4. **Identify causes**: What could cause each failure mode?
5. **Identify controls**: What existing design features, tests, or processes detect or prevent each failure mode?
6. **Assess risk**: Rate each failure mode on:
   - **Severity (1–10)**: Impact of the failure effect
   - **Occurrence (1–10)**: Likelihood of the cause occurring
   - **Detection (1–10)**: Likelihood that existing controls will detect the failure before it reaches the customer
7. **Calculate RPN**: Risk Priority Number = Severity x Occurrence x Detection. Used to prioritize mitigation efforts.
8. **Recommend actions**: For high-RPN items, identify additional controls or design changes.

**D-FMEA (Design FMEA)** specifically focuses on design-phase analysis:

- Applied during the design phase, before manufacturing/deployment
- Evaluates design adequacy against requirements
- Identifies design weaknesses that could lead to failure
- Feeds into design verification and validation planning
- Required by IATF 16949 (automotive quality management system) and ISO 26262

**FMEDA (Failure Modes, Effects, and Diagnostic Analysis)** extends FMEA by adding:

- Quantitative failure rate data for each failure mode
- Analysis of diagnostic coverage — what percentage of failures are detected by built-in diagnostics?
- Calculation of safe failure fraction and diagnostic coverage metrics required by IEC 61508 and ISO 26262
- Distinction between safe failures, dangerous detected failures, and dangerous undetected failures

**Source**: SAE J1739, "Potential Failure Mode and Effects Analysis in Design (Design FMEA), Potential Failure Mode and Effects Analysis in Manufacturing and Assembly Processes (Process FMEA)"; AIAG & VDA FMEA Handbook, 1st Edition, 2019; IEC 61508, "Functional safety of electrical/electronic/programmable electronic safety-related systems."

### 4.3 How Automotive Tracks Field Failures Back to Development

The automotive industry has a mature closed-loop process for connecting field failures to development improvements:

1. **Warranty claim analysis**: Every warranty repair is coded with failure mode information and fed into centralized databases.
2. **8D Problem Solving**: When field failure patterns emerge, formal 8D reports are generated:
   - D1: Team formation
   - D2: Problem description
   - D3: Interim containment action
   - D4: Root cause analysis
   - D5: Permanent corrective action selection
   - D6: Implementation and validation
   - D7: Prevention of recurrence
   - D8: Team recognition and closure
3. **Lessons learned integration**: Corrective actions from field failures are fed back into design standards, FMEA databases, and design review checklists.
4. **FMEA update cycle**: Production FMEAs are "living documents" that must be updated when new failure modes are discovered in the field.

**Source**: AIAG, "CQI-20: Effective Problem Solving Practitioner Guide"; VDA Volume 8D, "Problem Solving in 8 Disciplines."

---

## 5. The Normalization of Deviance

### 5.1 Diane Vaughan's Research on the Challenger Disaster

Sociologist **Diane Vaughan** coined the term **"normalization of deviance"** in her 1996 book *The Challenger Launch Decision: Risky Technology, Culture, and Deviance at NASA*. Through meticulous analysis of thousands of pages of NASA documents and years of research, Vaughan showed that the O-ring erosion problem that ultimately caused the Challenger disaster was not a sudden, surprising failure — it was a gradually accepted deviation from expected performance.

**The mechanism of normalization**:

1. **Initial deviation**: Engineers observed O-ring erosion on early shuttle flights — behavior outside the original design specifications.
2. **Rationalization**: Engineers analyzed the erosion, determined that it was within an "acceptable" safety margin, and documented this assessment.
3. **Precedent setting**: Each flight with erosion that didn't result in failure reinforced the belief that the erosion was acceptable.
4. **Expanded boundaries**: Over time, the definition of "acceptable" erosion expanded. What was initially an anomaly became an expected condition.
5. **Cultural embedding**: The acceptance of O-ring erosion became part of the organizational culture and institutional knowledge. New engineers inherited the normalized expectation.
6. **Catastrophic revelation**: On January 28, 1986, cold temperatures pushed the O-ring erosion beyond even the expanded "acceptable" boundary, resulting in the loss of Challenger and its crew.

**Vaughan's key insight**: The engineers and managers at NASA were not reckless or negligent in the conventional sense. They were following their organization's rules and norms — but those norms had gradually shifted to accept risk that the original design never intended. The deviance was **normalized through a social process**, not through individual bad decisions.

**Source**: Vaughan, Diane. *The Challenger Launch Decision: Risky Technology, Culture, and Deviance at NASA*. University of Chicago Press, 1996. ISBN: 978-0226851761.

### 5.2 How Normalization of Deviance Manifests in Software Engineering

The parallels to software engineering are striking and pervasive:

**Ignored warnings and alerts**:
- A monitoring system generates alerts that are reviewed and deemed "not actionable." Over time, the team stops investigating that alert category entirely. The volume of ignored alerts increases. Eventually, a genuine critical alert is lost in the noise. This is alert fatigue — the software equivalent of accepting O-ring erosion.
- Example: A log aggregator shows occasional `connection timeout` errors to a dependency. Initially investigated, found to be transient, and documented as acceptable. Over months, the frequency increases from 0.01% to 0.1% to 1%. Each increment is individually "small." No one notices the trend. When the dependency degrades further, the system lacks the resilience margins that the original design assumed.

**Skipped code reviews**:
- A team under deadline pressure merges a PR with a cursory review. Nothing bad happens. The next time there's pressure, the precedent exists. Over time, "thorough review" is redefined to match whatever the team actually does, rather than what the process originally required.

**Accumulated technical debt**:
- A shortcut is taken with a TODO comment. It works. More TODOs accumulate. The codebase gradually diverges from its documented architecture. The gap between "how we think the system works" and "how the system actually works" widens — a particularly dangerous form of normalization because it undermines the validity of all analysis built on the assumed architecture.

**Degraded testing**:
- A test suite becomes flaky. Tests are re-run until they pass. Flaky tests are eventually skipped or marked as expected failures. The effective coverage decreases while the nominal coverage number remains unchanged.

**SLA erosion**:
- A service that should respond in 100ms starts occasionally taking 200ms. Deemed acceptable. Clients build in longer timeouts. The "normal" latency gradually creeps upward. The original performance budget that ensured end-to-end responsiveness is consumed by accumulated small degradations.

### 5.3 Countermeasures

Vaughan's research suggests that normalization of deviance is **not preventable by individual vigilance alone** — it requires structural and cultural countermeasures:

1. **Quantitative baselines with drift detection**: Don't just monitor current values — monitor the trend. Alert on degradation from baseline, not just threshold violations.
2. **Regular "return to design intent" reviews**: Periodically compare actual system behavior, processes, and configurations against original design specifications. Identify and explicitly evaluate all deviations.
3. **Independent assessment**: Bring in people from outside the team who don't share the team's normalized expectations. Fresh eyes can see deviations that insiders have learned to accept.
4. **Mandatory anomaly investigation**: Every anomaly gets investigated, even if the immediate impact is small. The goal is not to fix each individual anomaly but to detect drift.
5. **Written standards with version control**: When "acceptable" is redefined, it should be a deliberate, documented decision with explicit justification — not an undocumented cultural shift.

**Source**: Vaughan, 1996 (op. cit.); Dekker, Sidney. *Drift into Failure: From Hunting Broken Components to Understanding Complex Systems*. Ashgate, 2011. ISBN: 978-1409422211.

### 5.4 James Reason's Swiss Cheese Model

James Reason's **Swiss Cheese Model** (1990) is one of the most widely referenced frameworks for understanding how incidents penetrate multiple defenses. Each defensive layer (design, procedures, training, monitoring, alarms) is modeled as a slice of Swiss cheese — mostly solid but with holes representing weaknesses. An incident occurs when the holes in multiple layers momentarily align, allowing a hazard trajectory to pass through all defenses.

The model emphasizes that incidents are rarely caused by a single failure; they result from the alignment of multiple **latent conditions**. Latent conditions — such as design flaws, maintenance gaps, procedural ambiguities, or training deficiencies — may exist for long periods without consequence. An incident materializes only when these latent conditions combine with an **active failure** (an error or violation at the operational level) and the holes align across all defensive layers.

For software teams, defensive layers include: code review, automated testing, staging environments, canary deployment, runtime monitoring, and incident response. Each layer is imperfect — code review may miss edge cases, tests may lack coverage for certain failure modes, staging may not perfectly replicate production, and monitoring may have blind spots.

The Swiss Cheese Model teaches that strengthening any single layer has diminishing returns — the goal is **defense in depth** with diverse, independent layers. When an incident occurs, the investigation should examine which holes existed in each layer and why, rather than focusing exclusively on the active failure that happened to trigger the final breach. This aligns directly with NASA's emphasis on identifying root causes and contributing factors across organizational, procedural, and technical dimensions.

**Source**: Reason, J. (1990). *Human Error*. Cambridge University Press.

---

## 6. Learning Loops and Organizational Memory

### 6.1 NASA's Lessons Learned Information System (LLIS)

NASA's **Lessons Learned Information System (LLIS)** is a publicly accessible database (llis.nasa.gov) containing lessons derived from NASA programs, projects, and mishap investigations. Established in the 1990s, LLIS represents one of the most ambitious attempts by any organization to create institutional memory for engineering lessons.

**LLIS entry structure**:

Each lesson in LLIS contains:
- **Lesson title and abstract**: Concise summary
- **Driving event**: What happened that generated this lesson
- **Lesson(s) learned**: The specific insight or knowledge gained
- **Recommendation(s)**: Actionable guidance for future programs
- **Evidence of recurrence**: Documentation that this type of issue has occurred before (reinforcing the importance of the lesson)
- **Program/project**: Source context
- **Approval chain**: LLIS entries go through a review and approval process before publication

**Challenges NASA has faced with LLIS**:

Despite significant investment, NASA has acknowledged challenges with LLIS effectiveness:

1. **Discovery problem**: Engineers don't know to search for a lesson they don't know exists. LLIS is a pull system — users must actively seek lessons.
2. **Relevance matching**: Lessons from a Mars rover program may be highly relevant to a satellite program, but keyword-based search may not surface the connection.
3. **Currency**: Some lessons become outdated as technology and processes evolve, but the database doesn't always reflect this.
4. **Incentive alignment**: Writing up lessons is time-consuming and competes with project work. Without strong organizational incentives, lesson submission rates decline.
5. **Absorption capacity**: Organizations have a limited ability to absorb and apply new lessons. Information overload can make a lessons-learned system less effective even as it grows larger.

The **Columbia Accident Investigation Board (CAIB) Report** (2003) specifically called out NASA's failure to learn from previous lessons, noting that many of the organizational factors in the Columbia disaster echoed findings from the Challenger investigation 17 years earlier.

**Source**: NASA Lessons Learned Information System, llis.nasa.gov; Columbia Accident Investigation Board, *Report of the Columbia Accident Investigation Board, Volume 1*, NASA, 2003; Mahler, Julianne G. and Casamayou, Maureen Hogan, *Organizational Learning at NASA: The Challenger and Columbia Accidents*, Georgetown University Press, 2009.

### 6.2 Building a Lessons-Learned System That Gets Used

Based on NASA's experience and organizational learning research, an effective lessons-learned system requires:

**Push, not just pull**: Don't rely solely on people searching a database. Actively push relevant lessons to teams at decision points:
- During design reviews, automatically surface lessons related to the technologies and failure modes being discussed.
- During incident response, surface lessons from similar past incidents.
- During onboarding, include relevant lessons in training materials.

**Low friction capture**: The effort required to submit a lesson must be proportional to the lesson's importance. Use templates, but don't make them bureaucratic for routine observations.

**Mandatory integration points**: Build lesson review into existing processes:
- Every design review checklist should include "Have relevant lessons from LLIS/prior incidents been reviewed?"
- Every post-incident review should include "What existing lessons are relevant, and what new lesson does this generate?"

**Curation and expiration**: Lessons need maintenance. Assign ownership, review for continued relevance, and retire lessons that are no longer applicable.

**Narrative context**: The most effective lessons include the story — not just "do X" but "we failed because of Y, and here's the context that made Y seem reasonable at the time." Narrative is more memorable and transferable than prescriptive rules.

### 6.3 Blameless Postmortems vs. NASA's Accountability Model

The software industry's **blameless postmortem** culture (popularized by Google, Etsy, and others) and NASA's **accountability-based** investigation model represent different but potentially complementary approaches.

**Blameless postmortems (software industry)**:
- Assume that individuals acted rationally given the information and pressures they had.
- Focus on systemic factors: tooling, processes, information flow, system design.
- Explicitly prohibit blame or punishment based on investigation findings.
- Goal: maximize psychological safety to encourage complete and honest disclosure.
- Risk: Can devolve into "blameless but also actionless" — identifying systemic issues without anyone being accountable for fixing them.

**NASA's accountability model**:
- Distinguishes between **individual accountability** and **blame**. Accountability means that responsible parties are identified and expected to take ownership of corrective actions.
- Uses the concept of **"responsible engineering authority"** — the person whose role includes ownership of specific technical decisions. This person is accountable for understanding and managing the associated risks.
- Does assign organizational and management responsibility when investigation reveals management failures (inadequate resources, unreasonable schedule pressure, failure to maintain technical oversight).
- Does **not** use mishap investigation findings for punitive personnel actions (this is similar to the blameless approach), but **does** expect responsible parties to acknowledge findings and implement changes.
- Goal: accountability without punishment, but with clear ownership of corrective actions.

**The synthesis for software organizations**:
The most effective approach combines elements of both:
1. **Psychological safety during investigation**: No punishment for honest disclosure. Focus on understanding what happened and why.
2. **Clear ownership of corrective actions**: Every action item has an owner with authority and accountability to complete it.
3. **Organizational accountability**: When investigation reveals systemic issues (e.g., insufficient staffing, training gaps, tooling deficiencies), management is accountable for addressing them.
4. **Distinguish between error and negligence**: Honest mistakes in complex systems are treated as learning opportunities. Deliberate circumvention of safety controls is treated differently.

**Source**: Dekker, Sidney. *Just Culture: Balancing Safety and Accountability*. Ashgate, 2007; Allspaw, John. "Blameless PostMortems and a Just Culture," Etsy Code as Craft blog, 2012; Google SRE Book, Chapter 15: "Postmortem Culture: Learning from Failure," O'Reilly, 2016.

### 6.4 Corrective vs. Preventive Actions

NASA (and ISO quality management standards) distinguish between:

**Corrective Action**: Eliminates the cause of a detected nonconformity or undesirable situation **to prevent recurrence**. Applied after an incident. Addresses the specific root cause found. Example: "The configuration validation check was missing the schema for rate-limit fields. We added schema validation for all rate-limit configuration parameters."

**Preventive Action**: Eliminates the cause of a **potential** nonconformity or undesirable situation **to prevent occurrence**. Applied proactively based on risk analysis or trends. Example: "We discovered that our configuration validation doesn't cover all configuration parameters. We implemented a meta-check that verifies every configuration parameter has a corresponding schema entry, so that newly added parameters cannot lack validation."

The distinction matters because corrective actions fix the specific hole, while preventive actions strengthen the entire system against the class of failure. Effective incident response generates both.

### 6.5 Closing the Loop: Incident to Process Change

The full learning loop:

```
Incident → Detection → Response → Stabilization → Investigation →
Root Cause Identification → Corrective Action Definition →
Action Implementation → Verification → Process/System Update →
Knowledge Capture → Dissemination → Integration into Practice →
[Monitor for recurrence and related issues]
```

**Where loops commonly break**:

1. **Investigation → Action**: Findings are documented but actions are vague or unassigned.
2. **Action Definition → Implementation**: Actions are assigned but never completed (deprioritized against feature work).
3. **Implementation → Verification**: Actions are claimed complete but effectiveness is not verified.
4. **Knowledge Capture → Integration**: Lessons are written but never read by the people who need them.
5. **Integration → Practice**: People read the lessons but the organizational incentives don't change, so behavior doesn't change.

**NASA's approach to closing loops**:
- Formal tracking systems with regular status reviews at the management level.
- Independent verification of action completion (not self-assessed by the action owner).
- Trend analysis to detect whether types of incidents are actually declining after corrective actions.
- Recurring assessment of organizational factors (schedule pressure, staffing, training) that contribute to incidents.

**Source**: NPR 8621.1B; ISO 9001:2015, Section 10.2 "Nonconformity and corrective action"; Hollnagel, Erik. *Safety-I and Safety-II: The Past and Future of Safety Management*. Ashgate, 2014.

---

## 7. Practical Application to API Platforms

### 7.1 Post-Incident Review for API Platform Failures

Applying NASA's investigation methodology to common API platform failure modes:

**Authentication/Authorization Failures**:

| NASA Concept | API Platform Application |
|-------------|------------------------|
| Mishap classification | Auth failure affecting all users = Type A (equivalent to SEV-1). Auth failure affecting a subset = Type B/C depending on scope. Auth bypass allowing unauthorized access = Type A regardless of exploitation. |
| Proximate cause | "The JWT validation library rejected all tokens after certificate rotation." |
| Root cause | "The certificate rotation runbook did not include a step to update the JWT validation configuration. The runbook was authored for a previous architecture version where validation and certificate management were co-located." |
| Contributing factors | "No integration test validates authentication end-to-end after certificate rotation. The rotation was performed during a period of reduced on-call staffing. Previous rotations happened to work because the old architecture had automatic propagation." |
| Corrective action | "Update the runbook. Add integration test for post-rotation auth validation." |
| Preventive action | "Implement automated runbook validation that checks all runbooks against current architecture. Create a 'change impact analysis' requirement for all architectural modifications that identifies affected operational procedures." |

**Data Leak Incidents**:

For data exposure incidents, the investigation must cover:
- **Barrier analysis**: What barriers should have prevented unauthorized data access? (Authentication, authorization, encryption at rest, encryption in transit, access logging, anomaly detection.) Which barriers failed and why?
- **Change analysis**: What changed that enabled the data exposure? (New endpoint without authorization, misconfigured access control, regression in filtering logic.)
- **Organizational factors**: Was there a design review? Did the review include security assessment? Were there automated security checks in the CI/CD pipeline?

**Configuration-Related Outages**:

Configuration errors are one of the leading causes of production incidents. NASA's investigation approach is particularly valuable here because configuration errors often have the same structure as NASA mishaps: a seemingly small change cascades through a complex system in unexpected ways.

Investigation template for config-related outages:
1. What was the configuration change?
2. What was the intended effect?
3. What was the actual effect?
4. What validation was performed before deployment?
5. What validation could have caught the error?
6. What barriers existed between the change and production impact? (Review, staging, canary, feature flags, rollback capability.)
7. Which barriers worked, which failed, and why?
8. How was the issue detected, and what was the time from deployment to detection?

### 7.2 Building Fault Trees for API Platform Failure Modes

**Example 1: Fault Tree for "Unauthorized Data Access via API"**

```
               [Unauthorized Data Access via API]
                            |
                         [OR Gate]
              /             |              \
[Authentication      [Authorization      [Data leaks
 Bypass]              Failure]            via side channel]
      |                    |                    |
   [OR Gate]           [OR Gate]            [OR Gate]
   /    |    \         /    |    \         /         \
[Token [Auth  [API   [RBAC [Policy [Broken [Verbose   [Timing
 forge] svc    key    mis-  eval   object  error      attack
        down,  leak]  config error] level   messages   reveals
        fails                      authz]  expose     data]
        open]                              data]
```

**Example 2: Fault Tree for "API Platform Cascading Failure"**

```
                [Cascading Failure Across All API Services]
                                |
                             [AND Gate]
                    /                        \
        [Initial service              [Failure propagation
         degradation]                  not contained]
              |                              |
           [OR Gate]                      [AND Gate]
          /    |     \                   /          \
    [Dependency [Resource  [Code      [Circuit     [Rate limiting/
     failure]    exhaustion] defect]   breakers     backpressure
                                       fail]        insufficient]
                                         |              |
                                      [OR Gate]      [OR Gate]
                                     /       \       /       \
                               [Not      [Misconfigured [Not    [Thresholds
                                deployed]  thresholds]   deployed] too high]
```

This fault tree reveals that cascading failure requires an AND condition: both an initial degradation AND a failure of containment mechanisms. This directs investment toward both preventing initial failures and — critically — ensuring containment mechanisms work.

### 7.3 Using FMEA Thinking for API Design Reviews

An API design FMEA evaluates each API function for potential failure modes:

**Example: FMEA for a Rate Limiting Service**

| Function | Failure Mode | Effect (Local) | Effect (System) | Severity | Cause | Current Control | Occurrence | Detection | RPN | Recommended Action |
|----------|-------------|----------------|-----------------|----------|-------|----------------|------------|-----------|-----|-------------------|
| Enforce rate limits | Fails to enforce (fails open) | Unlimited traffic passes | Downstream services overwhelmed, potential outage | 9 | Rate limiter crash, misconfigured rules | Health check, integration tests | 3 | 4 | 108 | Add fail-closed mode with manual override; add real-time rate monitoring |
| Enforce rate limits | Over-enforces (fails closed) | Legitimate traffic blocked | Service effectively unavailable for affected users | 8 | Counter overflow, clock skew, rule misconfiguration | Staging tests, gradual rollout | 4 | 5 | 160 | Add anomaly detection for sudden enforcement spikes; canary analysis for rule changes |
| Return rate limit headers | Incorrect headers | Clients get wrong remaining count | Clients may self-throttle incorrectly or not throttle when they should | 4 | Counter synchronization lag in distributed system | Integration tests | 5 | 6 | 120 | Add consistency checks between enforcement and reported counters |
| Persist rate state | State loss | Counters reset to zero | Brief window of unenforced limits | 6 | Node restart, replication lag | Replication, persistence | 3 | 3 | 54 | Acceptable risk with current controls |

**Key insight**: The FMEA forces systematic consideration of failure modes that are easy to overlook in design reviews. "What if the rate limiter over-enforces?" is not a question that naturally arises when designing rate limiting, but it has a high RPN and has caused real incidents at major platforms.

### 7.4 Tracking Corrective Actions to Completion

Drawing from NASA's CAPA process and automotive 8D methodology, an effective corrective action tracking system for API platforms includes:

**Action Record Structure**:
```
ID: INC-2024-042-CA-03
Source Incident: INC-2024-042 (Authentication service outage)
Root Cause Addressed: Runbook did not account for current architecture
Action Type: Preventive
Description: Implement automated runbook-architecture consistency checker
Owner: [Name, Role]
Due Date: 2024-04-15
Verification Method: Demonstrate that checker identifies intentionally
                     introduced inconsistency in test runbook
Verifier: [Independent person/team]
Status: In Progress
Dependencies: Architecture documentation must be updated first (INC-2024-042-CA-01)
```

**Tracking process**:
1. All actions from post-incident reviews entered within 48 hours of review completion.
2. Weekly status updates required from action owners.
3. Biweekly review by engineering leadership — actions at risk of missing deadline are escalated.
4. Completion requires independent verification (not self-attested by the owner).
5. Monthly trend report: Are incident categories declining? Are similar incidents recurring despite corrective actions?

**Common failure modes in corrective action tracking** (and countermeasures):

| Failure Mode | Countermeasure |
|-------------|---------------|
| Actions defined too vaguely ("improve monitoring") | Require specific, verifiable completion criteria at time of definition |
| Actions deprioritized against feature work | Corrective action completion included in team OKRs/performance metrics |
| Actions completed but ineffective | Post-verification effectiveness review after 90 days |
| Similar incidents recur despite corrective actions | Trend analysis flags repeat categories; triggers escalation to preventive action |
| Action backlog grows unboundedly | Regular triage; classify as must-do, should-do, or accept-risk (with explicit risk acceptance by accountable authority) |

### 7.5 Incident Severity Classification Mapped to Safety Criticality

Drawing the explicit mapping between NASA/automotive safety classification and software incident severity:

| NASA Type | Automotive ASIL | Software Equivalent | Characteristics | Investigation Rigor |
|-----------|----------------|--------------------|-----------------|--------------------|
| Type A | ASIL D | SEV-1 / P0 | Complete service outage affecting all users; data breach; data loss; security compromise with active exploitation | Full post-incident review with MIB-equivalent (cross-team senior participants). External communication. Exec-level corrective action ownership. Timeline: investigation within 72 hours, report within 2 weeks. |
| Type B | ASIL C | SEV-2 / P1 | Major functionality degraded for significant user population; SLA breach; partial data exposure | Structured post-incident review with team leads. Internal communication to stakeholders. Manager-level action ownership. Timeline: investigation within 1 week, report within 3 weeks. |
| Type C | ASIL B | SEV-3 / P2 | Minor functionality affected; performance degradation; non-critical service disruption | Team-level post-incident review. Action items in standard backlog. Timeline: investigation within 2 weeks. |
| Type D | ASIL A / QM | SEV-4 / P3 | Minimal impact; cosmetic issues; single-user impact; quickly self-resolved | Documented review, potentially asynchronous. Lightweight write-up. |
| Close Call | — | Near-miss | Issue detected and mitigated before user impact; "that was close" moments | Analyzed with same root-cause methodology as actual incidents. Often yields the highest-value preventive actions because there is no crisis to distract from analysis. |

**The close-call insight**: NASA and the aviation industry have demonstrated that close-call reporting systems generate more safety improvement per event than actual mishap investigations, because: (a) there are far more close calls than mishaps, providing a larger dataset; (b) close calls can be analyzed without the pressure and emotion of an actual casualty or major loss; and (c) the fact that the system "caught" the issue provides valuable information about which barriers work.

For API platforms, close calls include: deployments that were rolled back before user impact, bugs caught in staging, access control issues found during audit, capacity limits approached but not breached, and configuration errors caught by validation before reaching production.

**Source**: Aviation Safety Reporting System (ASRS), NASA; Heinrich, H.W., *Industrial Accident Prevention*, 1931 (Heinrich's Triangle — the ratio of near-misses to minor incidents to major incidents); Google SRE Book, Chapter 15 (op. cit.); ISO 26262:2018, Part 3.

---

## Summary of Key Sources

### Primary NASA Sources
1. **NPR 8621.1B** — "Mishap and Close Call Reporting, Investigating, and Recordkeeping," NASA Office of Safety and Mission Assurance
2. **NASA Fault Tree Handbook with Aerospace Applications** — Stamatelatos, M. et al., NASA Office of Safety and Mission Assurance, 2002
3. **NASA Systems Engineering Handbook (NASA/SP-2016-6105 Rev2)** — NASA, 2016
4. **NASA-STD-8719.13A** — "NASA Software Safety Standard"
5. **NASA Lessons Learned Information System (LLIS)** — llis.nasa.gov
6. **Columbia Accident Investigation Board Report, Volume 1** — NASA, 2003

### Automotive and Industrial Safety Standards
7. **ISO 26262:2018** — "Road vehicles — Functional safety," Parts 1–12
8. **IEC 61508** — "Functional safety of electrical/electronic/programmable electronic safety-related systems"
9. **IEC 62502:2010** — "Analysis techniques for dependability — Event tree analysis (ETA)"
10. **AIAG & VDA FMEA Handbook** — 1st Edition, 2019
11. **SAE J1739** — FMEA Standards for Design and Process

### Academic and Research Sources
12. **Vaughan, Diane** — *The Challenger Launch Decision: Risky Technology, Culture, and Deviance at NASA*, University of Chicago Press, 1996
13. **Dekker, Sidney** — *Drift into Failure: From Hunting Broken Components to Understanding Complex Systems*, Ashgate, 2011
14. **Dekker, Sidney** — *Just Culture: Balancing Safety and Accountability*, Ashgate, 2007
15. **Hollnagel, Erik** — *Safety-I and Safety-II: The Past and Future of Safety Management*, Ashgate, 2014
16. **Mahler & Casamayou** — *Organizational Learning at NASA: The Challenger and Columbia Accidents*, Georgetown University Press, 2009
17. **Ericson, C.A.** — *Hazard Analysis Techniques for System Safety*, Wiley, 2005

### Software Engineering Sources
18. **Beyer, B. et al.** — *Site Reliability Engineering: How Google Runs Production Systems* (Google SRE Book), O'Reilly, 2016, Chapter 15: "Postmortem Culture: Learning from Failure"
19. **Allspaw, John** — "Blameless PostMortems and a Just Culture," Etsy Code as Craft blog, 2012

### Foundational References
20. **NUREG-0492** — Vesely, W.E. et al., "Fault Tree Handbook," U.S. Nuclear Regulatory Commission, 1981
21. **DOE-NE-STD-1004-92** — "Root Cause Analysis Guidance Document," U.S. Department of Energy
22. **Heinrich, H.W.** — *Industrial Accident Prevention*, McGraw-Hill, 1931 (Heinrich's Triangle)

# Threat Modeling Meets Hazard Analysis — Unifying Security and Safety Thinking for Software Systems

## Reference Material for Internal Engineering Book

---

## 1. NASA's Hazard Analysis Methodology

### Overview and Governing Standards

NASA's approach to hazard analysis for software-intensive systems is defined primarily in:

- **NASA-STD-8719.13C (2013)** — NASA Technical Standard for Software Safety. This is the core standard governing how software hazards are identified, analyzed, classified, and tracked throughout a project lifecycle.
- **NPR 8715.3** — NASA Procedural Requirement for NASA Safety and Mission Assurance, which establishes the institutional safety framework.
- **NASA-HDBK-1002** — Fault Tree Handbook with Aerospace Applications, providing guidance on fault tree analysis for aerospace systems.
- **NASA Software Safety Guidebook (NASA-GB-8719.13)** — Companion guidance document that provides detailed how-to for implementing NASA-STD-8719.13.

The fundamental premise: **software itself cannot be hazardous**, but software can be a *contributor* or *cause* of a system-level hazard. Therefore, software hazard analysis always traces back to system-level hazards and the causal chains through which software behavior can initiate or fail to mitigate those hazards.

### Hazard Severity Classification

NASA uses a four-level hazard severity scheme (per NPR 8715.3 and NASA-STD-8719.13):

| Severity Level | Category | Description |
|---|---|---|
| **1** | Catastrophic | Loss of life, permanently disabling injury, loss of a major system/facility, or significant environmental damage |
| **2** | Critical | Severe injury or occupational illness, major property damage, or significant system damage |
| **3** | Marginal | Minor injury, minor occupational illness, or minor system/property damage |
| **4** | Negligible | Less than minor injury, illness, or property/system damage |

For software specifically, NASA-STD-8719.13 maps software's contribution to these severity levels based on:
- **Software is sole cause** of the hazard (highest concern)
- **Software is a contributing cause** among multiple factors
- **Software is an inhibitor/mitigator** whose failure removes a safety barrier

### Hazard Likelihood Classification

NASA uses a five-level probability/likelihood scheme:

| Level | Description | Qualitative Meaning |
|---|---|---|
| **A** | Frequent | Likely to occur often in the life of the system |
| **B** | Probable | Will occur several times in the life of the system |
| **C** | Occasional | Likely to occur sometime in the life of the system |
| **D** | Remote | Unlikely but possible to occur in the life of the system |
| **E** | Improbable | So unlikely it can be assumed it will not occur |

The combination of severity and likelihood produces a **Risk Assessment Code (RAC)**, typically a matrix from 1 (highest risk) to 20 (lowest risk), used to prioritize hazard mitigation efforts.

### Types of Hazard Analysis

NASA's hazard analysis is performed in a layered, progressive fashion:

#### Preliminary Hazard Analysis (PHA)

- **When**: Early in the project, during concept/requirements phase (Phase A/B in NASA parlance).
- **Purpose**: Identify potential hazards at the system level before detailed design begins. Establish initial hazard severity and likelihood estimates.
- **Inputs**: System concept of operations, preliminary requirements, lessons learned from similar systems.
- **Outputs**: Preliminary Hazard List (PHL), initial hazard reports, safety requirements candidates.
- **Software role**: At PHA stage, identify which system functions will be software-controlled and which of those functions are safety-relevant. Identify potential software contributions to system hazards.
- **Method**: Brainstorming sessions, checklists derived from previous missions, functional analysis of system-level operations, "what-if" analysis of software command/control paths.

**Source**: NASA-GB-8719.13, Section 4.3; NASA-STD-8719.13, Section 4.4.1.

#### Subsystem Hazard Analysis (SSHA)

- **When**: During detailed design (Phase C).
- **Purpose**: Analyze hazards at the subsystem level, focusing on interfaces between subsystems and internal failure modes within each subsystem.
- **Inputs**: Detailed design documents, interface control documents (ICDs), software architecture.
- **Outputs**: Subsystem hazard reports, refined safety requirements, identification of software-specific hazard causes.
- **Software role**: Analyze specific software components, their failure modes (e.g., timing failures, incorrect calculations, wrong state transitions, race conditions), and how those failures propagate to subsystem-level hazards.
- **Method**: FMEA (Failure Modes and Effects Analysis) applied to software modules, interface analysis between software and hardware, analysis of software-controlled valves/actuators/sensors.

**Source**: NASA-GB-8719.13, Section 4.4; MIL-STD-882E, Section A.5 (which NASA references heavily).

#### System Hazard Analysis (SHA)

- **When**: During integration and verification (Phase C/D).
- **Purpose**: Analyze system-level interactions and emergent hazards that arise from the integration of subsystems. Validate that subsystem-level mitigations actually resolve system-level hazards.
- **Inputs**: Integrated system design, test results, SSHA outputs.
- **Outputs**: Updated hazard tracking system, verification of hazard mitigations, residual risk acceptance data.
- **Software role**: Verify that software safety requirements are implemented, tested, and traced to the hazards they mitigate. Analyze system-level scenarios involving software, especially multi-subsystem interactions (e.g., guidance software commanding an engine while telemetry software reports sensor failures).

**Source**: NASA-GB-8719.13, Section 4.5; MIL-STD-882E, Section A.6.

### Hazard Reports and Hazard Tracking

Each identified hazard is documented in a **Hazard Report (HR)** that contains:

1. **Hazard description**: What the hazard is, in system-level terms
2. **Hazard causes**: All identified causal paths, including software causes
3. **Severity and likelihood assessment**: Using the classification schemes above
4. **Risk Assessment Code (RAC)**: Derived from severity x likelihood
5. **Mitigation/controls**: Design changes, safety requirements, operational procedures, warnings
6. **Verification method**: How each mitigation will be verified (test, analysis, inspection, demonstration)
7. **Status**: Open, mitigated, accepted, closed
8. **Residual risk**: Risk remaining after all mitigations are applied

Hazard reports are maintained in a **Hazard Tracking System (HTS)** throughout the project lifecycle. NASA requires that:
- Hazards are tracked from identification through closure or risk acceptance
- All changes to hazard status are reviewed by the Safety Review Board
- Software changes that affect safety-critical functions trigger re-analysis of associated hazards
- Hazard reports are living documents updated as design evolves

**Source**: NASA-STD-8719.13, Section 4.3; NPR 8715.3, Chapter 3.

### Relationship Between Hazard Analysis and Software Requirements

This is one of NASA's most important contributions to software engineering practice. The linkage works as follows:

1. **System hazard analysis** identifies hazards and their causal chains
2. **Software hazard analysis** identifies which causal chains involve software
3. For each software-related causal chain, **software safety requirements** are derived that, if satisfied, break the causal chain
4. These requirements are tagged as **safety-critical** and receive enhanced verification (code inspection, formal analysis, testing to safety standards)
5. **Bidirectional traceability** is maintained: every safety-critical software requirement traces to a hazard, and every hazard traces to the requirements that mitigate it

This traceability is enforced in NASA's Independent Verification and Validation (IV&V) process per NASA-STD-8739.8.

---

## 2. Automotive HARA (Hazard Analysis and Risk Assessment)

### ISO 26262 Part 3: Concept Phase

ISO 26262:2018, "Road vehicles — Functional safety," defines HARA in Part 3 (Concept phase) as the method for determining safety goals and their Automotive Safety Integrity Levels (ASILs). HARA is performed at the vehicle level during the concept phase, before any architectural decisions are made.

**Source**: ISO 26262:2018, Part 3, Clauses 7-8.

### The HARA Process

HARA proceeds through these steps:

#### Step 1: Situation Analysis and Hazard Identification

- Identify the **item** (the system or combination of systems to which the safety lifecycle is applied)
- Define the item's **functional behavior** and its interactions with other items and the environment
- Identify **operational situations** (driving scenarios): highway driving, urban driving, parking, etc.
- For each combination of item malfunction and operational situation, identify potential **hazardous events** (e.g., "unintended acceleration while driving on a highway")
- Methods: brainstorming, FMEA, HAZOP applied at the functional level

#### Step 2: Classification of Hazardous Events

Each hazardous event is rated on three independent parameters:

**Severity (S)**

| Class | Description | Example |
|---|---|---|
| S0 | No injuries | — |
| S1 | Light and moderate injuries | Minor bruising |
| S2 | Severe and life-threatening injuries (survival probable) | Broken limbs, concussion |
| S3 | Life-threatening injuries (survival uncertain), fatal injuries | Death, severe brain injury |

**Exposure (E)** — How often the operational situation occurs

| Class | Description |
|---|---|
| E0 | Incredible |
| E1 | Very low probability |
| E2 | Low probability |
| E3 | Medium probability |
| E4 | High probability |

> **Note**: ISO 26262 defines E and C classes qualitatively. Percentage approximations sometimes seen in industry (e.g., E1 = "<1%", E4 = ">50%") are informal heuristics, not normative ISO 26262 content.

**Controllability (C)** — Can the driver or other road users avoid the harm?

| Class | Description |
|---|---|
| C0 | Controllable in general |
| C1 | Simply controllable |
| C2 | Normally controllable |
| C3 | Difficult to control or uncontrollable |

#### Step 3: ASIL Determination

The ASIL is determined by combining S, E, and C ratings:

| | C1 | C2 | C3 |
|---|---|---|---|
| **S1, E1** | QM | QM | QM |
| **S1, E2** | QM | QM | QM |
| **S1, E3** | QM | QM | ASIL A |
| **S1, E4** | QM | ASIL A | ASIL B |
| **S2, E1** | QM | QM | QM |
| **S2, E2** | QM | QM | ASIL A |
| **S2, E3** | QM | ASIL A | ASIL B |
| **S2, E4** | ASIL A | ASIL B | ASIL C |
| **S3, E1** | QM | QM | ASIL A |
| **S3, E2** | QM | ASIL A | ASIL B |
| **S3, E3** | ASIL A | ASIL B | ASIL C |
| **S3, E4** | ASIL B | ASIL C | ASIL D |

- **QM** = Quality Management (no specific safety requirements beyond standard quality practices)
- **ASIL A** through **ASIL D** = Increasing levels of safety rigor (D is the most stringent)

#### Step 4: Safety Goals

For each hazardous event with ASIL A-D, a **safety goal** is formulated. Safety goals are top-level safety requirements expressed in terms of preventing or mitigating the hazardous event. Each safety goal inherits the ASIL of its hazardous event.

**Example**: "The electronic throttle control system shall not cause unintended acceleration" — ASIL D.

### How HARA Drives the Safety Lifecycle

HARA outputs cascade through the entire ISO 26262 lifecycle:

1. **Safety goals** (from HARA) become the top-level requirements (Part 3)
2. **Functional safety requirements** are derived from safety goals (Part 3)
3. **Technical safety requirements** refine functional requirements into HW/SW allocations (Part 4)
4. **Hardware safety requirements** drive HW design and verification (Part 5)
5. **Software safety requirements** drive SW design, coding standards, and verification rigor (Part 6)
6. The ASIL level determined by HARA dictates the **rigor of methods** used at every stage (e.g., ASIL D requires MC/DC test coverage for software, while ASIL A requires only statement coverage)

This cascading model is one of the most disciplined requirement-derivation frameworks in engineering.

**Source**: ISO 26262:2018, Parts 3-6; Automotive SPICE and ISO 26262 alignment guide.

---

## 3. SOTIF Hazard Analysis (ISO 21448)

### The Problem SOTIF Addresses

ISO 26262 addresses hazards caused by **component faults** — when hardware breaks or software has bugs. But modern vehicles (especially those with ADAS and autonomous driving features) face a different category of hazard: systems behaving exactly as designed but still creating unsafe conditions because of **functional insufficiencies** or **triggering conditions** in the operating environment.

Examples:
- A camera-based lane-keeping system that works correctly but fails in heavy rain because the algorithm cannot distinguish lane markings in reduced visibility
- An automatic emergency braking system that correctly detects an object but misclassifies a bridge shadow as an obstacle, causing unnecessary hard braking
- A pedestrian detection system that works as designed but was never trained on wheelchair users

These are not faults — the system is doing exactly what it was designed to do. The hazard arises from the **limitation of the intended functionality** in specific conditions.

**Source**: ISO 21448:2022, Clause 1 (Scope) and Clause 4 (Overview).

### Key Concepts

#### Triggering Conditions

A triggering condition is a specific condition or set of conditions of the environment, the system, or the driver that can lead to a hazardous event when the system is performing its intended functionality. Examples:
- Environmental: fog, direct sunlight, rain, snow, unusual road geometry
- System: sensor degradation over time, algorithm limitations with specific input patterns
- Human: unexpected driver behavior, distraction, over-reliance on the system

#### Foreseeable Misuse

Situations where the user operates the system outside its operational design domain (ODD) in ways that could reasonably be anticipated. Example: a driver removing hands from the steering wheel during Level 2 automation because the system "seems to be handling it."

#### The Four-Quadrant Model

SOTIF organizes scenarios into four areas:

| | Known | Unknown |
|---|---|---|
| **Safe** | Area 1: Known safe scenarios (normal operation) | Area 3: Unknown safe scenarios (not yet identified but safe) |
| **Unsafe** | Area 2: Known unsafe scenarios (identified triggering conditions) | Area 4: Unknown unsafe scenarios (unidentified triggering conditions) |

The goal of SOTIF analysis is to:
1. Identify scenarios in **Area 4** (unknown unsafe) and move them to **Area 2** (known unsafe)
2. For scenarios in **Area 2**, implement mitigations to move them to **Area 1** (known safe)
3. Provide evidence that the residual risk from **Area 4** is acceptably low

#### The SOTIF Analysis Loop

The SOTIF analysis process is iterative:

1. **Specification and design analysis**: Review the intended functionality, identify known limitations of sensors, algorithms, and actuators
2. **Identification of hazardous events**: Similar to HARA but focused on functional insufficiencies rather than component faults
3. **Identification of triggering conditions**: Systematic analysis of what environmental/system/human conditions can expose functional limitations
4. **Evaluation of known unsafe scenarios**: For each triggering condition + hazardous event pair, assess severity and acceptability
5. **Functional modification or mitigation**: Modify the algorithm, add sensors, restrict the ODD, improve driver monitoring
6. **Verification and validation**: Test against known triggering conditions, use simulation/field testing to reduce Area 4
7. **Residual risk evaluation**: Statistical argument that remaining risk is acceptable

This loop continues until the residual risk is argued to be acceptably low.

**Source**: ISO 21448:2022, Clauses 5-10.

### Relevance to Software Systems

The SOTIF concept maps directly to software systems that rely on heuristics, machine learning, or environmental inputs:
- An API rate limiter that works correctly but whose algorithm doesn't account for bursty traffic patterns from legitimate users
- A fraud detection system that works as designed but produces false positives for users from specific geographic regions
- An auto-scaling system that responds correctly to metrics but cannot distinguish between a DDoS attack and a viral marketing success

These are not bugs — the system is working as designed. The hazard is a **functional insufficiency** in the design itself.

---

## 4. Software Threat Modeling

### STRIDE

STRIDE was developed by Loren Kohnfelder and Praerit Garg at Microsoft in 1999 and has become the most widely used threat classification model in software security.

**Source**: Kohnfelder, L. and Garg, P., "The Threats to Our Products," Microsoft internal document, 1999; Shostack, A., *Threat Modeling: Designing for Security*, Wiley, 2014.

Each letter represents a category of threat:

#### S — Spoofing

- **Definition**: Pretending to be something or someone you are not.
- **Violates**: Authentication
- **Examples**: Impersonating another user, forging authentication tokens, DNS spoofing, ARP spoofing, IP spoofing.
- **API platform example**: An attacker crafts a JWT token with a forged issuer claim to impersonate a different tenant in a multi-tenant API gateway.

#### T — Tampering

- **Definition**: Modifying data or code without authorization.
- **Violates**: Integrity
- **Examples**: Modifying data in transit (MITM), altering database records, changing configuration files, modifying binaries.
- **API platform example**: An attacker intercepts and modifies API request bodies between the client and the gateway to inject additional parameters that bypass input validation.

#### R — Repudiation

- **Definition**: Claiming that you did not perform an action when you actually did (or vice versa).
- **Violates**: Non-repudiation
- **Examples**: Deleting or tampering with audit logs, performing actions without adequate logging, denying a transaction.
- **API platform example**: A malicious API consumer denies having made specific API calls; insufficient logging at the gateway makes it impossible to prove otherwise.

#### I — Information Disclosure

- **Definition**: Exposing information to unauthorized individuals.
- **Violates**: Confidentiality
- **Examples**: Reading data in transit, accessing files without authorization, verbose error messages revealing internal details, side-channel attacks.
- **API platform example**: Error responses from the API gateway include stack traces revealing internal service topology, database schemas, or other tenant information.

#### D — Denial of Service

- **Definition**: Making a system unavailable or degrading its performance.
- **Violates**: Availability
- **Examples**: Resource exhaustion, flooding, algorithmic complexity attacks, deadlocking.
- **API platform example**: An attacker sends requests with deeply nested JSON payloads that consume excessive CPU during parsing, degrading service for all tenants on a shared gateway.

#### E — Elevation of Privilege

- **Definition**: Gaining capabilities beyond what you are authorized to have.
- **Violates**: Authorization
- **Examples**: Buffer overflow exploits, SQL injection, privilege escalation through misconfigured roles, IDOR (Insecure Direct Object Reference).
- **API platform example**: A user with read-only API access exploits an IDOR vulnerability to access the admin API endpoint and modify rate-limiting policies for their tenant.

### Microsoft's Threat Modeling Methodology

Microsoft formalized threat modeling into a four-step process (documented in the SDL — Security Development Lifecycle):

1. **Diagram**: Create a data flow diagram (DFD) of the system showing processes, data stores, data flows, external entities, and trust boundaries
2. **Identify threats**: Apply STRIDE systematically to each element in the DFD. Each DFD element type maps to specific STRIDE categories:
   - External entities: Spoofing, Repudiation
   - Processes: Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege (all six)
   - Data flows: Tampering, Information Disclosure, Denial of Service
   - Data stores: Tampering, Information Disclosure, Denial of Service, Repudiation
3. **Mitigate**: For each identified threat, select a mitigation strategy (eliminate, mitigate, transfer, accept)
4. **Validate**: Verify that mitigations are implemented and effective

**Source**: Microsoft, "Microsoft Threat Modeling Tool" documentation; Howard, M. and Lipner, S., *The Security Development Lifecycle*, Microsoft Press, 2006.

### Attack Trees

Attack trees were formalized by Bruce Schneier in 1999 (building on earlier "threat trees" work by the NSA and DoD). They represent attacks against a system as a tree structure:

- **Root node**: The attacker's goal (e.g., "Steal customer data from API platform")
- **Leaf nodes**: Atomic attack steps (e.g., "Exploit SQL injection in search API")
- **Intermediate nodes**: Sub-goals that combine to achieve the parent goal
- **AND nodes**: All children must succeed for the parent to succeed
- **OR nodes**: Any child succeeding achieves the parent goal

Attack trees can be annotated with:
- **Cost to attacker**: How expensive is this attack path?
- **Technical difficulty**: What skill level is required?
- **Detectability**: How likely is detection before success?
- **Probability of success**: Estimated likelihood

**Example for API platform**:
```
Goal: Unauthorized access to tenant data [OR]
├── Exploit authentication bypass [OR]
│   ├── Forge JWT token (requires signing key) [AND]
│   │   ├── Extract key from configuration store
│   │   └── Craft token with target tenant claims
│   ├── Exploit OAuth misconfiguration
│   └── Session fixation attack
├── Exploit authorization flaw [OR]
│   ├── IDOR on tenant-scoped endpoints
│   ├── Parameter pollution to bypass tenant isolation
│   └── Privilege escalation through role manipulation
└── Exploit data leakage [OR]
    ├── Error messages revealing other tenant data
    ├── Cache poisoning returning cached responses from other tenants
    └── Timing side-channel revealing existence of other tenants' resources
```

**Source**: Schneier, B., "Attack Trees," Dr. Dobb's Journal, December 1999; Mauw, S. and Oostdijk, M., "Foundations of Attack Trees," ICISC 2005, LNCS 3935.

### LINDDUN for Privacy Threats

LINDDUN is a privacy threat modeling framework developed by researchers at KU Leuven (Deng, M. et al., 2011). It mirrors STRIDE but focuses on privacy:

| Category | Full Name | Privacy Property Violated |
|---|---|---|
| **L** | Linkability | Unlinkability |
| **I** | Identifiability | Anonymity / Pseudonymity |
| **N** | Non-repudiation (unwanted) | Plausible deniability |
| **D** | Detectability | Undetectability / Unobservability |
| **D** | Disclosure of information | Confidentiality |
| **U** | Unawareness | Content awareness |
| **N** | Non-compliance | Policy and consent compliance |

Applied to DFDs similarly to STRIDE, LINDDUN systematically identifies privacy threats at each element.

**API platform example**: A multi-tenant API analytics dashboard might allow **linkability** — correlating API usage patterns across different contexts to identify individual users even when data is pseudonymized.

**Source**: Wuyts, K., Scandariato, R., and Joosen, W., "LINDDUN privacy threat analysis methodology," KU Leuven, Technical Report CW 624, 2011; Deng, M. et al., "A Privacy Threat Analysis Framework," Requirements Engineering, 2011.

### Data Flow Diagrams for Threat Identification

DFDs are the foundational artifact for threat modeling. For software systems, they capture:

- **External entities**: Users, external systems, anything outside the system boundary
- **Processes**: Software components that transform data
- **Data stores**: Databases, file systems, caches, message queues
- **Data flows**: Communication paths between elements (API calls, messages, file reads/writes)
- **Trust boundaries**: Lines demarcating different trust levels (e.g., public internet vs. internal network, tenant A vs. tenant B)

**Key principle**: Threats concentrate at **trust boundary crossings**. Every data flow that crosses a trust boundary is a candidate for threat analysis.

For an API platform, typical trust boundaries include:
- Internet to API gateway (external trust boundary)
- Gateway to backend services (service mesh boundary)
- Between tenants in a multi-tenant system (tenant isolation boundary)
- Between control plane and data plane (management boundary)
- Between the platform and third-party plugins/extensions (extension boundary)

---

## 5. Unifying Safety and Security Analysis

### Where Hazard Analysis and Threat Modeling Overlap

| Dimension | Hazard Analysis | Threat Modeling |
|---|---|---|
| **Primary concern** | Accidental harm (safety) | Intentional harm (security) |
| **Threat agent** | Environment, physics, human error, component failure | Adversary with intent and capability |
| **Root cause model** | Faults, errors, failures (causal chain) | Attacker goals, attack paths (adversarial thinking) |
| **Risk model** | Severity x Likelihood | Impact x Likelihood x Attacker Capability |
| **Output** | Safety requirements, hazard mitigations | Security requirements, countermeasures |
| **Lifecycle** | Continuous from concept through operations | Often concentrated in design phase |
| **Regulatory drivers** | DO-178C (aerospace), ISO 26262 (automotive), IEC 61508 (industrial) | Common Criteria, PCI DSS, SOC 2 |

**Critical overlaps**:
1. Both start with **identifying what can go wrong** at the system level
2. Both use **structured decomposition** (fault trees / attack trees)
3. Both produce **requirements** that must be verified
4. Both require **traceability** from risk to mitigation to verification
5. Both must be **updated** when the system changes

### The Concept of Safety-Security Co-Analysis

The insight driving co-analysis is that safety and security can **conflict** or **compound**:

**Conflicts**:
- Safety may require a system to fail to a **safe state** (e.g., shut down) — but an attacker could exploit this to cause denial of service
- Safety may require **transparency** (operators must understand system state) — but this can create information disclosure
- Security may require **authentication** before action — but safety may require immediate emergency response without authentication delays

**Compounding**:
- A security breach can cause a safety incident (e.g., attacker tampers with sensor data, causing the control system to make a dangerous decision)
- A safety failure can create a security vulnerability (e.g., a system in degraded mode bypasses authentication to maintain availability)

**Source**: Schmittner, C., Gruber, T., Puschner, P., and Schoitsch, E., "Security Application of Failure Mode and Effect Analysis (FMEA)," SAFECOMP 2014; Young, W. and Leveson, N., "An Integrated Approach to Safety and Security Based on Systems Theory," Communications of the ACM, 2014.

### Automotive: Merging ISO 26262 with ISO/SAE 21434

ISO/SAE 21434:2021, "Road vehicles — Cybersecurity engineering," was developed specifically to be a cybersecurity companion to ISO 26262. Key integration points:

#### Parallel Lifecycle Models

| ISO 26262 Phase | ISO/SAE 21434 Phase |
|---|---|
| Item definition | Item definition (shared) |
| HARA (hazard analysis) | TARA (Threat Analysis and Risk Assessment) |
| Functional safety concept | Cybersecurity concept |
| Technical safety requirements | Cybersecurity requirements |
| HW/SW safety requirements | HW/SW cybersecurity requirements |
| Safety validation | Cybersecurity validation |
| Production, operation, decommissioning | Post-production cybersecurity management |

#### TARA (Threat Analysis and Risk Assessment)

ISO/SAE 21434's TARA is the security analog of HARA:

1. **Asset identification**: Identify assets that need protection (data, functions, firmware)
2. **Threat scenario identification**: Identify threat scenarios using methods like STRIDE, attack trees
3. **Impact rating**: Rate the impact of successful attacks on safety, financial, operational, and privacy dimensions
4. **Attack path analysis**: Identify feasible attack paths and rate their **attack feasibility** based on:
   - Elapsed time required
   - Specialist expertise needed
   - Knowledge of the target required
   - Window of opportunity
   - Equipment required
5. **Risk determination**: Combine impact and attack feasibility to determine risk level
6. **Risk treatment**: Reduce, retain, transfer, or avoid

**Source**: ISO/SAE 21434:2021, Clause 15 (Threat analysis and risk assessment methods).

#### Joint Analysis Requirements

The 2021 editions of both standards explicitly require consideration of the other domain:
- ISO 26262 requires considering cybersecurity threats as potential causes of safety hazards
- ISO/SAE 21434 requires considering safety impacts of cybersecurity threats
- Joint analysis is recommended during item definition and concept phases

Industry practice (e.g., from UNECE WP.29 Regulation No. 155 on cybersecurity) now requires OEMs to maintain both a **Safety Management System** and a **Cybersecurity Management System** with explicit interfaces between them.

### NASA's Approach to Cybersecurity: NPR 7150.2D

NASA's Software Engineering Requirements (NPR 7150.2D, effective 2019) integrates cybersecurity into the software lifecycle:

- **Clause 3.5**: Requires that software safety analysis consider cybersecurity threats as potential causes of safety hazards
- **Clause 4.5**: Requires identification of software security requirements alongside functional and safety requirements
- **SWE-029 through SWE-034**: Specific requirements for security-relevant software including secure coding practices, static analysis for security vulnerabilities, and security testing

NASA also references NIST SP 800-53 for security controls and integrates these with mission assurance requirements through NPR 8705.4.

Key NASA principle: **Cybersecurity threats can create safety hazards**. A compromised flight software system is not just a data breach — it can cause loss of mission or loss of crew. Therefore, security analysis is a **prerequisite input** to safety analysis.

**Source**: NPR 7150.2D, Chapter 3 and Appendix D; NASA/SP-2010-580, NASA Software Safety Guidebook.

### Common Cause Analysis Across Safety and Security

Common Cause Analysis (CCA), traditionally used in safety engineering (per ARP 4761 in aerospace), examines whether supposedly independent safety barriers share common failure causes. This concept extends naturally to safety-security co-analysis:

**Methodology**:
1. **Particular Risk Analysis**: Identify external events (including cyber attacks) that could simultaneously defeat multiple safety barriers
2. **Common Mode Analysis**: Identify design features shared between safety and security mechanisms that could fail from a single cause (e.g., both the safety monitor and the security module rely on the same OS kernel)
3. **Zonal Analysis**: Physical or logical colocation of safety and security mechanisms that could be affected by a single event

**Example for API platforms**: If your rate-limiting mechanism (safety/availability) and your authentication mechanism (security) both depend on the same Redis cluster, a single Redis failure or compromise defeats both safety and security simultaneously.

**Source**: SAE ARP 4761, "Guidelines and Methods for Conducting the Safety Assessment Process on Civil Airborne Systems and Equipment"; Lisova, E. et al., "Safety and Security Co-analysis: A Systematic Literature Review," IEEE Systems Journal, 2019.

### Systems-Theoretic Process Analysis (STPA)

Nancy Leveson's Systems-Theoretic Process Analysis (STPA), introduced in her 2011 book *Engineering a Safer World* (MIT Press), provides an alternative to traditional FTA and FMEA that is particularly suited to software-intensive systems. Rather than analyzing component failures, STPA models the system as a hierarchical control structure and analyzes **unsafe control actions** — actions (or inactions) by controllers that can lead to hazards in a particular context.

STPA proceeds in two main steps:
1. **Identify unsafe control actions**: For each controller and control action in the control structure, determine how the action could be unsafe — provided when not needed, not provided when needed, provided too early/too late, or applied too long/stopped too soon.
2. **Identify causal scenarios**: Determine why each unsafe control action might occur, considering flawed controller logic, inadequate feedback, incorrect process models, communication failures, and environmental disturbances.

STPA-Sec extends this framework to security analysis, treating an attacker as another source of unsafe control actions or as a cause of existing ones. This makes STPA well suited for combined safety-security analysis of complex systems, where emergent behavior from component interactions — rather than individual component failures — is the primary concern.

**Source**: Leveson, N., *Engineering a Safer World: Systems Thinking Applied to Safety*, MIT Press, 2011; Young, W. and Leveson, N., "An Integrated Approach to Safety and Security Based on Systems Theory," Communications of the ACM, 2014.

---

## 6. Fault Trees for Software

### Fault Tree Analysis (FTA) Fundamentals

FTA was invented at Bell Telephone Laboratories in 1961 by H.A. Watson for the Minuteman missile program, and was subsequently adopted and advanced by Boeing and NASA.

A fault tree is a **top-down, deductive analysis** that starts with an undesired system event (the "top event") and works backward through all possible combinations of lower-level events that could cause it.

**Source**: Vesely, W.E. et al., "Fault Tree Handbook," NUREG-0492, U.S. Nuclear Regulatory Commission, 1981; NASA Fault Tree Handbook with Aerospace Applications (NASA-HDBK-1002, 2002).

### Fault Tree Structure

#### Top Event
The system-level failure or hazard being analyzed. Must be precisely defined.
- Example: "Unauthorized user gains access to tenant data"

#### Gates

- **AND gate**: Output occurs only when ALL inputs occur simultaneously
- **OR gate**: Output occurs when ANY input occurs
- **Inhibit gate**: Output occurs when input occurs AND an enabling condition is true (essentially a conditional AND)
- **Priority AND gate**: Output occurs when all inputs occur in a specific sequence (important for software timing issues)
- **Voting gate (k-of-n)**: Output occurs when k out of n inputs occur (used for redundant systems)

#### Events

- **Basic event**: A fundamental fault that requires no further decomposition (a leaf node). Has an assigned probability or is left qualitative.
- **Intermediate event**: A fault that is further decomposed through gates into lower-level events.
- **Undeveloped event**: A fault that is not further decomposed (usually due to insufficient information or because it's outside scope), shown as a diamond.
- **Conditioning event**: A condition that restricts or enables a gate (used with Inhibit gates).
- **External/House event**: An event that is expected to occur (or not occur) by design — used to model different system configurations.

### Applying FTA to Software Systems

Software FTA requires adapting traditional hardware-oriented thinking:

**Software failure modes to consider**:
- Incorrect output/computation
- Output delivered too late (timing fault)
- Output delivered too early
- Output not delivered at all (omission)
- Output delivered when not expected (commission)
- Incorrect sequencing of outputs
- Stuck-at fault (same output regardless of input)

**Software-specific basic events**:
- Logic errors in code
- Race conditions / concurrency bugs
- Buffer overflows / memory corruption
- Configuration errors
- State machine violations
- Integer overflow / underflow
- Null pointer dereference in critical path
- Incorrect error handling (swallowed exceptions)

### Example: FTA for API Platform Tenant Data Breach

```
TOP EVENT: Unauthorized access to tenant data [OR]
│
├── Authentication failure [OR]
│   ├── Token validation bypass [OR]
│   │   ├── JWT signature not verified (code defect) [Basic]
│   │   ├── Algorithm confusion attack (alg:none) [Basic]
│   │   └── Signing key compromised [AND]
│   │       ├── Key stored in plaintext config [Basic]
│   │       └── Config store accessed by attacker [OR]
│   │           ├── Config API exposed without auth [Basic]
│   │           └── Insider access to config store [Basic]
│   ├── Session management failure [OR]
│   │   ├── Session token predictable [Basic]
│   │   ├── Session not invalidated after password change [Basic]
│   │   └── Session fixation vulnerability [Basic]
│   └── Credential compromise [OR]
│       ├── Brute force (no rate limiting) [Basic]
│       ├── Credential stuffing [Basic]
│       └── API key leaked in client-side code [Basic]
│
├── Authorization failure [OR]
│   ├── Tenant isolation bypass [OR]
│   │   ├── Missing tenant context check in query layer [Basic]
│   │   ├── SQL injection bypasses tenant WHERE clause [Basic]
│   │   ├── IDOR on tenant-scoped resource identifiers [Basic]
│   │   └── Shared cache returns other tenant's data [AND]
│   │       ├── Cache key does not include tenant ID [Basic]
│   │       └── Cache hit for wrong tenant's request [Basic]
│   ├── Role/permission bypass [OR]
│   │   ├── Privilege escalation through API parameter [Basic]
│   │   ├── Missing authorization check on admin endpoint [Basic]
│   │   └── Role assignment race condition [Basic]
│   └── Policy evaluation failure [OR]
│       ├── Policy engine returns "allow" on error [Basic]
│       ├── Policy not loaded (default-allow) [Basic]
│       └── Policy logic error (overly permissive rule) [Basic]
│
└── Data leakage without access control failure [OR]
    ├── Verbose error messages exposing tenant data [Basic]
    ├── Logging system captures and exposes sensitive data [Basic]
    ├── Backup/export includes cross-tenant data [Basic]
    └── Debug endpoint left active in production [Basic]
```

### Quantitative vs. Qualitative FTA

**Qualitative FTA**:
- Identifies **minimal cut sets** (MCS) — the smallest combinations of basic events that can cause the top event
- Each MCS represents an independent failure scenario
- Single-point-of-failure analysis: Any MCS with only one basic event is a single point of failure
- Used to identify where **design improvements** are most needed
- More common for software because failure probabilities are hard to assign

**Quantitative FTA**:
- Assigns probabilities to basic events
- Calculates top event probability using Boolean algebra:
  - OR gate: P(A ∪ B) = P(A) + P(B) - P(A)P(B) ≈ P(A) + P(B) for small probabilities
  - AND gate: P(A ∩ B) = P(A) × P(B) (assuming independence)
- **Challenge for software**: Unlike hardware components with known failure rates (MTBF data), software failure probabilities are generally not well characterized. Approaches include:
  - Using defect density metrics as proxies
  - Using operational failure data from similar systems
  - Expert estimation with uncertainty ranges
  - Bayesian approaches combining prior knowledge with testing evidence

**Importance measures** from quantitative FTA:
- **Fussell-Vesely importance**: Fraction of the top event probability attributable to cut sets containing a specific basic event
- **Birnbaum importance**: Sensitivity of the top event probability to changes in a basic event's probability
- **Risk Achievement Worth (RAW)**: How much the top event probability increases if a basic event certainly occurs
- **Risk Reduction Worth (RRW)**: How much the top event probability decreases if a basic event certainly does not occur

These measures help prioritize security investments: focus on basic events with the highest importance measures.

**Source**: Vesely, W.E. et al., "Fault Tree Handbook," NUREG-0492, 1981; Rausand, M. and Hoyland, A., *System Reliability Theory*, Wiley, 2004, Chapter 3.

---

## 7. Practical Application to API Platforms

### Threat Modeling an API Gateway End-to-End

#### Step 1: Build the Data Flow Diagram

Key components for an API gateway DFD:

**External Entities**:
- API consumers (mobile apps, web apps, third-party integrators)
- Identity provider (OAuth/OIDC server)
- API developers/publishers
- Platform administrators

**Processes**:
- API gateway (request routing, protocol translation)
- Authentication/authorization engine
- Rate limiter
- Request/response transformation engine
- Analytics/logging pipeline
- Developer portal
- Admin console / control plane API

**Data Stores**:
- API configuration store (routes, policies, transformations)
- API key / credential store
- Rate limit counters (often Redis or similar)
- Analytics data store
- Audit log store

**Trust Boundaries**:
- TB1: Internet ↔ API Gateway (external boundary)
- TB2: API Gateway ↔ Backend services (service boundary)
- TB3: Tenant A ↔ Tenant B (multi-tenant isolation boundary)
- TB4: Data plane ↔ Control plane (management boundary)
- TB5: Platform ↔ Third-party plugins/extensions (extension boundary)

#### Step 2: Apply STRIDE at Each Trust Boundary

**TB1 — Internet to Gateway**:

| Threat | STRIDE | Example Scenario |
|---|---|---|
| Spoofed client identity | S | Forged API key or JWT from another tenant |
| Request body tampering | T | MITM modifying request parameters (if TLS misconfigured) |
| Non-attributable requests | R | Requests without sufficient logging for forensic analysis |
| API schema disclosure | I | Exposing OpenAPI specs that reveal internal implementation details |
| Volumetric DDoS | D | Flooding the gateway with requests exceeding capacity |
| Admin API access from internet | E | Misconfigured routing exposing admin endpoints publicly |

**TB3 — Tenant Isolation**:

| Threat | STRIDE | Example Scenario |
|---|---|---|
| Tenant impersonation | S | Manipulating tenant context header to access another tenant's APIs |
| Cross-tenant data modification | T | Exploiting shared database without proper tenant scoping |
| Undeniable cross-tenant access | R | Insufficient per-tenant audit logging |
| Cross-tenant data leakage | I | Shared cache returning another tenant's API responses |
| Noisy neighbor | D | One tenant consuming all shared resources, degrading others |
| Tenant admin escalation | E | Tenant admin gaining platform admin privileges |

#### Step 3: Mitigate and Prioritize

Each identified threat gets a mitigation, and mitigations are prioritized by risk (combining impact and likelihood, informed by the HARA/TARA approach).

### Hazard Analysis for Multi-Tenant Isolation

Applying NASA's hazard analysis methodology to multi-tenant isolation:

#### Preliminary Hazard List

| Hazard ID | Hazard | Severity | Likelihood | RAC |
|---|---|---|---|---|
| H-MT-001 | Tenant A can read Tenant B's data | Critical (2) | Occasional (C) | 5 |
| H-MT-002 | Tenant A can modify Tenant B's configuration | Critical (2) | Remote (D) | 9 |
| H-MT-003 | Single tenant can exhaust shared resources | Marginal (3) | Probable (B) | 8 |
| H-MT-004 | Tenant credential leak enables cross-tenant access | Critical (2) | Occasional (C) | 5 |
| H-MT-005 | Admin operation on wrong tenant scope | Critical (2) | Probable (B) | 4 |
| H-MT-006 | Tenant deletion cascades to other tenants | Catastrophic (1) | Remote (D) | 4 |

> **Note**: RAC values shown are illustrative; derive from your organization's risk matrix (typically a severity-by-likelihood lookup table producing values from 1 to 20).

#### Deriving Safety Requirements from Hazards (NASA-Style)

From **H-MT-001** (cross-tenant data read):

- **SR-001**: All database queries for tenant-scoped data SHALL include tenant identifier in the query predicate. *[Prevents direct cross-tenant query]*
- **SR-002**: The data access layer SHALL validate that the tenant identifier in the query matches the authenticated tenant context. *[Defense-in-depth verification]*
- **SR-003**: API response payloads SHALL be validated against the requesting tenant's context before transmission. *[Output validation]*
- **SR-004**: Cache keys for tenant-scoped data SHALL include the tenant identifier. *[Prevents cache-based leakage]*
- **SR-005**: Integration tests SHALL include cross-tenant access attempt scenarios that verify denial. *[Verification requirement]*

Each of these traces back to H-MT-001 with bidirectional traceability, exactly as NASA-STD-8719.13 requires.

### STRIDE Applied to API Authentication Flows

Consider the OAuth 2.0 Authorization Code flow as used by an API platform:

```
[User Agent] → [API Platform Auth Server] → [Authorization Code] → [Token Exchange] → [Access Token] → [API Gateway]
```

| Flow Step | S | T | R | I | D | E |
|---|---|---|---|---|---|---|
| Auth request to auth server | CSRF to initiate auth as victim | Redirect URI manipulation | — | Scope values disclosed in URL | Auth server flooding | — |
| Consent and authorization | Session fixation | Consent parameter tampering | User denies granting but logs show grant | — | — | Consent bypass via scope manipulation |
| Authorization code return | Code interception (if not using PKCE) | Code substitution | — | Code leaked in referrer header | — | — |
| Token exchange | Client impersonation | Code_verifier bypass | — | Token response interception | — | — |
| Access token use at gateway | Token theft/replay | Token content manipulation (if not signed) | API calls without audit trail | Token metadata disclosure | Token validation resource exhaustion | Token scope escalation |
| Token refresh | Refresh token theft | — | — | — | Refresh loop exhaustion | Scope escalation on refresh |

**Key mitigations identified**:
- PKCE (Proof Key for Code Exchange) — mitigates code interception
- Strict redirect URI validation — mitigates redirect manipulation
- Short-lived access tokens with refresh rotation — limits token theft impact
- Token binding — prevents token replay
- Per-request audit logging — addresses repudiation

### Attack Trees for Policy Bypass Scenarios

```
Goal: Bypass API rate limiting policy [OR]
│
├── Evade rate limit counter [OR]
│   ├── Distribute requests across multiple API keys [Basic]
│   ├── Rotate source IPs (if IP-based limiting) [Basic]
│   ├── Exploit race condition in counter increment [Basic]
│   └── Reset counter via cache eviction attack [AND]
│       ├── Determine cache key pattern [Basic]
│       └── Send crafted requests to evict target keys [Basic]
│
├── Exploit rate limit configuration [OR]
│   ├── Find endpoints without rate limiting applied [Basic]
│   ├── Exploit different rate limits for different HTTP methods [Basic]
│   ├── Use API versioning to access unprotected older version [Basic]
│   └── Modify request to match a different (higher-limit) policy [Basic]
│
├── Bypass rate limiter entirely [OR]
│   ├── Access backend directly (bypass gateway) [AND]
│   │   ├── Discover backend service address [Basic]
│   │   └── Backend accepts direct connections [Basic]
│   ├── Exploit server-side request forgery (SSRF) [Basic]
│   └── Use WebSocket upgrade to bypass HTTP rate limiting [Basic]
│
└── Disable rate limiter [OR]
    ├── Compromise admin credentials [see auth attack tree]
    ├── Modify rate limit policy via control plane API [AND]
    │   ├── Gain access to control plane [Basic]
    │   └── Modify policy for target endpoint [Basic]
    └── Cause rate limiter service outage [AND]
        ├── Overwhelm rate limit storage (Redis) [Basic]
        └── System fails open (allows traffic when limiter is down) [Basic]
```

### Building a Combined Hazard/Threat Register

A unified register merges safety hazards and security threats into a single artifact:

| ID | Type | Description | Source Analysis | Severity | Likelihood / Feasibility | Risk Score | Mitigations | Status |
|---|---|---|---|---|---|---|---|---|
| HT-001 | Security | Forged JWT enables cross-tenant access | STRIDE (Spoofing), FTA branch Auth-001 | Critical | Occasional / Medium feasibility | High | SR-001: JWT signature mandatory verification; SR-002: Key rotation policy; SR-003: Token issuer validation | Mitigated |
| HT-002 | Safety | Rate limiter failure causes cascade failure of backend services | PHA, FTA branch Avail-003 | Critical | Probable | High | SR-010: Circuit breaker on backend calls; SR-011: Rate limiter fail-closed policy; SR-012: Independent health monitoring | Open |
| HT-003 | Both | Redis failure disables both rate limiting (safety) and session management (security) | Common Cause Analysis | Critical | Remote | Medium | SR-020: Separate Redis instances for rate limiting and sessions; SR-021: Graceful degradation with local fallback counters | Open |
| HT-004 | Security | Verbose error messages disclose internal topology | STRIDE (Information Disclosure) | Marginal | Frequent | Medium | SR-030: Error sanitization middleware; SR-031: Custom error response templates per tenant | Mitigated |
| HT-005 | Safety | SOTIF-type: Auto-scaling responds correctly to metrics but cannot distinguish DDoS from legitimate traffic spike | SOTIF analysis | Critical | Occasional | High | SR-040: Traffic fingerprinting for anomaly detection; SR-041: Human-in-the-loop for scaling beyond threshold; SR-042: DDoS mitigation upstream | Open |

### Risk-Based Prioritization of Security Work

Using the unified register, prioritize work using a framework inspired by HARA's systematic approach:

#### Priority Matrix

| | Frequent | Probable | Occasional | Remote | Improbable |
|---|---|---|---|---|---|
| **Catastrophic** | P1 — Immediate | P1 — Immediate | P1 — Sprint | P2 — Quarter | P3 — Roadmap |
| **Critical** | P1 — Immediate | P1 — Sprint | P2 — Quarter | P2 — Quarter | P3 — Roadmap |
| **Marginal** | P2 — Quarter | P2 — Quarter | P3 — Roadmap | P3 — Roadmap | P4 — Backlog |
| **Negligible** | P3 — Roadmap | P3 — Roadmap | P4 — Backlog | P4 — Backlog | P4 — Backlog |

**Key insight from safety engineering**: Do not prioritize solely by individual risk score. Also consider:
- **Common cause failures**: A single fix that addresses a common cause resolves multiple hazards/threats simultaneously (highest ROI)
- **Minimal cut sets from FTA**: Single-point-of-failure basic events (cut sets of size 1) should be prioritized over events that require multiple simultaneous failures
- **Defense-in-depth gaps**: Where only one barrier exists between a threat and an impact, add a second barrier before optimizing existing barriers
- **SOTIF-type risks**: Functional insufficiencies that cannot be found by testing existing requirements (because the requirements themselves are insufficient) require exploratory analysis and are often higher priority than they appear

---

## Key Sources and References

### NASA Standards and Handbooks
1. **NASA-STD-8719.13** — NASA Technical Standard for Software Safety
2. **NASA-GB-8719.13** — NASA Software Safety Guidebook
3. **NPR 8715.3** — NASA Safety and Mission Assurance Requirements
4. **NASA-HDBK-1002** — Fault Tree Handbook with Aerospace Applications (2002)
5. **NPR 7150.2D** — NASA Software Engineering Requirements (2019)
6. **NASA/SP-2010-580** — NASA System Safety Handbook, Volume 1
7. **NASA-STD-8739.8** — NASA Software Assurance and Software Safety Standard

### ISO Standards
8. **ISO 26262:2018** — Road vehicles — Functional safety (Parts 1-12)
9. **ISO 21448:2022** — Road vehicles — Safety of the intended functionality (SOTIF)
10. **ISO/SAE 21434:2021** — Road vehicles — Cybersecurity engineering
11. **IEC 61508:2010** — Functional safety of electrical/electronic/programmable electronic safety-related systems

### Military Standards
12. **MIL-STD-882E** — Department of Defense Standard Practice for System Safety (2012)

### Books and Papers
13. Shostack, A., *Threat Modeling: Designing for Security*, Wiley, 2014
14. Howard, M. and Lipner, S., *The Security Development Lifecycle*, Microsoft Press, 2006
15. Leveson, N., *Engineering a Safer World: Systems Thinking Applied to Safety*, MIT Press, 2011
16. Schneier, B., "Attack Trees," Dr. Dobb's Journal, December 1999
17. Vesely, W.E. et al., "Fault Tree Handbook," NUREG-0492, U.S. Nuclear Regulatory Commission, 1981
18. Rausand, M. and Hoyland, A., *System Reliability Theory: Models, Statistical Methods, and Applications*, 2nd ed., Wiley, 2004
19. Young, W. and Leveson, N., "An Integrated Approach to Safety and Security Based on Systems Theory," Communications of the ACM, Vol. 57, No. 2, 2014
20. Schmittner, C. et al., "Security Application of Failure Mode and Effect Analysis (FMEA)," SAFECOMP 2014, LNCS 8666
21. Wuyts, K. et al., "LINDDUN privacy threat analysis methodology," KU Leuven, 2011
22. Mauw, S. and Oostdijk, M., "Foundations of Attack Trees," ICISC 2005, LNCS 3935
23. Lisova, E. et al., "Safety and Security Co-analysis: A Systematic Literature Review," IEEE Systems Journal, 2019
24. SAE ARP 4761 — Guidelines and Methods for Conducting the Safety Assessment Process on Civil Airborne Systems and Equipment

### Regulatory
25. **UNECE WP.29 R155** — UN Regulation on Cybersecurity and Cybersecurity Management Systems (2021)
26. **NIST SP 800-53** — Security and Privacy Controls for Information Systems and Organizations

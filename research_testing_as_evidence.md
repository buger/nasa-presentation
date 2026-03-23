# Testing as Evidence, Not Just Confidence

## What NASA and Automotive Safety Teach About Verification

*Internal reference material for applying high-assurance engineering lessons to software engineering, with examples relevant to API management platforms.*

---

## 1. NASA's Testing Philosophy

### 1.1 Verification vs. Validation: The Fundamental Distinction

NASA draws a sharp line between **verification** and **validation**, and understanding this distinction is foundational to the "testing as evidence" mindset.

- **Verification**: "Did we build the product right?" — Confirms that the software correctly implements its specified requirements. Verification is about internal consistency: does the code do what the spec says?
- **Validation**: "Did we build the right product?" — Confirms that the software, when placed in its intended environment, fulfills its intended purpose. Validation is about external correctness: does this actually solve the real-world problem?

In NASA's framework (per NASA-STD-8739.8, "Software Assurance and Software Safety Standard," and NPR 7150.2, "NASA Software Engineering Requirements"), verification is not optional or deferrable. Every requirement must have a corresponding verification method, and the result must be recorded as **evidence**. This is not a cultural preference — it is a procedural requirement with accountability chains.

NASA defines four primary verification methods:
1. **Test** — Exercising the software under controlled conditions and comparing observed behavior against expected behavior.
2. **Analysis** — Using analytical techniques (mathematical proofs, modeling, simulation) to demonstrate compliance.
3. **Inspection** — Visual examination of code, documents, or artifacts (code reviews, document reviews).
4. **Demonstration** — Operating the system to show it performs as intended, often in a representative environment.

Each requirement is mapped to one or more of these methods. The key insight: **testing is one form of evidence, not the only form, and not always the best form.**

### 1.2 NPR 7150.2D — Software Engineering Requirements

NPR 7150.2D is NASA's top-level directive governing software engineering practices across the agency. Key testing-related requirements include:

- **SWE-050 through SWE-058**: These sections govern software testing. SWE-050 requires that software testing be performed to demonstrate compliance with requirements. SWE-051 requires test procedures to be documented and reviewed. SWE-052 requires that test results be recorded and maintained.
- **SWE-061**: Requires that software verification be performed to ensure that each software requirement is implemented correctly and can be traced to a test or other verification method.
- **SWE-134**: Requires bidirectional traceability between requirements, design, code, and test cases.

> **Note:** SWE requirement numbers cited here are based on NPR 7150.2D; exact numbering may vary between revisions. Verify against the current edition.
- **Classification-driven rigor**: NPR 7150.2D classifies software into Classes A through E (Class A being the highest safety/mission criticality, Class E being the lowest). Testing rigor scales with classification:
  - **Class A** (human-rated, safety-critical): Requires the most rigorous testing — formal test plans, witnessed testing, independent verification and validation (IV&V), structural coverage analysis.
  - **Class B** (mission-critical, non-human-rated): Similar to Class A but with some tailoring allowances.
  - **Class C/D**: Progressively reduced requirements, but still requiring documented test evidence.
  - **Class E**: Minimal requirements, but still governed by project-specific plans.

- **Independent Verification and Validation (IV&V)**: For Class A and some Class B software, NASA mandates IV&V — testing and analysis performed by a team organizationally independent from the development team. The NASA IV&V facility in Fairmont, West Virginia, exists specifically for this purpose. IV&V is not just "someone else runs the tests"; it is an independent technical assessment that the software meets its requirements and is safe for its intended use.

### 1.2.1 The Software Requirements Specification (SRS) and How FRET Augments It

**Important clarification:** FRET does NOT replace the SRS. It **augments** it by formalizing the subset of requirements that have clear behavioral semantics (input/output/timing). The SRS remains the authoritative document.

#### What an SRS Actually Contains

An SRS (following IEEE 830 / NASA standards) is a comprehensive document — often hundreds of pages:

- **Section 1: Introduction** — purpose, scope, definitions, references
- **Section 2: Overall Description** — product perspective, functions, constraints, assumptions
- **Section 3: Specific Requirements** — the core content:
  - **3.1 Functional requirements** — behavioral "shall" statements (**FRET CAN formalize these**)
  - **3.2 Performance requirements** — timing constraints (some formalizable: "shall execute within 20ms")
  - **3.3 Interface requirements** — hardware/software interfaces (mostly NOT formalizable: "shall communicate via SpaceWire at 100 Mbps")
  - **3.4 Safety requirements** — constraints on dangerous states (**almost always formalizable**: "shall never command simultaneous opposing thrusters")
  - **3.5 Design constraints** — process/technology constraints (NOT formalizable: "shall be written in C99")
  - **3.6 Quality attributes** — maintainability, reliability (NOT formalizable: "shall be designed for maintainability")
- **Section 4: Traceability Matrix** — requirement → design → code → test
- **Section 5: Appendices**

**Only a subset of the SRS is formalizable in FRET** — specifically, requirements that have a clear trigger, component, timing, and behavioral response. In a typical SRS, approximately 40-60% of functional requirements and most safety requirements are candidates. Design constraints, quality attributes, and interface specs remain as traditional SRS text with verification by inspection or analysis.

#### The SRS → FRET Translation Flow

1. **Systems engineers write the SRS.** This is the authoritative document, going through formal reviews, sign-offs, and configuration management. FRET does not touch this process.

2. **Requirements engineers identify formalizable requirements.** They review Section 3 of the SRS and tag which "shall" statements have clear input/output/timing semantics.

3. **Formalizable requirements get translated into FRETish.** This is a **manual, expert step** — done by someone who understands both the domain and FRET. The original SRS requirement ID is preserved:

   SRS requirement FSW-REQ-0100:
   > *"The FSW shall transition to SAFE_MODE when any primary sensor reports a value exceeding the configured threshold for more than 3 consecutive cycles."*

   FRETish formalization (in FRET tool, tagged as FSW-REQ-0100):
   > *"When sensor_A_exceeded_count >= 3, the FlightController shall within 1 cycle satisfy mode = SAFE_MODE."*

   Notice: the vague "any primary sensor" became a specific variable. The vague "more than 3 consecutive cycles" became `sensor_A_exceeded_count >= 3`. The translator had to **make design decisions** — and those decisions may generate questions back to systems engineers: "Which sensors are 'primary'? Is it 3 or more, or strictly more than 3?"

4. **Both artifacts live together, linked by requirement IDs:**
   - SRS (authoritative document, Word/PDF, config-managed): FSW-REQ-0100 → English "shall" statement
   - FRET project (tool database, version-controlled): FSW-REQ-0100 → FRETish formalization + auto-generated CoCoSpec contract + temporal logic + trace diagram + realizability status
   - Traceability matrix (updated): FSW-REQ-0100 → FRET:FSW-REQ-0100 → test case → code location

5. **Non-formalizable requirements stay as-is in the SRS.** FSW-REQ-0500 ("shall be written in C99") lives in the SRS with verification method "Inspection" — a human reviews the code. No FRET, no Kind 2, just review.

#### The "Questions Back" Loop — Arguably the Most Valuable Part

When translating SRS → FRETish, the requirements engineer is **forced to resolve every ambiguity**. Every vague English phrase must become a specific variable with a specific condition. This surfaces questions:

- SRS says "anomalous" → FRET translation asks: "Which variable? What threshold?"
- SRS says "promptly" → FRET translation asks: "Within how many cycles?"
- SRS says "appropriate action" → FRET translation asks: "Which specific output changes?"
- SRS says "any primary sensor" → FRET translation asks: "Which sensors are 'primary'? Sensor A only, or A through D?"

These questions go **back to the systems engineers** who wrote the SRS. The SRS gets updated with more precise language. This feedback loop — FRET forcing precision, which improves the SRS — is arguably more valuable than the formal verification itself. Defects found at the requirements stage are orders of magnitude cheaper to fix than defects found in testing or operations.

#### What FRET Produces Per Requirement

For each formalized requirement, FRET generates four synchronized views:

1. **FRETish text** — human-readable structured English (the requirements engineer validates "did I write what I meant?")
2. **Semantic explanation** — FRET's unambiguous interpretation in plain English: "Whenever sensor_A_exceeded_count is greater than or equal to 3, at the next time step, mode must equal SAFE_MODE"
3. **Temporal logic formula** — the pmLTL/SMV formula consumed by Kind 2 and Copilot (humans rarely read this)
4. **Trace diagram** — interactive timeline where the engineer toggles inputs at each time step and sees if the requirement is satisfied or violated

The requirements engineer uses views 1, 2, and 4 to validate intent. View 3 is for tool consumption.

#### One Artifact, Three Consumers

The FRETish requirement (augmenting the SRS, not replacing it) simultaneously serves:

| Consumer | How they use the FRET requirement |
|---|---|
| **Developer** (flight software engineer) | Reads it alongside the SRS as their implementation spec — inputs, outputs, timing are explicit. Resolves the ambiguities in the original "shall" statement. |
| **Tester** | MC/DC test cases derive directly from the conditions. FRET requirement IDs go in test names for bidirectional traceability (SWE-134). |
| **Verifier** (IV&V engineer) | FRET generates temporal logic → Kind 2 proves it. Copilot generates runtime monitors from the same spec. |

This is the efficiency argument: FRET doesn't add a step — it replaces the ambiguity-resolution step that already happens (informally, in people's heads) with a formal, tool-supported version that produces machine-checkable artifacts as a byproduct.

#### Who Uses FRET at NASA

| Team | Uses FRET directly? | Relationship to FRET output |
|---|---|---|
| Systems engineers | Not typically | Write the original SRS; receive questions back from FRET translation that improve the SRS |
| Requirements engineers | Yes — primary authors | Translate SRS → FRETish, run realizability checks, validate trace diagrams |
| GN&C engineers | Not typically — use MathWorks/Simulink tooling | Receive FRET requirements as design spec; Simulink models checked against FRET contracts |
| Flight software engineers | Not typically — they write C/C++ | Receive FRET formalization alongside the SRS as their implementation spec |
| IV&V engineers | Yes — primary power users | Use FRET contracts to independently verify everyone else's work with Kind 2 |

#### Not All Requirements Are Formalizable — The Four Verification Methods

Only ~40-60% of SRS requirements are candidates for FRET formalization — specifically, behavioral "shall" statements with clear input/output/timing semantics. The remaining requirements are still real, still verified, but through different methods.

**What FRET CANNOT formalize and why:**

| Requirement type | Example | Why not formalizable | Verified by |
|---|---|---|---|
| Design constraints | "Shall be written in C99 conforming to JPL Rule Set" | Process/technology choice — no input/output/timing behavior | Inspection (linter + code review) |
| Quality attributes | "Shall be designed for maintainability" | Subjective, no measurable trigger/response | Inspection (design review) |
| Interface specs (structural) | "Communicate via SpaceWire at 100 Mbps" | Hardware/protocol spec, not software behavior | Analysis + Test |
| Capacity/load requirements | "Support 10,000 API definitions simultaneously" | Sizing constraint, not behavioral logic | Test (load testing) |
| Documentation/process | "Contractor shall deliver source code and traceability matrices" | Deliverable obligation, not software behavior | Inspection |
| Human factors | "UI shall be intuitive for trained operators" | Subjective, context-dependent | Demonstration |

**NASA (and DO-178C) defines exactly four verification methods.** Every requirement in the SRS gets assigned one:

| Verification method | Used for | How it works | FRET involved? |
|---|---|---|---|
| **Test** | Behavioral requirements | Run software, check behavior against expected output. MC/DC coverage for DO-178C Level A. | **Yes** — FRET formalizes the requirement, generates test conditions, Kind 2 proves it, Copilot monitors it |
| **Analysis** | Performance, timing, mathematical properties | Mathematical/logical argument or calculation. E.g., worst-case execution time (WCET) analysis proves a loop completes in 18ms < 20ms budget. | No — mathematical proof, not temporal logic |
| **Inspection** | Code standards, design constraints, documentation | A qualified person reviews the code/document and confirms compliance. "Yes, this is C99. Yes, all functions have header comments." | No — human judgment |
| **Demonstration** | Usability, integration, operational scenarios | Show it working in realistic conditions — like UAT or acceptance demo. "Operator completed recovery procedure in 4 minutes." | No — observed performance |

**Example SRS with verification methods assigned:**

```
FSW-REQ-0100 | "Shall transition to SAFE_MODE when sensor > threshold"
             | Priority: P0  | Verification: Test      ← FRET + MC/DC + Kind 2

FSW-REQ-0200 | "Control loop shall complete within 20ms"
             | Priority: P0  | Verification: Analysis   ← WCET mathematical proof

FSW-REQ-0500 | "Shall be written in C99 per JPL coding standard"
             | Priority: P1  | Verification: Inspection ← linter + human code review

FSW-REQ-0600 | "Shall be designed for maintainability"
             | Priority: P2  | Verification: Inspection ← design review

FSW-REQ-0700 | "Operator shall be able to initiate safe mode manually within 30s"
             | Priority: P1  | Verification: Demonstration ← operator acceptance test
```

**The practical implication:** Teams don't need to formalize everything. The strategy is:
- **P0 behavioral requirements** (safety, auth, data integrity) → FRET + MC/DC + Kind 2. Full formal treatment.
- **Performance requirements** → Analysis (timing budgets, load testing with mathematical bounds)
- **Coding standards** → Inspection (linters, code review checklists — automated where possible)
- **Integration/usability** → Demonstration (staging environment, acceptance testing)

The 40-60% that IS formalizable is typically the most **critical** 40-60% — the behavioral logic where bugs cause real incidents. The non-formalizable requirements tend to be lower-risk or verified by other well-established methods.

#### How DOORS and FRET Fit Together

In practice, the SRS doesn't live as a Word document — it lives in **IBM Rational DOORS** (Dynamic Object-Oriented Requirements System), the industry-standard requirements management tool used across aerospace, automotive, and defense. DOORS handles storage, versioning, traceability, and change management. FRET handles formalization. They are complementary:

| Concern | DOORS | FRET |
|---|---|---|
| **What it stores** | ALL requirements — functional, interface, safety, design constraints, quality attributes | Only the formalizable behavioral subset (~40-60% of functional, most safety) |
| **Format** | English text + structured attributes + traceability links | FRETish structured English + temporal logic + CoCoSpec contracts |
| **Traceability** | Requirement → design → code → test (bidirectional links, change impact analysis) | Requirement → contract → verification result (formal) |
| **Analysis** | Coverage gap detection (by link counting), change impact, baselines | Realizability, vacuity, formal verification, trace diagrams |
| **Output** | Reports, matrices, baselines, approval workflows | CoCoSpec contracts, temporal logic formulas, Copilot specs, JSON export |

**The integrated flow (the complete multi-step approach):**

1. **Systems engineers** write requirements in DOORS — this is the SRS, the single source of truth, with unique IDs (e.g., DOORS-REQ-0100), version control, approval workflows
2. **Requirements engineers** identify formalizable requirements and export/translate them to FRET, preserving DOORS requirement IDs as FRET requirement IDs
3. **FRET formalization generates questions** (forced by precision): "What does 'anomalous' mean? Which sensors are 'primary'?" → answers go back to systems engineers → DOORS requirements get updated with more precise language
4. **FRET exports CoCoSpec contracts** → Kind 2 verifies Lustre models against them (design-time proof)
5. **FRET exports JSON** → Ogma → Copilot C99 runtime monitors (runtime checking)
6. **Traceability links in DOORS are updated**: DOORS-REQ-0100 → FRET:FSW-REQ-0100 → Kind2:proof-result → test:TestSafeModeTransition → code:fsw_mode.c:line-247
7. **Non-formalizable requirements** stay in DOORS only, with verification method "Inspection" or "Analysis" — no FRET involvement
8. **IV&V team** uses both: DOORS for traceability auditing, FRET/Kind 2 for formal verification of the formalizable subset

This is the complete NASA multi-team, multi-tool pipeline. The key insight: **no single tool covers everything**. DOORS manages, FRET formalizes, Kind 2 proves, Copilot monitors, and MC/DC tests verify the hand-written code. Each tool has a specific role, and the requirement ID is the thread that connects them all.

**For software engineering teams adapting this approach:** You probably don't have DOORS. The analogous mapping:
- DOORS → Jira/Linear with structured requirement fields and bidirectional links
- SRS → well-structured tickets/epics with explicit acceptance criteria
- FRET → FRETish formalizations attached to tickets (or in a separate FRET project linked by ticket IDs)
- Kind 2 → design-time verification (may not be practical for most teams)
- Copilot monitors → runtime assertions / observability checks
- MC/DC tests → table-driven tests in CI with requirement IDs in test names

#### How the SRS Evolves: Bug Fixes, New Features, and Extensions

The SRS is a **living document under configuration management**, not a one-time artifact. You don't create a new SRS for each change — you update the existing one. In DOORS, every change is tracked: who, when, why, and the previous version. Baselines let you diff "SRS v2.3" against "SRS v2.4" like a git diff.

##### Scenario 1: Bug Fix

Example: Flight software enters SAFE_MODE when sensor reads exactly the threshold (off-by-one: `>=` vs `>`). The requirement said "exceeding the threshold."

**Step 1: Problem Report (PR)** — a formal tracked artifact, not a Jira comment:
> PR-2024-0847: FSW-REQ-0100 specifies "exceeding the threshold" but implementation uses `>=`.

**Step 2: Root cause analysis — the critical fork:**
- **Code bug:** Requirement is correct ("exceeding" = `>`), code used `>=`. Fix code, update tests. No SRS change.
- **Requirements bug:** Requirement said "exceeding" but intent was `>=`. Fix SRS, then fix code to match.
- **Requirements ambiguity (most common):** "Exceeding" is ambiguous — could mean either. Fix SRS to be precise, update FRET, verify code matches.

**Step 3: If the SRS needs updating:**
1. Change goes through the **Change Control Board (CCB)** — even for a one-character change
2. In DOORS: requirement edited in-place, old text preserved in version history, change note links to PR-2024-0847
3. In FRET: FRETish formalization updated (`>` → `>=`), realizability re-checked
4. Kind 2 re-verifies Lustre model against updated contract
5. MC/DC tests updated — boundary case explicitly tested
6. Traceability: FSW-REQ-0100 (v2) → PR-2024-0847 → test update → code fix

**Key insight for bugs:** Most bugs in safety-critical systems trace to **requirements ambiguity**, not coding errors. If the requirement had been formalized in FRET from the start, `>` vs `>=` would have been resolved during translation, not discovered in testing.

##### Scenario 2: New Feature

Example: "When spacecraft enters eclipse, reduce non-essential systems to conserve battery."

**Step 1: New requirements added to existing SRS** (not a new document):
- FSW-REQ-0250: Transition non-essential to LOW_POWER within 5s of eclipse entry
- FSW-REQ-0251: Restore to NORMAL within 10s of eclipse exit
- FSW-REQ-0252: Essential subsystems (attitude control, comms) NEVER reduced during eclipse
- FSW-REQ-0253: Log all eclipse mode transitions with timestamps

**Step 2: Identify formalizable requirements:**
- FSW-REQ-0250: Formalizable — clear trigger, timing, response
- FSW-REQ-0251: Formalizable — same pattern
- FSW-REQ-0252: Formalizable as safety constraint — "shall NEVER"
- FSW-REQ-0253: Partially — logging is a side effect, but "all transitions" is checkable

**Step 3: Add to existing FRET project, realizability check catches conflicts:**
Maybe FSW-REQ-0250 (reduce non-essential) conflicts with existing FSW-REQ-0180 (thermal heaters at full power always) — and thermal heaters are classified as non-essential. FRET flags: "These requirements cannot be simultaneously satisfied." Caught **before any code is written**.

**Step 4: Normal flow** — contracts, verification, tests, code, traceability update. SRS baseline advances from v2.4 to v2.5.

##### Scenario 3: Extending Existing Software (Most Common in Commercial Settings)

Same as new features, with one addition: **impact analysis** before making changes.

1. **DOORS impact analysis:** "If I add eclipse power requirements, which existing requirements reference power subsystems?" DOORS shows all linked requirements, designs, tests, code.
2. **FRET realizability:** Add new requirements to existing FRET project. Check ALL requirements (old + new) together. Conflicts between new and existing behavior caught immediately.
3. **Code:** Modified pure functions get new MC/DC test rows. Existing rows unchanged (no regression).

##### Concrete Example: Extending Our Go Middleware

Bug filed: "CORS passthrough doesn't work when request has OPTIONS method AND X-Custom-Auth header — auth check runs before CORS passthrough."

**Step 1: Problem Report** — BUG-4521 filed.

**Step 2: Root cause = requirements gap.** R2 says CORS passthrough sets `passthrough_cors = true`, but no requirement says auth should be skipped when `passthrough_cors` is true. The requirement doesn't cover the interaction.

**Step 3: Add new requirement:**
> R8: "When passthrough_cors is true, the MiddlewareExecutor shall immediately satisfy auth_bypassed = true."

**Step 4: FRET re-check.** Does R8 conflict with existing requirements? Maybe R3 (NewRelic tracing) assumes auth always runs. If so, FRET flags the conflict.

**Step 5: Update everything:**
- Add `auth_bypassed` to `MiddlewarePlan` struct
- Update `PlanBeforeProcess` pure function
- Add new MC/DC test rows for R8 conditions
- Update Lustre model if maintained
- Close BUG-4521 with full traceability: BUG-4521 → R8 → test:TestR8 → plan.go:line-45

##### Summary: The SRS Change Lifecycle

| Event | SRS change? | FRET change? | New document? |
|---|---|---|---|
| **Code bug** (requirement correct, code wrong) | No | No | No — just fix code + tests |
| **Requirements bug** (requirement wrong) | Yes — edit in place, CCB approval | Yes — update FRETish | No — same SRS, new version |
| **Requirements ambiguity** (most common) | Yes — make precise | Yes — formalization resolves it | No — same SRS, new version |
| **New feature** | Yes — add new requirements with new IDs | Yes — formalize the behavioral subset | No — same SRS, new requirements added |
| **Extension / enhancement** | Yes — new + possibly modified existing | Yes — add new + re-check realizability of all | No — same SRS, impact analysis first |
| **Decommission / remove feature** | Yes — requirements marked deprecated/deleted | Yes — remove from FRET, re-check realizability | No — same SRS, requirements removed |

The SRS is always versioned and baselined, growing and evolving with the software. The requirement ID (FSW-REQ-XXXX) is the stable anchor that everything else links to.

##### SRS Structure for Multi-Component Systems

**Correction to the above:** The statement "ONE document per system" is an oversimplification. For systems with multiple components, the standard practice is a **hierarchical requirements decomposition**:

```
Level 0: Mission/Business Requirements
         "The system shall provide automated backup management
          with 99.99% data durability"
              │
Level 1: System Requirements Document (SyRD)
         ONE document for the whole system
         Cross-cutting requirements + interfaces between components
              │
         ┌────────────┬──────────────┬─────────────────┐
         │            │              │                 │
Level 2: Gateway     Dashboard    Cloud Mgmt       Analytics
         SRS         SRS          Layer SRS        Layer SRS
         (own doc)   (own doc)    (own doc)        (own doc)
```

**Each component gets its own SRS**, governed by and traceable to the system-level document (SyRD) above it. Reasons:

1. **Different teams, different cadences.** Gateway ships weekly, analytics ships monthly. Separate documents = independent change control. A gateway change doesn't block analytics review.
2. **Different concerns.** Gateway = latency, auth, routing. Analytics = data pipelines, aggregation accuracy. Separate documents make completeness analysis tractable.
3. **FRET projects map to components.** FRET's fundamental unit is the "component" with typed inputs/outputs. Each FRET project corresponds to one component SRS.
4. **NASA does exactly this.** A spacecraft has: system requirements → flight software SRS → GN&C SRS, fault management SRS, communications SRS, etc. Each is a separate document with its own change control.

**What goes in each level:**

| Document | Contains | Example |
|---|---|---|
| **System Requirements (SyRD)** | Cross-cutting requirements, interface contracts between components, system-level quality attributes | "Backup request from Dashboard shall reach Cloud Mgmt Layer within 200ms via Gateway." "All components shall authenticate via Gateway's auth service." |
| **Component SRS** | All component-specific behavior | "Gateway shall reject requests without valid JWT within 5ms." "Cloud Mgmt Layer shall retry failed backups up to 3 times." |
| **Interface Control Document (ICD)** | Schemas, APIs, protocols, data formats between components | OpenAPI specs, protobuf definitions, event schemas |

**The SyRD captures what no single component SRS can:** interface requirements (contracts between components), system-level safety ("no single component failure shall cause data loss"), and cross-cutting concerns ("all components log in structured JSON with correlation IDs").

**Traceability across the hierarchy:**

System requirement SyRD-REQ-0010 ("Backup requests processed within 5 minutes end-to-end") decomposes into:
- GW-REQ-0050: "Gateway routes backup requests within 50ms"
- CM-REQ-0120: "Cloud Mgmt acknowledges within 2s"
- CM-REQ-0121: "Cloud Mgmt completes backup within 4 minutes"
- AN-REQ-0030: "Analytics records completion within 30s"

Each component requirement traces UP to the system requirement it satisfies. Verifying the system requirement = verifying all its decomposed component requirements together.

**DOORS + FRET structure for multi-component systems:**

DOORS project structure:
- Module: System Requirements (SyRD) — interface + cross-cutting
- Module: Gateway SRS — gateway behavior
- Module: Dashboard SRS — dashboard behavior
- Module: Cloud Management Layer SRS — backup orchestration
- Module: Analytics Layer SRS — data pipeline
- Module: Interface Control Document (ICD) — schemas, APIs

FRET project structure:
- Project: Gateway — formalizes behavioral subset of Gateway SRS
- Project: CloudMgmtLayer — formalizes behavioral subset of Cloud Mgmt SRS
- Project: AnalyticsLayer — formalizes behavioral subset of Analytics SRS
- (Dashboard may have fewer formalizable requirements — UI behavior is hard to formalize)

**Practical adaptation for software teams without DOORS:**

| NASA/Aerospace | Software team adaptation |
|---|---|
| SyRD (system-level) | Architecture Decision Records (ADRs) + API contracts (OpenAPI specs) + system-level epic in Jira |
| Component SRS | Requirements/acceptance criteria in Jira epics per service, or a living requirements doc per service |
| Interface Control Document | OpenAPI specs, protobuf definitions, AsyncAPI for events |
| DOORS traceability | Jira ticket links + requirement IDs in test names + contract tests |
| FRET projects per component | FRETish formalizations for critical decision logic per service |

The key principle: **the document structure mirrors the architecture.** One SRS per deployable component/service, one system-level document for the glue between them.

##### Deciding What Goes Where: Component SRS vs. System SyRD vs. ICD

The boundary between documents follows established principles from **ISO/IEC/IEEE 29148:2018** (which replaced IEEE 830). The core rule:

**The Three Tests:**

1. **Can you assign ONE owner who implements it?** Yes → component SRS. No (requires multiple components) → SyRD, decompose into component requirements.
2. **If you changed this requirement, which teams need to know?** One team → component SRS. Multiple teams → ICD (if it's about the contract) or SyRD (if it's about end-to-end behavior).
3. **Is it about what a COMPONENT does, or what the SYSTEM achieves?** Component behavior → component SRS. System-level outcome → SyRD.

**Practical rule of thumb:** "If I give this requirement to team X, can they implement and test it without coordinating with team Y?" Yes → component SRS. No, team Y must also do something → SyRD. No, they need to agree on format/protocol → ICD.

**Concrete example: Gateway loading API definitions from Dashboard**

System-level requirement:
> SyRD-REQ-0080: "The Gateway shall serve API traffic using the current API definitions managed by the Dashboard, with no more than 60 seconds of staleness under normal operation."

This cannot be implemented by any single component alone — it requires Dashboard to serve definitions quickly AND Gateway to poll/cache correctly. It decomposes into:

Dashboard SRS:
- DASH-REQ-0040: "Dashboard shall expose current API definitions via GET /v2/apis within 100ms"
- DASH-REQ-0041: "Dashboard shall include version identifier and last-modified timestamp in response"
- DASH-REQ-0042: "Dashboard shall emit APIDefinitionsUpdated event within 5s of any change"

Gateway SRS:
- GW-REQ-0100: "Gateway shall load API definitions from Dashboard API on startup"
- GW-REQ-0101: "Gateway shall refresh by polling Dashboard every 30 seconds"
- GW-REQ-0102: "Gateway shall retry failed calls up to 3 times with exponential backoff (1s, 2s, 4s)"
- GW-REQ-0103: "When Dashboard is unreachable after all retries, Gateway shall serve last successfully loaded definitions"
- GW-REQ-0104: "When serving stale definitions (>60s), Gateway shall set X-API-Definitions-Stale: true header"
- GW-REQ-0105: "When Dashboard returns matching version, Gateway shall skip reloading"

ICD (Interface Control Document):
- ICD-GW-DASH-001: "Gateway→Dashboard: GET /v2/apis with APIDefinitionResponse schema"
- ICD-GW-DASH-002: "Dashboard→Gateway: APIDefinitionsUpdated event on topic api.definitions.updated"

Traceability: SyRD-REQ-0080 decomposes into DASH-REQ-0040 + DASH-REQ-0042 + GW-REQ-0101 + GW-REQ-0102 + GW-REQ-0103 + ICD-GW-DASH-001. Together they guarantee: Dashboard publishes within 5s + Gateway polls every 30s with retries = worst-case staleness under 60s.

**Decision table for common requirement types:**

| Requirement type | Where it lives | Example |
|---|---|---|
| Component behavior (one owner) | **Component SRS** | "Gateway shall reject invalid tokens within 5ms" |
| Fault tolerance of one component | **Component SRS** (traced to system availability req) | "Gateway shall cache APIs when Dashboard is down" |
| End-to-end system behavior | **System SyRD** (decomposes into component reqs) | "System shall process backups within 5 min end-to-end" |
| Data format / protocol between components | **ICD** | "Gateway calls Dashboard using APIDefinition schema v2" |
| System-level safety | **System SyRD** | "No single component failure shall cause data loss" |
| Cross-cutting quality attribute | **System SyRD** (each component SRS references it) | "All components shall log structured JSON with correlation IDs" |
| Non-functional budget | **System SyRD** (decomposed into per-component budgets) | "5 min total = 50ms Gateway + 2s ack + 4min backup + 30s analytics" |

**Grey areas and honest guidance:**

1. **Fault tolerance involving another component:** "Gateway caches when Dashboard is down" — Gateway implements it, but the reason is system availability. Put the implementation requirement in Gateway SRS, trace it to a system-level availability requirement in SyRD. Both documents reference it at different abstraction levels.

2. **Shared infrastructure:** "All components shall use structured logging" — system SyRD as a system-wide mandate, each component SRS says "Component X implements logging per SyRD-REQ-0200."

3. **Tightly coupled components:** If decomposition feels awkward — you can't write one component's requirements without constantly referencing the other — that's a design smell, not a requirements problem. Requirements decomposition problems often surface architecture problems. Consider whether the components should be merged or the coupling reduced.

##### The Interface Control Document (ICD) in Detail

The ICD is a **separate document** — not part of any component's SRS. It sits between two (or more) component SRSes and defines the **contract at their boundary**: data formats, protocols, message schemas, timing constraints, error handling conventions.

**The key property:** the ICD has **two owners**. Both the Gateway team AND the Dashboard team must agree on and sign off on ICD-GW-DASH. Neither can unilaterally change it. That's why it can't live in either team's SRS — it's shared territory.

**How ICD relates to SRS and FRET:**

| Aspect | SRS | ICD | FRET |
|---|---|---|---|
| **Scope** | One component's behavior | The boundary between two components | One component's formalizable behavior |
| **Owner** | One team | Two teams (joint ownership) | Requirements/IV&V engineer |
| **Content** | "Component SHALL do X" | "Data looks like Y, protocol is Z" | "When A, component shall satisfy B" |
| **Focus** | What the component does (verbs) | What flows between components (nouns) | Temporal behavioral properties (provable verbs) |
| **Change control** | One team's CCB | Joint CCB (both teams must approve) | Updated when SRS changes |
| **Testable how?** | MC/DC tests, unit tests, integration tests | Contract tests, schema validation | Kind 2 proof, Copilot monitors |

**The critical distinction:** The ICD says "the response has a `version` field of type string and an `apis` array" (the **shape** of data). The SRS says "Gateway SHALL skip reloading when the version matches" (what to **do** with that data). FRET formalizes the SRS: "When response_version = loaded_version, PlanBeforeProcess shall immediately satisfy skip_reload = true" (the **provable** behavior).

**Example ICD: Gateway ↔ Dashboard (ICD-GW-DASH v2.1)**

```
══════════════════════════════════════════════════════════════
  INTERFACE CONTROL DOCUMENT
  ICD-GW-DASH v2.1
  Gateway ↔ Dashboard API Definitions Interface

  Owners: Gateway Team, Dashboard Team
  Approved: 2026-02-15 (CCB-2026-0042)
  Status: Active
══════════════════════════════════════════════════════════════

1. SCOPE
   This ICD defines the interface between the API Gateway
   and the Dashboard for loading and refreshing API definitions.

2. INTERFACE IDENTIFICATION
   ICD-GW-DASH-001: API Definitions REST Endpoint
   ICD-GW-DASH-002: API Definitions Change Event
   ICD-GW-DASH-003: Health Check Endpoint

3. INTERFACE ICD-GW-DASH-001: API Definitions REST Endpoint

   3.1 Direction:      Gateway → Dashboard (request/response)
   3.2 Transport:      HTTPS, mTLS required
   3.3 Method:         GET
   3.4 Path:           /v2/apis
   3.5 Authentication: Service-to-service JWT (audience: "dashboard")

   3.6 Request Headers:
       If-None-Match: <etag>     (optional, for conditional fetch)
       X-Correlation-ID: <uuid>  (required)

   3.7 Response — 200 OK:
       Content-Type: application/json
       ETag: <version-hash>

       Schema: APIDefinitionResponse
       {
         "version": string,          // semantic version "2.4.1"
         "last_modified": timestamp,  // RFC 3339
         "apis": [
           {
             "id": string,           // unique API identifier
             "name": string,         // human-readable name
             "listen_path": string,  // e.g. "/users/v2"
             "target_url": string,   // backend service URL
             "methods": [string],    // ["GET","POST","PUT"]
             "auth_required": bool,
             "rate_limit": {
               "per_second": int,
               "burst": int
             },
             "cors": {
               "enabled": bool,
               "allowed_origins": [string]
             },
             "active": bool
           }
         ]
       }

   3.8 Response — 304 Not Modified:
       (when If-None-Match matches current ETag)
       No body.

   3.9 Response — 401 Unauthorized:
       { "error": "invalid_token", "message": string }

   3.10 Response — 503 Service Unavailable:
        { "error": "database_unavailable", "message": string }
        Retry-After: <seconds>

   3.11 Timing Constraints:
        - Dashboard SHALL respond within 100ms (p99)
        - Gateway SHALL timeout after 2000ms
        - Gateway SHALL retry up to 3x with backoff (1s, 2s, 4s)

   3.12 Backward Compatibility:
        - Fields may be ADDED to the response without version bump
        - Fields SHALL NOT be removed or renamed without major version
        - Gateway MUST ignore unknown fields (forward-compatible)

4. INTERFACE ICD-GW-DASH-002: API Definitions Change Event

   4.1 Direction:     Dashboard → Gateway (async notification)
   4.2 Transport:     Message bus (NATS/Kafka)
   4.3 Topic:         api.definitions.updated
   4.4 Format:        JSON

   4.5 Schema: APIDefinitionsUpdatedEvent
       {
         "event_id": string,         // unique event ID
         "timestamp": timestamp,     // when the change occurred
         "version": string,          // new version identifier
         "changed_api_ids": [string] // which APIs changed
       }

   4.6 Timing:
       - Dashboard SHALL emit within 5s of any definition change
       - Gateway SHOULD re-fetch within 10s of receiving event
       - Events are at-least-once (Gateway must handle duplicates)

   4.7 Ordering:
       - No ordering guarantee across partitions
       - Gateway SHALL use version field to detect stale events

5. INTERFACE ICD-GW-DASH-003: Health Check

   5.1 Direction:     Gateway → Dashboard
   5.2 Method:        GET /healthz
   5.3 Response 200:  { "status": "ok", "version": string }
   5.4 Response 503:  { "status": "degraded", "reason": string }
   5.5 Timing:        SHALL respond within 50ms

6. ERROR HANDLING CONVENTIONS

   6.1 All error responses use the standard error envelope:
       { "error": string, "message": string, "request_id": string }
   6.2 HTTP status codes follow RFC 7231
   6.3 Gateway treats any 5xx as "Dashboard unavailable"
       and falls back to cached definitions

7. VERSIONING

   7.1 This ICD follows semantic versioning
   7.2 Minor versions: additive changes (new fields, new endpoints)
   7.3 Major versions: breaking changes (path change, field removal)
   7.4 Both teams must approve major version changes via CCB
```

**Which ICD constraints are FRET-formalizable?**

Most ICD content is structural (schemas, field types, JSON shapes) — not formalizable in FRET. But behavioral constraints within the ICD ARE formalizable:

| ICD constraint | FRET-formalizable? | Why / how |
|---|---|---|
| Response schema (fields, types) | No | Schema validation, not temporal behavior |
| "Dashboard SHALL respond within 100ms" | **Yes** | Timing constraint → becomes DASH-REQ-0040 in Dashboard FRET project |
| "Gateway SHALL timeout after 2000ms" | **Yes** | Timing constraint → becomes GW-REQ-0106 in Gateway FRET project |
| "Events are at-least-once" | Partially | Can express "handler must be idempotent" as Gateway behavioral requirement |
| "Fields SHALL NOT be removed without major version" | No | Process constraint, verified by schema diff tooling |
| "Gateway MUST ignore unknown fields" | **Yes** | Behavioral requirement for Gateway → goes into Gateway SRS and FRET |
| "Dashboard SHALL emit event within 5s" | **Yes** | Timing constraint → becomes DASH-REQ-0042 in Dashboard FRET project |

**Key principle:** When an ICD constraint IS formalizable, it gets **pulled into the relevant component's SRS** as a proper requirement and then formalized in that component's FRET project. The ICD references the FRET formalization for traceability but doesn't "own" it.

**ICD FRET Traceability appendix:**

Every ICD should include a traceability section linking behavioral constraints to their FRET formalizations:

```
ICD-GW-DASH APPENDIX: FRET Traceability

ICD Constraint                    → Component Req  → FRET ID
3.11 "respond within 100ms"       → DASH-REQ-0040  → FRET:Dashboard:DASH-REQ-0040
3.11 "timeout after 2000ms"       → GW-REQ-0106    → FRET:Gateway:GW-REQ-0106
4.6  "emit within 5s"             → DASH-REQ-0042  → FRET:Dashboard:DASH-REQ-0042
4.6  "re-fetch within 10s"        → GW-REQ-0107    → FRET:Gateway:GW-REQ-0107
4.7  "handle duplicates"          → GW-REQ-0108    → FRET:Gateway:GW-REQ-0108
```

**Dedicated interface FRET projects for critical interfaces:**

For safety-critical or high-risk interfaces, you can create a FRET project specifically for the interface. This enables **cross-component realizability checking** — "can both sides satisfy their obligations simultaneously?"

```
FRET Project: Interface_GW_DASH
  Component: Gateway    (for Gateway-side obligations)
  Component: Dashboard  (for Dashboard-side obligations)

  Requirements:
    ICD-001-A: "When Gateway sends api_request,
                Dashboard shall within 100ms satisfy
                response_sent = true"

    ICD-001-B: "When Gateway sends api_request &
                Dashboard response_time > 2000ms,
                Gateway shall immediately satisfy
                timeout_triggered = true"

    ICD-002-A: "When Dashboard api_definition_changed is true,
                Dashboard shall within 5s satisfy
                event_emitted = true"
```

FRET's realizability check on this project catches interface-level conflicts — for example, if Gateway expects responses within 2s but Dashboard is allowed 5s for certain operations. These contradictions surface before any code is written.

**When to use which approach:**

| Situation | FRET approach for ICD |
|---|---|
| Most interfaces | FRET records in component projects, ICD references them via traceability appendix |
| Safety-critical interfaces | Dedicated interface FRET project for cross-component realizability |
| Simple CRUD APIs | No FRET needed — schema validation + contract tests are sufficient |

**In software terms — what you already have that maps to ICD:**

| NASA / Aerospace ICD | Software team equivalent |
|---|---|
| ICD REST endpoint section | **OpenAPI / Swagger spec** |
| ICD event/message section | **AsyncAPI spec** or **protobuf definitions** |
| ICD schema definitions | **JSON Schema**, **protobuf**, **GraphQL schema** |
| ICD timing constraints | SLA definitions, timeout configs |
| ICD versioning rules | API versioning policy doc |
| ICD error conventions | Error response standards doc |
| Joint CCB approval for changes | PR review requiring approval from both teams |

**The practical gap:** NASA consolidates all interface artifacts into ONE controlled document per interface pair. Software teams typically scatter these across OpenAPI files, README sections, Confluence pages, and tribal knowledge. Consolidating into an explicit ICD (even a well-structured markdown file per interface pair) is the most practical immediate win.

**The complete document set showing where ICD fits:**

```
System Requirements (SyRD)         ← what the SYSTEM must do
    │
    ├── Gateway SRS                ← what GATEWAY must do
    │       │
    │       ├── FRET: Gateway      ← formal behavioral subset
    │       │
    ├── ICD-GW-DASH ──────────────── shared contract (schemas, protocols, timing)
    │       │                         references FRET IDs from both component projects
    │       ├── OpenAPI spec       ← machine-readable contract (generated from ICD or vice versa)
    │       │
    ├── Dashboard SRS              ← what DASHBOARD must do
    │       │
    │       ├── FRET: Dashboard    ← formal behavioral subset
    │
    ├── ICD-GW-CLOUD ────────────── Gateway ↔ Cloud Mgmt contract
    │
    ├── ICD-DASH-ANALYTICS ──────── Dashboard ↔ Analytics contract
    │
    └── ... (one ICD per interface pair that needs formal control)
```

### 1.3 Requirements-Based Testing vs. Structural Coverage

NASA's testing approach distinguishes two complementary activities:

**Requirements-Based Testing (RBT):**
- Each requirement generates one or more test cases.
- Tests are designed to exercise both normal and robustness (off-nominal) conditions specified in requirements.
- The goal is to demonstrate that every "shall" statement in the requirements has been verified.
- RBT answers: "Does the software do everything it is required to do?"

**Structural Coverage Analysis:**
- After requirements-based testing is complete, structural coverage analysis determines what code was NOT exercised by the requirement-based tests.
- This is explicitly NOT about achieving a coverage number for its own sake.
- Its purpose is to find **requirements gaps**: code that exists but has no corresponding requirement (potential dead code or missing requirements).
- Structural coverage answers: "Is there code that no requirement caused us to test?" If yes, either: (a) a requirement is missing, (b) a test case is missing, or (c) the code is dead/deactivated and should be justified or removed.

This is a critical reframe for commercial software teams: **coverage is a diagnostic tool for requirements completeness, not a measure of test quality.**

### 1.4 MC/DC — Modified Condition/Decision Coverage

MC/DC is the most rigorous structural coverage criterion used in safety-critical software. MC/DC was formalized by John Joseph Chilenski (Boeing) and Steven P. Miller (Rockwell Collins) in their 1994 paper, in the context of DO-178B avionics certification. NASA subsequently adopted MC/DC for its highest-criticality software. It was later carried forward into DO-178C for Level A (catastrophic failure condition) software.

**What MC/DC requires:**

For every decision (boolean expression) in the code, MC/DC requires that:
1. Every point of entry and exit in the program has been invoked at least once.
2. Every condition in a decision has taken all possible outcomes at least once.
3. Every decision in the program has taken all possible outcomes at least once.
4. **Each condition in a decision has been shown to independently affect the outcome of the decision.**

Criterion 4 is what distinguishes MC/DC from simpler coverage metrics. "Independently affect" means: holding all other conditions fixed, changing just this one condition changes the decision outcome.

**Example:**

Consider the decision: `(A && B) || C`

To achieve MC/DC, you need test cases that show:
- A independently affects the outcome (find two cases where only A differs and the decision outcome changes)
- B independently affects the outcome
- C independently affects the outcome

An MC/DC-satisfying test set for `(A && B) || C`:

| Test | A | B | C | Result |
|------|---|---|---|--------|
| T1   | T | T | F | T      |
| T2   | F | T | F | F      |
| T3   | T | F | F | F      |
| T4   | F | F | T | T      |

- T1 vs T2: A independently affects outcome (B=T, C=F held constant)
- T1 vs T3: B independently affects outcome (A=T, C=F held constant)
- T3 vs T4: C independently affects outcome (A and B are fixed in the sense that the A&&B sub-expression evaluates to F in both cases; here only C changes: C=F→T flips the result F→T)

> **Note:** DO-178C recognizes multiple MC/DC interpretations: unique-cause (only the condition of interest changes), unique-cause + masking, and masking MC/DC. Under strict unique-cause MC/DC, the independence pair for C must differ only in C's value. The pair T3 (A=T, B=F, C=F)→F vs T4 (F, F, T)→T would not satisfy unique-cause because A also changes; an alternative unique-cause pair for C is (A=F, B=F, C=F)→F vs (A=F, B=F, C=T)→T, or (A=F, B=T, C=F)→F vs (A=F, B=T, C=T)→T. Under masking MC/DC, T3 vs T4 is acceptable because A is masked by B=F. The test set above satisfies masking MC/DC with N+1 = 4 test cases.

**Where MC/DC is required:**
- **DO-178C Level A**: Catastrophic failure condition software in avionics (MC/DC is mandatory).
- **DO-178C Level B**: Hazardous failure condition software (decision coverage is required; MC/DC is not mandatory but often applied).
- **NASA Class A software**: When following DO-178C guidance (common for flight software), MC/DC applies.
- **ISO 26262 ASIL D**: MC/DC is "highly recommended" for the highest automotive safety integrity level.

**The coverage hierarchy (from least to most rigorous):**
1. Statement coverage — every statement executed at least once
2. Branch/decision coverage — every branch taken in both directions
3. Condition coverage — every boolean sub-expression evaluated both true and false
4. Condition/decision coverage — combines 2 and 3
5. **MC/DC** — adds the independence requirement
6. Multiple condition coverage — all combinations (exponential; usually impractical)

MC/DC provides near-multiple-condition rigor with linear (not exponential) test case growth — for N conditions, you need N+1 test cases minimum, versus 2^N for full multiple condition coverage. This is why it was chosen as the practical ceiling for safety-critical testing.

#### 1.4.1 MC/DC Applied: API Auth Gate Example

The abstract `(A && B) || C` example hides the practical value. Here is MC/DC applied to a real API authorization decision:

```
allow = tokenValid && !expired && ipAllowed && !rateLimited
```

This is a pure AND gate with 4 conditions. Brute-force would require 2^4 = 16 tests. MC/DC requires only N+1 = 5:

| # | tokenValid | !expired | ipAllowed | !rateLimited | allow | Proves |
|---|:---:|:---:|:---:|:---:|:---:|---|
| 1 | T | T | T | T | **T** | baseline — all guards pass |
| 2 | **F** | T | T | T | **F** | bad token alone blocks |
| 3 | T | **F** | T | T | **F** | expiry alone blocks |
| 4 | T | T | **F** | T | **F** | wrong IP alone blocks |
| 5 | T | T | T | **F** | **F** | rate limit alone blocks |

Each test flips exactly one condition against the baseline. If the outcome changes (T→F), that condition independently affects the decision.

**What MC/DC skips — and why that's OK (mostly):**

The 11 missing test cases are all combinations where **multiple conditions are false simultaneously** (e.g., bad token AND expired AND wrong IP). MC/DC skips these because the outcome is already determined — if one false guard blocks the request, two false guards also block it. For a pure AND gate, there are no interaction effects. You've proved each guard independently matters; multiple failures can't produce a surprise outcome.

**Where this breaks down:** For complex expressions with mixed AND/OR/nesting — e.g., `(tokenValid && !expired) || isAdmin` — MC/DC can miss interaction effects between sub-expressions. In practice this rarely matters for correctness, but it is a real theoretical gap compared to full multiple-condition coverage.

#### 1.4.2 Choosing the Baseline (Independence Pairs)

For a pure AND gate, the baseline is obvious: all conditions true (the only way to produce `true`). But MC/DC is not actually "pick a happy path and mutate." The formal requirement is to find **independence pairs** — pairs of test cases where:
- Exactly one condition differs
- The decision outcome differs

For mixed logic, there are multiple paths to `true`, so you need multiple baselines:

```
allow = (tokenValid && !expired) || isAdmin
```

Paths to `true`:
- Regular user: `tokenValid=T, expired=F, isAdmin=F` → true (via left sub-expression)
- Admin: `tokenValid=F, expired=T, isAdmin=T` → true (via right sub-expression)

You need independence pairs per path:

| # | tokenValid | !expired | isAdmin | allow | Pair for |
|---|:---:|:---:|:---:|:---:|---|
| 1 | T | T | F | T | baseline for left path |
| 2 | **F** | T | F | F | tokenValid (pair with 1) |
| 3 | T | **F** | F | F | !expired (pair with 1) |
| 4 | F | F | **T** | T | — |
| 5 | F | F | **F** | F | isAdmin (pair with 4) |

This is where MC/DC tooling (automated test generation) becomes valuable — manually finding valid independence pairs for complex decisions with 8+ conditions is tedious and error-prone.

#### 1.4.3 Numeric and Non-Boolean Conditions: Boundary Value Analysis

MC/DC operates at the decision level, where every condition is boolean. But real conditions derive from numeric values:

```
allow = (retryCount < 5) && (latency < 3000) && tokenValid
```

The MC/DC table still looks boolean:

| # | retryCount < 5 | latency < 3000 | tokenValid | allow |
|---|:---:|:---:|:---:|:---:|
| 1 | T | T | T | T |
| 2 | **F** | T | T | F |
| 3 | T | **F** | T | F |
| 4 | T | T | **F** | F |

But you must **pick concrete values** for each T/F. This is where **boundary value analysis** (BVA) intersects with MC/DC:

| # | retryCount | latency | tokenValid | Notes |
|---|:---:|:---:|:---:|---|
| 1 | **4** | **2999** | T | just inside both boundaries |
| 2 | **5** | 2999 | T | boundary: retryCount = 5 is the first failing value |
| 3 | 4 | **3000** | T | boundary: latency = 3000 is the first failing value |
| 4 | 4 | 2999 | **F** | flip the boolean |

**The principle:** MC/DC tells you **which conditions to flip**. Boundary value analysis tells you **which values to use when flipping**. Bugs concentrate at boundaries (off-by-one errors, `<` vs `<=`, integer overflow), not in the middle of ranges. Testing `retryCount = 1` for true and `retryCount = 999` for false would satisfy MC/DC but miss the boundary bug.

For floating-point conditions, boundary values also need to account for precision. Testing `latency < 3000.0` should include values like `2999.999999` and `3000.0`, not just `1000.0` and `5000.0`.

#### 1.4.4 Coupled and Dependent Conditions

The hardest practical challenge for MC/DC is **coupled conditions** — where one condition constrains another, making certain combinations in the MC/DC table impossible.

**Example: Token validity depends on expiry**

```
allow = tokenValid && !expired && ipAllowed
```

If `tokenValid` internally checks expiry (a valid token, by definition, is not expired), then the combination `tokenValid=T, expired=T` is **impossible**. The MC/DC table requires this combination for the `expired` independence pair:

| # | tokenValid | !expired | ipAllowed | allow | Problem |
|---|:---:|:---:|:---:|:---:|---|
| 1 | T | T | T | T | baseline |
| 2 | F | T | T | F | tokenValid pair — OK |
| 3 | T | **F** | T | F | **impossible** — token can't be valid AND expired |
| 4 | T | T | F | F | ipAllowed pair — OK |

**Solutions for coupled conditions:**

1. **Find alternative independence pairs.** Instead of flipping against the all-true baseline, find a different achievable pair where only the condition of interest differs:
   - For `!expired`: use `(tokenValid=F, expired=F, ipAllowed=T) → F` vs `(tokenValid=F, expired=T, ipAllowed=T) → F` — but wait, both results are F, so this doesn't show independence. You may need to restructure.

2. **Refactor the decision logic.** If `tokenValid` already checks expiry, the `!expired` guard is redundant. Remove it:
   ```
   allow = tokenValid && ipAllowed
   ```
   This is actually a **design benefit of MC/DC** — the process of trying to construct independence pairs reveals redundant or conflicting conditions. If you can't prove a condition independently matters, maybe it doesn't, and removing it simplifies the code.

3. **Decompose into layers.** Separate the concerns:
   ```
   // Layer 1: Token state (unit tested separately)
   tokenState = checkToken(token)  // returns VALID, EXPIRED, MALFORMED, REVOKED

   // Layer 2: Authorization decision (MC/DC tested)
   allow = (tokenState == VALID) && ipAllowed && !rateLimited
   ```
   Now the conditions at the decision level are truly independent. Token state is a single enum, not a compound of correlated booleans.

4. **Accept and document.** For some coupled conditions, no alternative pair exists and refactoring isn't practical. Document that this specific condition cannot be independently demonstrated, explain why, and note what alternative testing covers it (e.g., unit tests on the sub-function).

**The broader insight:** MC/DC's requirement for condition independence is not just a testing technique — it is a **design feedback mechanism**. If constructing independence pairs is difficult, your boolean logic may have:
- Redundant conditions (simplify)
- Hidden coupling (decompose)
- Overly complex expressions (refactor into layers)

This makes MC/DC valuable beyond coverage measurement — the process of achieving it pushes code toward cleaner, more testable decision logic.

#### 1.4.5 Negated Conditions and Operator Treatment

A common question: how does MC/DC handle negated conditions like `!expired` or `!rateLimited`?

**DO-178C defines a "condition" as the smallest boolean expression containing no boolean operators.** The `!` (NOT) is a boolean operator, just like `&&` and `||`. So in:

```
allow = tokenValid && !expired && ipAllowed && !rateLimited
```

The **conditions** are: `tokenValid`, `expired`, `ipAllowed`, `rateLimited` — the raw variables. The negation operator `!` is part of the decision's structure, not part of the condition itself.

**For practical MC/DC testing, this changes nothing.** You're proving that flipping `expired` (from false to true) independently changes the outcome. Whether you think of it as "expired goes F→T" or "!expired goes T→F" — same flip, same test, same proof. The column headers in an MC/DC table can use either `expired` or `!expired` — it's a presentation choice.

**The trap to avoid:** Don't count `!expired` and `expired` as two separate conditions. It's one variable, one condition, one independence pair needed. If you see both `expired` and `!expired` appearing as seemingly separate conditions in the same decision expression, that's either:
- A redundancy (simplify the expression)
- A miscount of conditions (recount — the variable is the condition, not its appearances)

This also applies to any unary transformation: `!flag`, `isEmpty()`, `isValid()` — MC/DC treats the result as an atomic boolean condition regardless of what computation produced it. The internal complexity of evaluating `isValid()` is tested at the unit level, not at the MC/DC decision level.

#### 1.4.6 What MC/DC Does and Does Not Guarantee

**MC/DC guarantees:**
- Every condition in every decision has been shown to independently affect the outcome
- The test set is minimal (N+1 for N conditions) while still being rigorous
- No condition is "dead" (always masked by others) — if it were, you couldn't find an independence pair

**MC/DC does NOT guarantee:**
- **Correctness of condition evaluation.** MC/DC tests the *decision logic*, not the *condition implementation*. If `ipAllowed` has a bug in IPv6 parsing, MC/DC won't find it. You still need unit tests on each condition's implementation.
- **All combinations tested.** For 4 conditions, 11 of 16 combinations go untested. For pure AND/OR this is safe; for complex mixed logic, interaction effects are theoretically possible (though rare in practice).
- **Data flow correctness.** MC/DC is a structural coverage criterion for control flow. It says nothing about whether the right variable was used, whether the value was computed correctly, or whether the decision is evaluated at the right point in the program.
- **Concurrency or timing issues.** MC/DC assumes deterministic, sequential evaluation. Race conditions, timeouts, and ordering bugs require different testing approaches.

**Practical recommendation for API/backend systems:**

Apply MC/DC thinking to your highest-criticality decision points (P0 auth gates, policy engines, permission checks) where the boolean logic is the core correctness concern. Combine with:
- Boundary value analysis for numeric conditions (see 1.4.3)
- Unit tests for condition implementations (IPv6 parsing, token decoding, etc.)
- Integration tests for the end-to-end path
- Property-based / fuzz testing for unexpected input shapes

MC/DC is the **most efficient way to prove every guard in a critical decision matters** — not a silver bullet, but the sharpest tool in the structural coverage toolbox.

#### 1.4.7 Real-World Example: Applying MC/DC and FRET to a Go Middleware Function (added 2026-03-16)

This section walks through a real-world refactoring of a Go API gateway middleware function (`createMiddleware`) to make it 100% coverable by MC/DC and FRET. The original function is representative of typical backend middleware: interleaved decision logic, side effects, instrumentation, and error handling all mixed together.

##### The Problem with the Original Code

The original `createMiddleware` function (~80 lines in the HTTP handler closure) has these characteristics:

- **6 interleaved boolean decisions** controlling flow (OpenTelemetry tracing, CORS passthrough, error handling, GoPlugin suppression, instrumentation, StatusRespond bypass)
- **Decisions tangled with side effects** — logging, span creation, metrics recording, error response writing all mixed with conditional logic
- **Coupled conditions** — `err != nil` and `errCode` are coupled (errCode is only meaningful from ProcessRequest)
- **Closure-captured state** — `mwConf` captured at init time and shared across all concurrent requests

**Analysis of what MC/DC and FRET can cover in the original:**

| Aspect | Coverable? | Tool |
|---|---|---|
| Boolean decision logic (6 decisions) | ~30-40% of function | MC/DC |
| Side effect ordering (span before/after process) | ❌ | Integration tests |
| Data content (correct IP in metrics) | ❌ | Unit tests |
| Concurrent safety of closure-captured `mwConf` | ❌ | Race detector / TLA+ |
| Correct defer ordering | ❌ | Language semantics |

##### The Specific Decisions

**Decision 1: OpenTelemetry tracing**
```go
if cfg.OpenTelemetry.Enabled && baseMw.Spec.DetailedTracing
```
2 conditions, pure AND gate → 3 MC/DC tests (N+1)

**Decision 2: CORS passthrough**
```go
if mw.Base().Spec.CORS.OptionsPassthrough && r.Method == "OPTIONS"
```
2 conditions, pure AND gate → 3 MC/DC tests

**Decision 3: Error handling with GoPlugin exception**
```go
if err != nil {
    if goPlugin, isGoPlugin := actualMW.(*GoPluginMiddleware); isGoPlugin && goPlugin.handler != nil {
        writeResponse = false
    }
}
```
Outer: 1 condition (trivial). Inner: 2 conditions → 3 MC/DC tests.

**Decision 4: StatusRespond bypass**
```go
if errCode != middleware.StatusRespond { next.ServeHTTP(w, r) }
```
1 condition → 2 tests.

**Decision 5 & 6: Instrumentation and NewRelic**
Single booleans → 2 tests each.

**Total MC/DC tests for all decisions: ~16 tests.** But writing them requires mocking HTTP handlers, tracing providers, NewRelic, and instrumenting — because the decisions are entangled with side effects.

##### The Refactoring Pattern: Decide → Plan → Execute

The core insight: **decisions should produce data, not side effects.**

Refactor into three layers:

1. **Pure decision functions** — take structs in, return structs out. Zero side effects. FRET and MC/DC cover these 100%.
2. **An executor** — carries out the plan mechanically. Each line is one plan field → one action. No branching logic.
3. **An orchestrator** — gathers inputs, calls decisions, passes plan to executor. Trivial wiring.

**The Plan types:**

```go
// MiddlewarePlan is the complete output of all decision logic.
// Every field is an observable output that FRET can bind to.
type MiddlewarePlan struct {
    Trace           bool
    PassthroughCORS bool
    Process         bool
    WriteError      bool
    CallNext        bool
    UpdateSession   bool
    Instrument      bool
}

// MiddlewareInputs captures every signal the decisions depend on.
// Every field maps to a FRET Glossary Input variable.
type MiddlewareInputs struct {
    OTelEnabled          bool
    DetailedTracing      bool
    CORSPassthrough      bool
    RequestMethod        string
    InstrumentationOn    bool
    HasNewRelicTxn       bool
}

// ProcessResult captures the outcome of ProcessRequest.
// Separated because it's only available after processing.
type ProcessResult struct {
    Err              error
    ErrCode          int
    IsGoPlugin       bool
    PluginHasHandler bool
}
```

**The pure decision functions:**

```go
// PlanBeforeProcess decides everything knowable before calling ProcessRequest.
// Pure function: no side effects, no interfaces, deterministic.
func PlanBeforeProcess(in MiddlewareInputs) MiddlewarePlan {
    plan := MiddlewarePlan{
        Instrument: in.InstrumentationOn,
        Trace:      in.OTelEnabled && in.DetailedTracing,
    }
    plan.PassthroughCORS = in.CORSPassthrough && in.RequestMethod == "OPTIONS"
    plan.Process = !plan.PassthroughCORS
    if plan.PassthroughCORS {
        plan.CallNext = true
        plan.WriteError = false
        plan.UpdateSession = false
    }
    return plan
}

// PlanAfterProcess decides what to do with the ProcessRequest result.
// Pure function. Only called when plan.Process == true.
func PlanAfterProcess(plan MiddlewarePlan, result ProcessResult) MiddlewarePlan {
    hasError := result.Err != nil
    if hasError {
        plan.WriteError = !(result.IsGoPlugin && result.PluginHasHandler)
        plan.CallNext = false
        plan.UpdateSession = false
    } else {
        plan.WriteError = false
        plan.CallNext = result.ErrCode != middleware.StatusRespond
        plan.UpdateSession = true
    }
    return plan
}
```

**The executor (mechanical, no decisions):**

```go
type MiddlewareExecutor struct {
    mw        *TraceMiddleware
    mwConf    interface{}
    startTime time.Time
    span      trace.Span
    // ...
}

func (e *MiddlewareExecutor) SetupTracing(r *http.Request)    { /* creates span */ }
func (e *MiddlewareExecutor) FinalizeTracing(r *http.Request)  { /* sets attrs, ends span */ }
func (e *MiddlewareExecutor) RecordMetrics(r *http.Request)    { /* builds meta map */ }
func (e *MiddlewareExecutor) RecordTiming(meta health.Kvs)     { /* records elapsed time */ }
func (e *MiddlewareExecutor) HandleError(...)                  { /* writes error response */ }
```

**The orchestrator (wiring only):**

```go
// Inside createMiddleware's HTTP handler closure:
inputs := MiddlewareInputs{
    OTelEnabled:       cfg.OpenTelemetry.Enabled,
    DetailedTracing:   baseMw.Spec.DetailedTracing,
    CORSPassthrough:   baseMw.Spec.CORS.OptionsPassthrough,
    RequestMethod:     r.Method,
    InstrumentationOn: instrumentationEnabled,
    HasNewRelicTxn:    newrelic.FromContext(r.Context()) != nil,
}

plan := PlanBeforeProcess(inputs)       // DECIDE (pure)
exec := NewExecutor(mw, mwConf, r)

if plan.Trace { exec.SetupTracing(r); defer exec.FinalizeTracing(r) }
if plan.PassthroughCORS { next.ServeHTTP(w, r); return }

procErr, errCode := mw.ProcessRequest(w, r, mwConf)
plan = PlanAfterProcess(plan, ProcessResult{...})  // DECIDE again (pure)

if plan.WriteError { exec.HandleError(...) }
if plan.UpdateSession { mw.Base().UpdateRequestSession(r) }
if plan.CallNext { next.ServeHTTP(w, r) }
```

##### FRET Coverage of the Refactored Code

With the refactored design, FRET can model the decision functions as components:

**FRET Glossary for PlanBeforeProcess:**

| Variable | Role | Type | Mapping |
|---|---|---|---|
| `otel_enabled` | Input | boolean | `MiddlewareInputs.OTelEnabled` |
| `detailed_tracing` | Input | boolean | `MiddlewareInputs.DetailedTracing` |
| `cors_passthrough` | Input | boolean | `MiddlewareInputs.CORSPassthrough` |
| `request_method` | Input | string | `MiddlewareInputs.RequestMethod` |
| `trace` | Output | boolean | `MiddlewarePlan.Trace` |
| `passthrough_cors` | Output | boolean | `MiddlewarePlan.PassthroughCORS` |
| `call_next` | Output | boolean | `MiddlewarePlan.CallNext` |

**FRETish requirements:**

- **R1:** `When cors_passthrough is true & request_method = "OPTIONS", PlanBeforeProcess shall immediately satisfy passthrough_cors = true & call_next = true`
- **R2:** `When process_error is true, PlanAfterProcess shall immediately satisfy call_next = false`
- **R3:** `When process_error is true & (is_go_plugin = false | plugin_has_handler = false), PlanAfterProcess shall immediately satisfy write_error = true`
- **R4:** `When process_error is true & is_go_plugin is true & plugin_has_handler is true, PlanAfterProcess shall immediately satisfy write_error = false`
- **R5:** `When process_error is false & error_code = StatusRespond, PlanAfterProcess shall immediately satisfy call_next = false`
- **R6:** `When process_error is false & error_code != StatusRespond, PlanAfterProcess shall immediately satisfy call_next = true & update_session = true`
- **R7:** `When otel_enabled is true & detailed_tracing is true, PlanBeforeProcess shall immediately satisfy trace = true`

##### MC/DC Test Tables for the Refactored Code

With pure functions, MC/DC becomes trivial table-driven unit tests — zero mocks needed:

**PlanBeforeProcess MC/DC tests:**

```go
func TestPlanBeforeProcess(t *testing.T) {
    tests := []struct {
        name   string
        in     MiddlewareInputs
        expect MiddlewarePlan
    }{
        // MC/DC for Trace: OTelEnabled && DetailedTracing (3 tests)
        {"trace: both enabled",
            MiddlewareInputs{OTelEnabled: true, DetailedTracing: true},
            MiddlewarePlan{Trace: true, Process: true}},
        {"trace: otel disabled",
            MiddlewareInputs{OTelEnabled: false, DetailedTracing: true},
            MiddlewarePlan{Trace: false, Process: true}},
        {"trace: tracing disabled",
            MiddlewareInputs{OTelEnabled: true, DetailedTracing: false},
            MiddlewarePlan{Trace: false, Process: true}},

        // MC/DC for CORS: CORSPassthrough && Method==OPTIONS (3 tests)
        {"cors: passthrough + OPTIONS",
            MiddlewareInputs{CORSPassthrough: true, RequestMethod: "OPTIONS"},
            MiddlewarePlan{PassthroughCORS: true, CallNext: true, Process: false}},
        {"cors: passthrough + GET",
            MiddlewareInputs{CORSPassthrough: true, RequestMethod: "GET"},
            MiddlewarePlan{PassthroughCORS: false, Process: true}},
        {"cors: no passthrough + OPTIONS",
            MiddlewareInputs{CORSPassthrough: false, RequestMethod: "OPTIONS"},
            MiddlewarePlan{PassthroughCORS: false, Process: true}},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := PlanBeforeProcess(tt.in)
            assert.Equal(t, tt.expect, got)
        })
    }
}
```

**PlanAfterProcess MC/DC tests:**

```go
func TestPlanAfterProcess(t *testing.T) {
    base := MiddlewarePlan{Process: true, Instrument: true}
    tests := []struct {
        name   string
        result ProcessResult
        expect MiddlewarePlan
    }{
        // R6: happy path
        {"no error, normal code",
            ProcessResult{Err: nil, ErrCode: 200},
            MiddlewarePlan{Process: true, Instrument: true,
                CallNext: true, UpdateSession: true}},
        // R5: StatusRespond bypass
        {"no error, StatusRespond",
            ProcessResult{Err: nil, ErrCode: middleware.StatusRespond},
            MiddlewarePlan{Process: true, Instrument: true,
                CallNext: false, UpdateSession: true}},
        // R2 + R3: error, not go plugin → writes error
        {"error, not go plugin",
            ProcessResult{Err: errors.New("fail"), ErrCode: 500},
            MiddlewarePlan{Process: true, Instrument: true,
                WriteError: true, CallNext: false}},
        // R4: GoPlugin suppresses write
        {"error, go plugin with handler",
            ProcessResult{Err: errors.New("fail"), ErrCode: 500,
                IsGoPlugin: true, PluginHasHandler: true},
            MiddlewarePlan{Process: true, Instrument: true,
                WriteError: false, CallNext: false}},
        // MC/DC independence pair for PluginHasHandler
        {"error, go plugin WITHOUT handler",
            ProcessResult{Err: errors.New("fail"), ErrCode: 500,
                IsGoPlugin: true, PluginHasHandler: false},
            MiddlewarePlan{Process: true, Instrument: true,
                WriteError: true, CallNext: false}},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := PlanAfterProcess(base, tt.result)
            assert.Equal(t, tt.expect, got)
        })
    }
}
```

##### The Coverage Breakdown After Refactoring

| Layer | What it contains | Coverage tool | Mocks needed |
|---|---|---|---|
| **Pure decision functions** | ALL boolean logic | MC/DC + FRET (100%) | **None** — just structs |
| **Executor methods** | Side effect mechanics | Integration tests | HTTP recorder, span mock |
| **Orchestrator** | Input gathering + wiring | Integration tests | Full middleware stack |

The key wins:

| Before (original) | After (refactored) |
|---|---|
| 6 interleaved decisions inside 80-line closure | 2 pure functions, ~20 lines each |
| Decisions tangled with logging, tracing, metrics | Decisions return data, executor does effects |
| Testing requires mocking HTTP, tracing, NewRelic | Decision tests need zero mocks — just structs |
| MC/DC requires integration test harness | MC/DC is table-driven unit tests |
| FRET can model ~30-40% of behavior | FRET covers 100% of decision logic |
| Can't tell if a bug is in logic or wiring | Logic bugs → plan tests. Wiring bugs → integration tests |

##### The Architectural Insight

This refactoring pattern — **Decide → Plan → Execute** — is the same principle as FRET's component model applied at the function level:

1. **Inputs** (MiddlewareInputs, ProcessResult) = FRET Input variables
2. **Decision functions** (PlanBeforeProcess, PlanAfterProcess) = FRET component
3. **Plan struct** = FRET Output variables
4. **Executor** = outside FRET's boundary — mechanical side effects

The pattern works because it separates **what to do** (pure, testable, FRET-coverable) from **how to do it** (side effects, I/O, platform mechanics). This is the same separation that makes Lustre effective: the synchronous dataflow equations describe behavior (what), and the compilation target handles execution (how).

**Broader applicability:** This pattern applies to any complex handler function with interleaved logic and side effects — not just middleware. HTTP handlers, gRPC interceptors, queue consumers, event processors, CLI command handlers — anywhere decisions are tangled with effects, extracting a pure "plan" function makes MC/DC and FRET coverage achievable.

##### When NOT to Apply This Pattern

The Decide → Plan → Execute pattern adds a layer of indirection. It is worth the cost when:
- The decision logic is complex enough that bugs hide in it (4+ conditions, mixed AND/OR, mode-dependent behavior)
- The function is on a critical path (auth, policy, error routing)
- The side effects make testing expensive (need to mock 3+ external dependencies)

It is NOT worth it for:
- Simple guard clauses (`if err != nil { return err }`)
- Trivial forwarding functions
- Functions with one or two obvious conditions
- Code where the side effects ARE the logic (e.g., a logging function)

The test: **if writing the MC/DC table for the function is straightforward without refactoring, the function is already clean enough.**

##### The Lustre Connection: From Go to Formal Verification (added 2026-03-16)

Once the decision functions are pure, they translate directly to **Lustre nodes with CoCoSpec contracts** — enabling formal verification via Kind 2 for ALL possible inputs, not just the 11 MC/DC test cases.

**PlanBeforeProcess as Lustre:**

```lustre
node PlanBeforeProcess(
  otel_enabled: bool; detailed_tracing: bool;
  cors_passthrough: bool; is_options: bool;
  instrumentation: bool
) returns (
  trace: bool; passthrough: bool; process: bool;
  call_next: bool; instrument: bool
);
(*@contract
  -- R7: tracing requires both flags
  guarantee (otel_enabled and detailed_tracing) => trace;
  guarantee not (otel_enabled and detailed_tracing) => not trace;
  -- R1: CORS passthrough
  guarantee (cors_passthrough and is_options) => passthrough;
  guarantee (cors_passthrough and is_options) => call_next;
  guarantee (cors_passthrough and is_options) => not process;
  -- Non-passthrough means process
  guarantee not (cors_passthrough and is_options) => process;
*)
let
  trace       = otel_enabled and detailed_tracing;
  passthrough = cors_passthrough and is_options;
  process     = not passthrough;
  call_next   = passthrough;
  instrument  = instrumentation;
tel
```

**PlanAfterProcess as Lustre:**

```lustre
node PlanAfterProcess(
  has_error: bool; err_code: int;
  is_go_plugin: bool; plugin_has_handler: bool;
  STATUS_RESPOND: int
) returns (
  write_error: bool; call_next: bool; update_session: bool
);
(*@contract
  -- R2: error blocks forwarding
  guarantee has_error => not call_next;
  -- R3: error triggers response (unless GoPlugin suppresses)
  guarantee (has_error and not (is_go_plugin and plugin_has_handler)) => write_error;
  -- R4: GoPlugin suppresses response
  guarantee (has_error and is_go_plugin and plugin_has_handler) => not write_error;
  -- R5: StatusRespond bypass
  guarantee (not has_error and err_code = STATUS_RESPOND) => not call_next;
  -- R6: happy path
  guarantee (not has_error and err_code <> STATUS_RESPOND) => call_next and update_session;
*)
let
  write_error    = has_error and not (is_go_plugin and plugin_has_handler);
  call_next      = if has_error then false else err_code <> STATUS_RESPOND;
  update_session = if has_error then false else true;
tel
```

**What Kind 2 proves that MC/DC cannot:**

| Dimension | MC/DC (11 test cases) | Kind 2 (formal proof) |
|---|---|---|
| Coverage | 11 of 256 input combinations | All 256 input combinations |
| What it finds | Each condition independently matters | Contract violations in ANY state |
| Interaction effects | Can miss multi-condition interactions | Finds ALL interactions (exhaustive) |
| Realizability | Cannot check | Can the contracts even be implemented? |
| Counterexamples | Test fails → shows one bad input | Minimal counterexample trace |
| Maintenance | Add requirement → add test manually | Add guarantee → re-run, auto-checked |

**Runtime monitoring via Copilot (third layer):**

The same FRET requirements can also generate Copilot runtime monitors via Ogma. These compile to C99 constant-memory monitors that observe every request decision and fire triggers on requirement violations in production:

```haskell
-- Generated by Ogma from FRET JSON export
-- R2: error blocks forwarding
spec :: Spec
spec = do
  let processError = extern "process_error" :: Stream Bool
  let callNext     = extern "call_next"     :: Stream Bool
  trigger "r2_violation"
    (processError && callNext)  -- fires if error=true AND next=called
    []
```

**The three-layer verification strategy:**
1. **Layer 1 (CI):** MC/DC table-driven Go tests — fast feedback, 11 cases
2. **Layer 2 (Design-time):** Kind 2 proves Lustre contracts — exhaustive, all 256 states
3. **Layer 3 (Runtime):** Copilot C99 monitors from same FRET spec — production safety net

All three layers derive from the same 7 FRETish requirements. The pure function refactoring is what makes all three possible.

### 1.5 "Test as Evidence" vs. "Test as Confidence"

This is the philosophical core of the high-assurance testing mindset:

**Test as Confidence (typical commercial software):**
- Tests exist to give developers and stakeholders confidence that the software "probably works."
- Tests are written by the same team that writes the code, often after the code.
- Coverage metrics are targets to hit ("we aim for 80% coverage").
- Test failures are bugs to fix; test passes are assumed to mean correctness.
- Tests are disposable — they can be skipped, deleted, or rewritten freely.
- The test suite is a living artifact that primarily serves the development process.

**Test as Evidence (high-assurance):**
- Tests exist to **demonstrate compliance** with specific, traceable requirements.
- Each test case has a documented purpose: which requirement(s) it verifies.
- Test results are **artifacts** — they are reviewed, signed, archived, and auditable.
- A test that passes but cannot be traced to a requirement is a **gap indicator**, not a success.
- A requirement without a corresponding test (or other verification method) is a **non-compliance**.
- Tests are not disposable; they are part of the certification/qualification evidence package.
- The question is never "do we have enough tests?" but "do we have sufficient evidence for every claim?"

**Key implications for the evidence mindset:**
- **Test plans are reviewed artifacts**, not informal documents. They describe what will be tested, how, under what conditions, with what pass/fail criteria, and who will witness or review the results.
- **Test procedures are repeatable** — another person or team can execute the same test and get the same result.
- **Test results are immutable records** — once a test is executed and the result recorded, it becomes part of the evidence base. If you change the code, you re-test and create new evidence; you don't modify old results.
- **Negative testing is required** — you must demonstrate not only that the software does what it should, but that it handles what it shouldn't (invalid inputs, out-of-range values, timing violations, resource exhaustion).

### 1.6 Witnessed Testing

For NASA Class A and some Class B software, certain test activities must be **witnessed** — observed in real time by an independent party (often the IV&V team or a designated Safety and Mission Assurance representative).

Witnessed testing is not about distrust. It serves several purposes:
- **Independent confirmation** that the test was actually executed as documented.
- **Real-time identification** of anomalies that the development team might inadvertently normalize.
- **Procedural compliance** — ensures the test environment, configuration, and procedures match what was approved in the test plan.
- **Evidence chain integrity** — the witness signs off on the test results, adding another link in the evidence chain.

The aerospace equivalent in commercial software would be requiring that a security audit of authentication flows be observed by an independent security team, with the results co-signed and archived.

---

## 2. Automotive Testing — ISO 26262

### 2.1 Overview of ISO 26262 and ASIL Levels

ISO 26262 ("Road vehicles — Functional safety") is the automotive industry's functional safety standard, derived from IEC 61508. It defines four Automotive Safety Integrity Levels (ASILs):

- **ASIL A**: Lowest safety integrity level (still safety-relevant).
- **ASIL B**: Moderate.
- **ASIL C**: High.
- **ASIL D**: Highest safety integrity level — applies to systems whose failure could directly cause life-threatening situations (e.g., steering, braking).
- **QM (Quality Management)**: Non-safety-relevant; standard quality practices suffice.

ASIL is determined through hazard analysis and risk assessment, considering:
- **Severity** (S1-S3): How bad is the consequence?
- **Exposure** (E1-E4): How often is the situation encountered?
- **Controllability** (C1-C3): How controllable is the situation by the driver?

### 2.2 Part 6 — Software Testing Requirements

ISO 26262 Part 6 ("Product development at the software level") specifies testing requirements that scale with ASIL. The standard uses a recommendation notation:
- **"++"**: Highly recommended (essentially mandatory for certification).
- **"+"**: Recommended.
- **"o"**: No recommendation for or against.

#### Software Unit Testing Methods (Table 9 in Part 6):

| Method | ASIL A | ASIL B | ASIL C | ASIL D |
|--------|--------|--------|--------|--------|
| Requirements-based testing | ++ | ++ | ++ | ++ |
| Interface testing | + | ++ | ++ | ++ |
| Fault injection testing | + | + | ++ | ++ |
| Resource usage testing | + | + | + | ++ |
| Back-to-back testing | + | + | + | ++ |

#### Structural Coverage Metrics for Unit Testing (Table 10 in Part 6):

| Coverage Metric | ASIL A | ASIL B | ASIL C | ASIL D |
|-----------------|--------|--------|--------|--------|
| Statement coverage | ++ | ++ | ++ | ++ |
| Branch coverage | + | ++ | ++ | ++ |
| MC/DC | + | + | + | ++ |

**Key observations:**
- Requirements-based testing is universally mandatory across all ASIL levels.
- MC/DC is only highly recommended at ASIL D (the highest level), aligning with DO-178C's requirement of MC/DC only at the most critical level.
- Fault injection testing becomes highly recommended at ASIL C and D, reflecting the need to verify behavior under failure conditions.

### 2.3 Software Integration Testing (Part 6, Clause 10)

Integration testing in ISO 26262 verifies the correct interaction between software units and between software and hardware. Required methods include:

- **Functional and black-box testing**: Testing integrated components against their functional requirements without knowledge of internal structure.
- **Interface testing**: Verifying that data exchanged between components conforms to interface specifications (data types, ranges, timing, protocols).
- **Fault injection testing at integration level**: Injecting faults at component boundaries to verify error handling, degradation behavior, and fail-safe mechanisms.
- **Resource usage evaluation**: Verifying that integrated software stays within allocated resources (memory, CPU, communication bandwidth).

### 2.4 Back-to-Back Testing

Back-to-back testing is a powerful technique emphasized in ISO 26262 (and also used in aerospace). The concept:

1. Build a **reference model** of the expected behavior (often a Simulink/Matlab model, a formal specification, or a previous verified version).
2. Run the **same test inputs** through both the reference model and the actual software implementation.
3. Compare outputs. Any discrepancy is a potential defect.

Back-to-back testing is particularly valuable because:
- It catches implementation errors that deviate from the design model.
- It can be automated extensively, enabling large-scale regression testing.
- It provides a natural **oracle** (the model) against which to judge correctness.
- It is highly recommended at ASIL D for both unit and integration testing.

**Relevance to API platforms**: Back-to-back testing maps directly to **contract testing** and **differential testing** — running the same API requests through an old version and a new version, or through a specification model and the implementation, and comparing responses.

### 2.5 Fault Injection Testing

ISO 26262 Part 6 requires fault injection testing to verify that software handles internal and external failures correctly. Categories include:

- **Hardware fault injection**: Simulating hardware failures (memory corruption, communication loss, sensor failures) and verifying software responses.
- **Software fault injection**: Introducing defects or anomalies into software inputs, state, or execution flow.
- **Communication fault injection**: Simulating message loss, delay, corruption, or replay on communication buses.

The standard requires demonstrating that safety mechanisms detect, report, and handle faults within specified time windows. This is not optional for ASIL C and D systems.

### 2.6 Requirements-Based vs. Interface-Based vs. Fault-Injection Testing: A Unified View

ISO 26262 treats these as complementary, not alternatives:

| Approach | What It Verifies | Typical Technique |
|----------|-----------------|-------------------|
| Requirements-based | Software does what it should | Derive test cases from "shall" statements |
| Interface-based | Components interact correctly | Test boundary values, data types, timing, protocols at interfaces |
| Fault-injection | Software handles what it shouldn't | Inject errors, timeouts, corrupted data, resource exhaustion |

Together, these three approaches cover: correct behavior (requirements), correct communication (interfaces), and correct degradation (faults). A robust test strategy uses all three.

---

## 3. Property-Based Testing and Fuzzing

### 3.1 From Example-Based to Property-Based Testing

Traditional unit tests are **example-based**: the developer picks specific inputs and asserts specific outputs. This is the dominant paradigm in commercial software.

**Property-based testing** (pioneered by QuickCheck, created by Koen Claessen and John Hughes at Chalmers University, 2000) inverts this:
- Instead of specifying examples, you specify **properties** — invariants that must hold for all valid inputs.
- The framework **generates** random inputs (potentially thousands) and checks whether the property holds.
- When a property violation is found, the framework **shrinks** the failing input to the minimal reproducing case.

**Key property-based testing frameworks:**
- **QuickCheck** (Haskell, original — Claessen & Hughes, 2000)
- **Hypothesis** (Python — David R. MacIver)
- **FsCheck** (F#/.NET)
- **fast-check** (JavaScript/TypeScript)
- **Gopter / rapid** (Go)
- **PropEr** (Erlang)
- **ScalaCheck** (Scala)
- **Proptest** (Rust)

### 3.2 How Property-Based Testing Maps to High-Assurance Verification

Property-based testing provides a bridge between informal commercial testing and formal verification:

| Concept in High-Assurance | Property-Based Equivalent |
|---------------------------|--------------------------|
| Formal specification | Property definition (invariant, precondition, postcondition) |
| Exhaustive state exploration | Random + guided input generation across the input space |
| MC/DC coverage of conditions | Properties that exercise boolean logic with diverse inputs |
| Requirements-based testing | Each property corresponds to a requirement or invariant |
| Negative/robustness testing | Properties that assert correct behavior on invalid inputs |
| Test oracle | The property itself serves as the oracle |

**Critical advantage**: Property-based tests can discover edge cases that a developer would never think to write as examples. QuickCheck famously found previously unknown bugs in Ericsson's telecommunications software (Hughes, "QuickCheck Testing for Fun and Profit," 2007, Practical Aspects of Declarative Languages).

**Stateful property-based testing** (QuickCheck's state machine testing, Hypothesis's stateful testing) goes further:
- Generates random sequences of operations (not just single inputs).
- Checks invariants at each step.
- This is analogous to **model-based testing** in formal methods — defining a state machine model and checking that the implementation conforms.

### 3.3 Fuzzing as Boundary Exploration

Fuzzing generates semi-random, malformed, or unexpected inputs to find crashes, hangs, memory violations, and undefined behavior. It complements property-based testing:

| Approach | Goal | Input Strategy | Oracle |
|----------|------|---------------|--------|
| Property-based testing | Verify invariants | Random but well-typed inputs | The property assertion |
| Fuzzing | Find crashes/violations | Random, mutated, boundary inputs | Crash = failure (implicit oracle) |
| Coverage-guided fuzzing | Maximize code exploration | Mutation guided by coverage feedback | Crash, timeout, sanitizer signal |

**Key fuzzing tools:**
- **AFL / AFL++** (American Fuzzy Lop — Michal Zalewski, originally at Google): Coverage-guided binary fuzzer.
- **libFuzzer** (LLVM project): In-process, coverage-guided fuzzer.
- **go-fuzz** / **Go's built-in fuzzing** (since Go 1.18): Native fuzzing support in the Go toolchain.
- **Jazzer** (Code Intelligence): Coverage-guided fuzzing for JVM.
- **OSS-Fuzz** (Google): Continuous fuzzing infrastructure for open-source projects.
- **Atheris** (Google): Python fuzzer based on libFuzzer.

**Coverage-guided fuzzing** (AFL, libFuzzer) uses structural coverage as a feedback signal — it retains inputs that reach new code paths, effectively performing automated boundary exploration. This is structurally similar to using coverage analysis to find untested code, but automated and continuous.

### 3.4 How These Complement Traditional Tests

The high-assurance test suite combines:

1. **Requirements-based tests** (example-based): Demonstrate compliance with each requirement. These are the primary evidence artifacts.
2. **Property-based tests**: Explore the input space broadly, catching edge cases and invariant violations. These serve as **supplementary evidence** and as a tool for discovering missing requirements.
3. **Fuzzing**: Discovers inputs that cause crashes, hangs, or undefined behavior. These serve as **robustness evidence** — proof that the system handles malformed inputs gracefully.

Together, they form a complementary strategy:
- Requirements-based tests show the system does what it should (verification).
- Property-based tests show the system maintains invariants across the input space (generalized verification).
- Fuzzing shows the system does not catastrophically fail on unexpected inputs (robustness verification).

---

## 4. Runtime Verification and Monitoring

### 4.1 The Gap Between Pre-Deployment Testing and Production Reality

No matter how thorough pre-deployment testing is, it cannot anticipate every scenario the software will encounter in production. The real world introduces:
- Environmental conditions not represented in the test environment.
- Input sequences never generated during testing.
- Hardware degradation over time.
- Interactions with external systems that change independently.

Runtime verification and monitoring extend the verification mindset from "before deployment" into "during operation."

### 4.2 NASA Copilot — Runtime Verification Framework

NASA Copilot is an open-source runtime verification framework developed at NASA Langley Research Center (originally led by Lee Pike at Galois, alongside Alwyn Goodloe at NASA Langley and Ivan Perez, with further collaborators). It is implemented in Haskell and generates constant-time, constant-space C monitors that can run on embedded systems.

**Key characteristics of Copilot:**
- **Stream-based specification language**: Monitors are specified as stream transformations in Haskell, making specifications compositional and type-safe.
- **Temporal logic support**: Copilot supports past-time and future-time linear temporal logic (LTL), enabling specifications like "whenever X happens, Y must happen within N steps."
- **Hard real-time guarantees**: Generated C code runs in constant time and constant memory per step, making it suitable for flight-critical systems.
- **No dynamic memory allocation**: Critical for safety-critical embedded systems where heap allocation is typically forbidden.
- **Compilation to C99**: Monitors compile to standard C99 code that can be integrated into existing embedded systems.

**Copilot's specification model:**
```
-- Example Copilot specification (conceptual)
-- "If engine temperature exceeds threshold for 3 consecutive readings,
--  the cooling system must be active within 2 readings"
engineTempHigh = extern "engine_temp" > 500
coolingActive = extern "cooling_system_active"
sustained = engineTempHigh && prev engineTempHigh && prev (prev engineTempHigh)
requirement = always (sustained ==> within 2 coolingActive)
```

**References:**
- Perez, I., Dedden, F., Goodloe, A. (2020). "Copilot 3." NASA Technical Report.
- Pike, L., Goodloe, A., Morisset, R., Niller, S. (2010). "Copilot: A Hard Real-Time Runtime Monitor." Runtime Verification 2010, LNCS 6418.
- Repository: https://github.com/Copilot-Language/copilot

### 4.3 R2U2 — Realizable, Responsive, Unobtrusive Unit

R2U2 (developed at NASA Ames Research Center by Kristin Rozier and collaborators) is a runtime monitoring framework designed specifically for safety-critical systems, particularly unmanned aerial systems (UAS).

**Key characteristics of R2U2:**
- **FPGA-based monitoring**: R2U2 can run on FPGAs (Field-Programmable Gate Arrays), providing hardware-level monitoring that does not share computational resources with the monitored software. This eliminates the concern that the monitor could interfere with the system being monitored.
- **Mission-time Linear Temporal Logic (MLTL)**: R2U2 uses MLTL, which adds bounded temporal operators (e.g., "G[0,100]" meaning "always within the next 100 time steps"). This enables specifications with precise timing bounds.
- **Bayesian reasoning**: R2U2 includes probabilistic reasoning capabilities, allowing it to reason about uncertain sensor data and provide probabilistic verdicts.
- **Non-intrusive architecture**: The monitor observes system behavior through existing data interfaces without modifying the monitored system.

**References:**
- Reinbacher, T., Rozier, K.Y., Schumann, J. (2014). "Temporal-Logic Based Runtime Observer Pairs for System Health Management of Real-Time Systems." TACAS 2014.
- Rozier, K.Y., Schumann, J. (2017). "R2U2: Tool Overview." International Workshop on Competitions, Usability, Benchmarks, Evaluation, and Standardisation for Runtime Verification Tools (RV-CuBES).

### 4.4 The Relationship Between Offline Verification and Online Monitoring

Offline verification (testing, analysis, formal verification) and online monitoring (runtime verification) serve different but complementary roles:

| Dimension | Offline Verification | Online Monitoring |
|-----------|---------------------|-------------------|
| When | Before deployment | During operation |
| What it covers | Known scenarios and specifications | Actual operational behavior |
| Limitation | Cannot anticipate all real-world conditions | Can only check properties that are monitorable |
| Output | Pass/fail evidence for certification | Verdicts, alerts, health status |
| Cost of failure | Rework and re-test | Potential mission/safety impact; triggers mitigation |

**The synthesis:** High-assurance systems use offline verification to establish a **baseline of evidence** that the software is correct, and online monitoring to **extend that assurance** into the operational environment. Properties verified offline provide the foundation; runtime monitors watch for violations of those properties (and additional operational constraints) during execution.

**The trust model:** Offline verification gives you confidence before deployment. Runtime monitoring gives you detection during operation. Neither alone is sufficient for the highest criticality systems.

### 4.5 Runtime Monitoring in Commercial Software Context

The principles of runtime verification translate to production monitoring:

| NASA/Automotive Concept | Commercial Software Equivalent |
|------------------------|-------------------------------|
| Copilot temporal specifications | Alert rules and SLO definitions |
| R2U2 non-intrusive monitoring | Sidecar proxies, eBPF-based observability |
| MLTL bounded temporal properties | "If error rate exceeds 5% for 60 seconds, alert" |
| Runtime verdict (pass/fail/unknown) | Health check status, circuit breaker state |
| Safety monitor triggering mitigation | Automatic rollback, traffic shifting, feature flag disable |

The gap in commercial practice is typically **formality**: NASA specifies monitors in temporal logic with precise semantics; commercial teams write ad-hoc alert rules in monitoring tools. Bridging this gap means treating production monitoring rules as specifications that are reviewed, tested, and maintained with the same rigor as code.

---

## 5. Test Traceability

### 5.1 Bidirectional Traceability

Both NASA (NPR 7150.2D, SWE-134) and ISO 26262 (Part 8, Clause 6) require **bidirectional traceability**:

**Forward traceability**: From requirements to test cases to test results.
- "Requirement R-042 is verified by test case TC-042-01, which was executed on 2024-01-15 with result PASS."

**Backward traceability**: From test cases back to requirements.
- "Test case TC-042-01 verifies requirement R-042."

**Why bidirectional?**
- Forward traceability ensures every requirement has verification evidence (no gaps).
- Backward traceability ensures every test case has a purpose (no orphan tests).
- Together, they enable impact analysis: when a requirement changes, you can immediately identify which tests are affected, and vice versa.

### 5.2 The Traceability Matrix

A **Requirements Verification Traceability Matrix (RVTM)** is the standard artifact. A simplified structure:

| Req ID | Requirement Text | Verification Method | Test Case ID(s) | Test Result | Test Date | Status |
|--------|-----------------|--------------------|--------------------|-------------|-----------|--------|
| R-001 | System shall authenticate users via OAuth 2.0 | Test | TC-001-01, TC-001-02, TC-001-03 | PASS, PASS, PASS | 2024-01-15 | Verified |
| R-002 | System shall rate-limit API calls to N/minute per consumer | Test, Analysis | TC-002-01, TC-002-02, AN-002-01 | PASS, PASS, Complete | 2024-01-16 | Verified |
| R-003 | System shall fail gracefully under database unavailability | Test (Fault Injection) | TC-003-01, TC-003-02 | PASS, PASS | 2024-01-17 | Verified |
| R-004 | System shall log all access control decisions | Inspection, Test | TC-004-01, IR-004-01 | PASS, Approved | 2024-01-18 | Verified |

**Key properties of a good RVTM:**
- Every requirement has at least one verification method and evidence artifact.
- Status is explicitly tracked (Not Started / In Progress / Verified / Waived with justification).
- The matrix is maintained as a living document throughout development, not created retroactively.
- Changes to requirements trigger updates to the matrix and re-verification.

### 5.3 The Test Evidence Pack

A **test evidence pack** (also called a "verification evidence package" or "qualification data package") is the complete collection of artifacts that demonstrate the software has been verified. In aerospace (DO-178C) and automotive (ISO 26262), this pack is a deliverable artifact. Its contents typically include:

**1. Test Plan**
- Scope of testing (what will and will not be tested).
- Test strategy (types of testing, tools, environments).
- Entry and exit criteria (when testing starts, when it is considered complete).
- Test environment description (hardware, OS, compilers, tool versions — everything needed to reproduce).

**2. Test Cases and Procedures**
- Each test case: ID, purpose, preconditions, inputs, expected outputs, pass/fail criteria.
- Each test procedure: step-by-step instructions for executing the test.
- Traceability to requirements.

**3. Test Results**
- For each test case: actual results, pass/fail determination, date, tester, test environment configuration.
- For automated tests: test execution logs, tool output.
- For witnessed tests: witness signature and date.

**4. Structural Coverage Analysis**
- Coverage report showing what was covered.
- Analysis of any gaps (unreached code justified as dead code, deactivated code, or identified as needing additional test cases or requirements).

**5. Problem/Anomaly Reports**
- Any anomalies discovered during testing, their disposition (fixed, deferred, waived with rationale).
- Evidence that fixes were re-verified.

**6. Test Environment Qualification**
- Evidence that test tools (compilers, test frameworks, simulators) are trustworthy and produce correct results.
- DO-178C Section 12.2 requires tool qualification for tools whose output is trusted without independent checking.

**7. Traceability Matrix**
- The complete RVTM demonstrating full verification coverage.

### 5.4 Building Traceability in Modern Software Projects

Modern tools and practices that support traceability:

- **Requirements management tools**: Jira (with traceability plugins), IBM DOORS, Polarion, Helix RM. These tools maintain requirements hierarchies and link to test cases.
- **Test case management**: TestRail, Zephyr, qTest. These tools link test cases to requirements and record results.
- **Annotation-based traceability**: Embedding requirement IDs in test code as tags/annotations:
  ```go
  // @verifies R-042 "System shall return 429 when rate limit exceeded"
  func TestRateLimitExceeded(t *testing.T) { ... }
  ```
- **CI/CD integration**: Automated extraction of traceability data from test results, generating RVTM reports as part of the CI pipeline.
- **Git-based traceability**: Using commit messages and PR descriptions to link code changes to requirements, creating an auditable chain from requirement to code to test to deployment.

---

## 6. Practical Application to API Platforms

### 6.1 Testing Auth Flows as Safety-Critical Paths

Authentication and authorization are the **safety-critical paths** of an API platform. Failure in auth flows can lead to:
- Unauthorized data access (confidentiality breach).
- Privilege escalation (integrity breach).
- Service disruption through authentication bypass or token abuse (availability breach).

**Applying the evidence mindset to auth testing:**

1. **Enumerate auth requirements explicitly** — not just "auth works" but specific requirements:
   - R-AUTH-001: "The system shall reject requests with expired JWT tokens with HTTP 401."
   - R-AUTH-002: "The system shall reject requests with tokens signed by unknown keys with HTTP 401."
   - R-AUTH-003: "The system shall enforce scope-based access control per the policy configuration."
   - R-AUTH-004: "The system shall not cache authorization decisions for longer than N seconds."
   - R-AUTH-005: "The system shall rate-limit failed authentication attempts to M per minute per source IP."

2. **Map each requirement to test cases** — with both positive and negative tests:
   - TC-AUTH-001-01: Submit request with expired token; verify 401 response.
   - TC-AUTH-001-02: Submit request with token expiring in 1 second; wait 2 seconds; verify 401.
   - TC-AUTH-002-01: Submit request with token signed by valid key; verify acceptance.
   - TC-AUTH-002-02: Submit request with token signed by unknown key; verify 401.
   - TC-AUTH-002-03: Submit request with token signed by revoked key; verify 401.

3. **Add property-based tests for auth logic:**
   - Property: "For any valid JWT with scope X, access is granted to all endpoints requiring scope X and denied for all endpoints requiring other scopes."
   - Property: "For any expired JWT, regardless of claims, the system returns 401."

4. **Add fuzzing for auth parsing:**
   - Fuzz the JWT parser with malformed tokens, truncated tokens, tokens with incorrect encoding, oversized tokens.
   - Fuzz the OAuth flow endpoints with malformed redirect URIs, state parameters, authorization codes.

5. **Create a traceability matrix for auth requirements** — this becomes the "auth verification evidence pack."

### 6.2 Contract Testing for API Compatibility

Contract testing verifies that API providers and consumers agree on the interface. This maps directly to **interface testing** in ISO 26262.

**Tools and approaches:**
- **Pact**: Consumer-driven contract testing. Consumers define expected interactions; providers verify they satisfy those expectations. Each contract is a testable artifact.
- **OpenAPI/Swagger specification testing**: Using the API specification as a contract, testing that the implementation conforms (tools: Schemathesis, Dredd, committee gem).
- **gRPC/Protobuf contracts**: Protocol buffer definitions serve as machine-verifiable contracts. Tools like `buf` can detect breaking changes.
- **Schemathesis** (particularly relevant): Generates test cases from OpenAPI specifications using property-based testing — it is essentially property-based testing applied to API contracts. Schemathesis discovers specification violations, crashes, and consistency issues automatically.

**Mapping to high-assurance concepts:**
- The API specification (OpenAPI, gRPC, GraphQL schema) is the **requirement specification**.
- Contract tests are **requirements-based tests** — they verify the implementation against the specification.
- Breaking change detection is **regression verification** — ensuring that changes do not violate previously verified behavior.
- Consumer-driven contracts provide **bidirectional traceability**: consumers specify what they need, providers verify they deliver it.

### 6.3 Shadow/Differential Testing for Policy Engines

Policy engines (authorization policies, rate limiting rules, routing rules) are analogous to **decision logic** in safety-critical systems. Testing them requires:

**Shadow testing (also called dark launching):**
- Route production traffic through both the old and new policy engine.
- Compare decisions from both engines.
- Log discrepancies without affecting production behavior.
- This is directly analogous to **back-to-back testing** in ISO 26262.

**Differential testing:**
- Maintain a reference implementation (a "model") of the policy logic.
- Run the same inputs through both the model and the production engine.
- Any discrepancy indicates a potential defect.
- The reference model can be simpler (e.g., a Python script implementing the policy rules) while the production engine is optimized (e.g., compiled OPA/Rego policies).

**Property-based testing for policies:**
- Property: "If user has role Admin, access is granted to all admin endpoints."
- Property: "Rate limiting is monotonic — increasing the request count never decreases the remaining quota."
- Property: "Policy evaluation is deterministic — the same input always produces the same decision."
- Property: "Adding a more permissive rule never reduces access (or: the policy is monotonically permissive with rule addition)."

### 6.4 Chaos/Fault Injection for Resilience

Fault injection for API platforms maps directly to ISO 26262's fault injection testing requirements:

| Fault Category | Example Injections | What It Verifies |
|---------------|-------------------|-----------------|
| Network faults | Latency injection, packet loss, DNS failure, TLS handshake timeout | Timeout handling, retry logic, circuit breaking |
| Dependency faults | Database unavailability, cache failure, auth service timeout | Graceful degradation, fallback behavior, error propagation |
| Resource faults | Memory pressure, CPU saturation, file descriptor exhaustion, disk full | Resource limit handling, OOM behavior, backpressure |
| Data faults | Malformed responses from upstream, unexpected JSON schemas, encoding errors | Parsing resilience, schema validation, error responses |
| Configuration faults | Invalid configuration, partial configuration, conflicting rules | Configuration validation, safe defaults, startup checks |

**Tools:**
- **Chaos Monkey / Simian Army** (Netflix): Random instance termination.
- **Gremlin**: Commercial fault injection platform.
- **Toxiproxy** (Shopify): TCP proxy that simulates network conditions.
- **Chaos Mesh**: Kubernetes-native chaos engineering platform.
- **LitmusChaos**: Kubernetes chaos engineering framework.
- **tc (Linux traffic control)**: Network latency and packet loss injection.

**The evidence connection:** In a high-assurance context, chaos tests are not "we ran Chaos Monkey and things seemed fine." They are:
- Documented fault injection scenarios, each tied to a resilience requirement.
- Expected behavior under each fault (defined before the test).
- Actual behavior recorded and compared against expectations.
- Pass/fail determination with evidence artifacts.

### 6.5 Coverage Metrics That Matter Beyond Line Coverage

Line coverage is the crudest coverage metric. For API platforms, more meaningful coverage dimensions include:

**1. Requirements Coverage**
- What percentage of requirements have at least one test? (Target: 100%)
- What percentage have both positive and negative tests?

**2. API Surface Coverage**
- What percentage of API endpoints have tests?
- What percentage of request/response schemas have been exercised?
- What percentage of error codes have been triggered and verified?

**3. Configuration Coverage**
- What percentage of configuration options have been tested?
- Have default values been tested? Non-default values? Boundary values?
- Have configuration combinations been tested (pairwise at minimum)?

**4. Failure Mode Coverage**
- What percentage of identified failure modes have fault injection tests?
- What percentage of error handling paths have been exercised?
- What percentage of circuit breaker states have been reached in testing?

**5. Decision Coverage for Policy Logic**
- Branch coverage of policy evaluation paths.
- MC/DC for complex policy rules (e.g., "if (isAdmin AND hasScope) OR isServiceAccount AND NOT isBlocked").

**6. Integration Coverage**
- What percentage of inter-service communication paths have integration tests?
- What percentage of external dependency interactions have been tested (including failure modes)?

---

## 7. The Testing Pyramid in a High-Assurance Context

### 7.1 The Traditional Testing Pyramid

The traditional testing pyramid (popularized by Mike Cohn in "Succeeding with Agile," 2009) has three layers:

```
        /  E2E Tests  \          (few, slow, expensive)
       / Integration    \        (moderate number)
      /   Unit Tests     \       (many, fast, cheap)
     ----------------------
```

The principle: have many fast unit tests at the base, fewer integration tests in the middle, and a small number of slow end-to-end tests at the top.

### 7.2 The High-Assurance Testing Diamond

When you add formal verification, property-based tests, runtime monitors, and evidence requirements, the shape changes. It becomes more of a **diamond** or **hexagon**:

```
              Runtime Monitors
             /                \
            / Property-Based   \         (continuous, production)
           /   Tests & Fuzzing  \        (broad exploration)
          / Requirements-Based   \       (evidence artifacts)
         /   Integration Tests    \      (interface verification)
        /     Unit Tests           \     (foundation)
       /  Static Analysis & Formal  \    (pre-test verification)
      --------------------------------
```

**Layer-by-layer description:**

**Layer 0: Static Analysis and Formal Methods (foundation, before any test runs)**
- Static analysis tools catch defects without executing code (e.g., `go vet`, `staticcheck`, Coverity, Polyspace, SPARK/Ada provers, Frama-C).
- Formal verification proves properties mathematically (e.g., TLA+ for distributed system design, Alloy for data model verification, CBMC for bounded model checking of C code).
- Type systems serve as lightweight formal verification (Go's type system, Rust's ownership system, TypeScript's structural types).
- **Evidence produced**: Analysis reports, formal proof artifacts, static analysis clean reports.

**Layer 1: Unit Tests (same as traditional, but with traceability)**
- Each unit test traces to a requirement.
- Structural coverage is measured and analyzed (not just reported).
- Negative tests and boundary tests are explicitly required, not optional.
- **Evidence produced**: Unit test results, coverage reports, traceability matrix entries.

**Layer 2: Integration Tests (same as traditional, but with interface and fault focus)**
- Interface testing verifies data exchange at component boundaries.
- Fault injection at integration points verifies error handling.
- Back-to-back testing validates implementation against models.
- **Evidence produced**: Integration test results, interface coverage reports.

**Layer 3: Requirements-Based Tests (explicit verification of each requirement)**
- This layer may overlap with unit and integration tests, but the distinguishing factor is **explicit traceability**: each test exists because a specific requirement demands it.
- Acceptance tests at this layer are the primary evidence artifacts.
- **Evidence produced**: RVTM, test evidence pack.

**Layer 4: Property-Based Tests and Fuzzing (broad exploration)**
- Property-based tests explore the input space beyond what example-based tests cover.
- Fuzzing discovers edge cases and robustness issues.
- These feed back into the requirements and test case layers — when a property-based test finds a bug, it indicates either a missing requirement or a missing test case, which should be added to the evidence base.
- **Evidence produced**: Property violation reports, fuzz finding reports, new test cases derived from findings.

**Layer 5: Runtime Monitors (continuous, post-deployment verification)**
- Runtime monitors watch for requirement violations during operation.
- Health checks verify system invariants continuously.
- SLO monitoring tracks aggregate quality metrics.
- Anomaly detection identifies unexpected behavior patterns.
- **Evidence produced**: Monitoring reports, SLO compliance records, incident-triggered re-verification records.

### 7.3 Key Differences from the Traditional Pyramid

| Dimension | Traditional Pyramid | High-Assurance Diamond |
|-----------|-------------------|----------------------|
| Purpose of testing | Find bugs, gain confidence | Produce evidence of compliance |
| Test documentation | Informal or in-code | Formal test plans, procedures, results |
| Coverage analysis | Metric to optimize (target 80%) | Diagnostic tool for requirements completeness |
| Negative testing | Nice to have | Mandatory per requirement |
| Traceability | Optional | Mandatory, bidirectional |
| Static analysis | Linting, best practice | Pre-test verification layer, results archived |
| Runtime monitoring | Operations concern | Verification extension, part of assurance case |
| Test results | CI dashboard | Archived evidence artifacts |
| Regression scope | Changed code + related | Full re-verification of affected requirements |
| Who reviews tests | Development team | Independent review (potentially IV&V) |

### 7.4 Practical Adoption Path

Teams do not need to jump to full high-assurance practices overnight. A practical adoption path:

**Phase 1 — Establish traceability foundations:**
- Define explicit requirements for critical paths (auth, data integrity, billing).
- Tag test cases with requirement IDs.
- Generate a basic RVTM, even if initially sparse.

**Phase 2 — Add property-based testing for critical logic:**
- Identify policy engines, parsers, data transformers, and auth logic.
- Write properties that capture business invariants.
- Use Gopter/rapid (Go) or Hypothesis (Python) to run property-based tests in CI.

**Phase 3 — Introduce fault injection testing:**
- Define resilience requirements (timeouts, fallbacks, circuit breakers).
- Use Toxiproxy or Chaos Mesh to inject faults in integration tests.
- Record results as evidence against resilience requirements.

**Phase 4 — Formalize coverage analysis:**
- Stop treating coverage as a target number.
- Start treating gaps as diagnostic signals — uncovered code triggers the question: "Is there a missing requirement, a missing test, or dead code?"

**Phase 5 — Extend into runtime:**
- Define SLOs as formal requirements.
- Treat monitoring alerts as runtime specifications (similar to Copilot's temporal logic).
- When production incidents occur, trace back to requirements: was this covered? Should it have been?

---

## 8. AI, Auto-Generated Code, and the Identity of Engineering

### 8.1 The Precedent: Auto-Generated Code in Aerospace

The current anxiety about AI replacing software engineers has a direct historical precedent: the introduction of automated code generation in aerospace during the 1990s–2000s.

**What happened:** SCADE (Safety-Critical Application Development Environment) and Simulink/MathWorks introduced tools that auto-generate C code from visual models. GN&C (Guidance, Navigation & Control) engineers could design control systems as block diagrams in Simulink, and SCADE would produce DO-178C certified C code automatically. The code generator itself was formally verified — it guaranteed the generated C faithfully implements the Simulink model.

**What the industry feared:** "Machines are writing our code. Engineers will be replaced."

**What actually happened:**

| What changed | What did NOT change |
|---|---|
| GN&C engineers stopped writing C by hand — they design visually in Simulink | Flight software engineers STILL write C/C++ by hand (Mars rovers, Orion, JWST) |
| New roles emerged: requirements engineers, IV&V specialists, verification architects | Quality did not drop — it increased (auto-generated code eliminates translation errors) |
| Engineers moved from "code producer" to "system designer + verifier" | Regulators did not accept "the tool wrote it" — human accountability remained |
| The mechanical part of engineering (translating equations to C) was automated | The judgment part (what to build, how to verify, what risks exist) remained human |

**The key lesson:** Auto-generation did not eliminate engineers. It split the field: some moved to higher-level design (visual programming in Simulink), others stayed hands-on but with better tooling and verification. Both paths required MORE expertise, not less — expertise in system design, formal requirements, and verification, rather than expertise in typing C syntax.

### 8.2 AI Is Doing the Same Thing Now

AI code assistants (Copilot, ChatGPT, Claude) are automating a different layer: not just translating equations to C, but generating code from natural language descriptions. The parallel to SCADE is striking:

| SCADE/Simulink (1990s-2000s) | AI Code Assistants (2020s) |
|---|---|
| Auto-generates C from visual block diagrams | Auto-generates code from natural language |
| Output is deterministic and reproducible | Output is non-deterministic — different each time |
| Code generator is formally verified (DO-178C certified) | No formal guarantee of output correctness |
| Traceability: block diagram → generated C (1:1 mapping) | No traceability: prompt → generated code (opaque) |
| Used for a specific domain (control algorithms) | Used for everything |
| Engineer designs the system, tool produces the code | Engineer describes intent, tool produces the code |

The critical difference: SCADE's code generator is certified and deterministic. AI assistants are neither. This means AI-generated code requires MORE verification, not less — the opposite of what happened with SCADE where the certified generator reduced the verification burden.

### 8.3 The Engineer's Value Was Never in Typing Syntax

What AI replaces:

- Writing boilerplate code
- Generating test scaffolding
- Drafting documentation
- Pattern-matching known solutions
- Speed of initial production

What AI cannot replace:

- **Deciding WHAT to build** — classifying risk, understanding consequences, choosing architecture
- **Specifying requirements precisely** — writing SRS requirements that machines can check
- **Proving correctness** — building the evidence chain (MC/DC tests, Kind 2 proofs, traceability matrices)
- **Taking accountability** — signing off that the system is safe for its intended use
- **Independent judgment** — IV&V, code review, architectural decisions

**The value shift:** AI makes code production nearly free. But trust — verified, traceable, independently reviewed evidence that the system works correctly — is still expensive. The engineer's value was always in trust production, not code production. AI just made this distinction visible.

### 8.4 Implications for Banking and Regulated Industries

For teams working with banks, financial institutions, and other regulated industries, this reframing is especially important:

1. **Regulators require human accountability.** The FSA, PRA, OCC, and ECB will never accept "the AI wrote it" as evidence of correctness. Someone must classify the risk, review the output, and sign off with their name. That someone is the engineer.

2. **AI amplifies the need for verification skills.** The more AI-generated code enters financial systems, the more you need engineers who can verify, test, and prove that code is correct. MC/DC testing, formal requirements, traceability — these skills become MORE valuable, not less.

3. **The SRS/FRET framework applies directly.** Financial software has regulatory requirements (Basel III, SOX, PCI-DSS, DORA) that map to SRS requirements. FRET-style formalization can make compliance requirements verifiable. The four verification methods (Test, Analysis, Inspection, Demonstration) map to banking audit practices.

4. **Auto-generated code is not new — the governance is.** Banks already use code generators (ORM tools, API scaffolding, protocol buffers). AI is just a more powerful and less predictable code generator. The same governance applies: classify the risk of the generated code, verify it against requirements, maintain traceability, get independent review for critical paths.

---

## References

### NASA Standards and Documents
- **NPR 7150.2D** — NASA Software Engineering Requirements. NASA Procedural Requirements, current revision. Governs all NASA software development.
- **NASA-STD-8739.8** — Software Assurance and Software Safety Standard. Defines assurance requirements for NASA software.
- **NASA-HDBK-2203** — NASA Software Engineering Handbook. Guidance document for implementing NPR 7150.2.
- **NASA-GB-8719.13** — NASA Software Safety Guidebook.
- **NASA IV&V Facility** — Independent Verification and Validation facility, Fairmont, WV.

### Aerospace Standards
- **DO-178C** — "Software Considerations in Airborne Systems and Equipment Certification." RTCA, 2011. The primary standard for airborne software.
- **DO-178C Section 6.4** — Structural coverage analysis requirements.
- **DO-330** — "Software Tool Qualification Considerations." Companion document to DO-178C for tool qualification.
- **DO-333** — "Formal Methods Supplement to DO-178C and DO-278A." Guidance for using formal methods in lieu of or in addition to testing.

### Automotive Standards
- **ISO 26262:2018** — "Road vehicles — Functional safety." 12-part standard.
- **ISO 26262-6:2018** — "Product development at the software level." Part 6 covers software testing requirements, Tables 9-12.
- **ISO 26262-8:2018** — "Supporting processes." Part 8 covers configuration management, documentation, and traceability (Clause 6).

### MC/DC
- Chilenski, J.J., Miller, S.P. (1994). "Applicability of Modified Condition/Decision Coverage to Software Testing." Software Engineering Journal, 9(5), 193-200. The foundational MC/DC paper.
- Hayhurst, K.J., Veerhusen, D.S., Chilenski, J.J., Rierson, L.K. (2001). "A Practical Tutorial on Modified Condition/Decision Coverage." NASA/TM-2001-210876. Excellent tutorial with worked examples.

### Runtime Verification
- Pike, L., Goodloe, A., Morisset, R., Niller, S. (2010). "Copilot: A Hard Real-Time Runtime Monitor." Proceedings of Runtime Verification 2010, LNCS 6418.
- Perez, I., Dedden, F., Goodloe, A. (2020). "Copilot 3." NASA Technical Report.
- Reinbacher, T., Rozier, K.Y., Schumann, J. (2014). "Temporal-Logic Based Runtime Observer Pairs for System Health Management of Real-Time Systems." TACAS 2014.
- Rozier, K.Y., Schumann, J. (2017). "R2U2: Tool Overview." RV-CuBES Workshop.
- GitHub: https://github.com/Copilot-Language/copilot

### Property-Based Testing
- Claessen, K., Hughes, J. (2000). "QuickCheck: A Lightweight Tool for Random Testing of Haskell Programs." Proceedings of ICFP 2000.
- Hughes, J. (2007). "QuickCheck Testing for Fun and Profit." Practical Aspects of Declarative Languages, LNCS 4354.
- MacIver, D.R. et al. (2019). "Hypothesis: A new approach to property-based testing." Journal of Open Source Software.
- Arts, T., Hughes, J., Johansson, J., Wiger, U. (2006). "Testing telecoms software with Quviq QuickCheck." Erlang Workshop 2006.

### Fuzzing
- Zalewski, M. "American Fuzzy Lop (AFL) Technical Details." http://lcamtuf.coredump.cx/afl/technical_details.txt
- Serebryany, K. (2017). "OSS-Fuzz — Google's continuous fuzzing service for open source software." USENIX Security.
- Go Fuzzing: https://go.dev/doc/security/fuzz/

### Testing Methodology
- Cohn, M. (2009). "Succeeding with Agile: Software Development Using Scrum." Addison-Wesley. (Origin of the testing pyramid.)
- Beizer, B. (1990). "Software Testing Techniques." 2nd ed. Van Nostrand Reinhold. Classic reference on test design techniques.
- Myers, G.J., Sandler, C., Badgett, T. (2011). "The Art of Software Testing." 3rd ed. Wiley.

### Contract Testing
- Pact Foundation: https://pact.io/ — Consumer-driven contract testing.
- Schemathesis: https://github.com/schemathesis/schemathesis — Property-based API testing from OpenAPI specs.
- Zaljic, D. (2023). "Schemathesis: Property-Based Testing for APIs."

### Chaos Engineering
- Basiri, A., Behnam, N., de Rooij, R., et al. (2016). "Chaos Engineering." IEEE Software, 33(3).
- Rosenthal, C., Jones, N. (2020). "Chaos Engineering: System Resiliency in Practice." O'Reilly Media.

Yes — here’s a deck draft you can almost drop into slides.

I’d frame it as a **16-slide / 20–25 minute talk** with one thesis:

> **NASA’s real lesson is not “use pictures instead of code.”
> It is “make function, sequence, interfaces, criticality, and risk explicit before implementation.”**

## Slide 1 — Title

**On slide**

* **Behavior Before Code**
* *What NASA’s FFBD-to-MBSE mindset can teach modern software teams*
* Case lens: **a Go API management platform**

**Speaker notes**
Open with this: *“This is not a talk about aerospace nostalgia. It is a talk about how complex systems fail when behavior stays implicit until integration, and how diagram-first thinking can reduce that risk.”*

**Visual**
A clean title slide with one simple visual motif: a functional flow on the left transforming into a modern system model on the right.

---

## Slide 2 — Drawings, models, and generated code are not the same thing

**On slide**

* **Drawings** = communicate and review intent
* **Models** = capture behavior, interfaces, traceability
* **Generated code** = optional downstream automation

**Speaker notes**
A lot of people collapse these into one thing. That is the first mistake. NASA-style practice spans all three. Sometimes diagrams are just design-control artifacts. Sometimes models are the engineering source of truth. Sometimes code is auto-generated from those models — but when that happens, NASA explicitly requires tool V&V, configuration control, allowed scope, equivalent verification for generated code, rules for manual edits, and access to the source models. Modern NASA MBSE guidance is tool-agnostic and focuses on extracting diagrams and tables from the system model to support engineering work products and reviews. ([nodis3.gsfc.nasa.gov][1])

**Visual**
Three stacked layers: **diagram → model → implementation**.

---

## Slide 3 — What FFBD actually is

**On slide**

* Function-first, not component-first
* Time-sequenced view of **what** the system must do
* Useful for nominal, contingency, startup/shutdown, ops procedures
* Decomposes top-level behavior into lower-level functions

**Speaker notes**
NASA defines an FFBD as a block diagram that defines system functions and the time sequence of functional events. In the Systems Engineering Handbook, logical decomposition is about creating detailed functional requirements — the “what” to be achieved — and functional analysis is described as the primary method used in system architecture development and requirement decomposition. In other words, FFBD is not “box drawing for its own sake”; it is one way of forcing the team to agree on behavior before arguing about implementation. ([NASA][2])

**Visual**
One top-level function decomposed across 2–3 levels.

---

## Slide 4 — Which diagram answers which question?

**On slide**

* **FFBD** → What happens next?
* **EFFBD** → What control/data flow and concurrency make it happen?
* **N²** → Who exchanges what with whom?
* **State machine** → What modes/states can the system occupy?
* **SysML / MBSE** → How do all these views stay consistent?

**Speaker notes**
This is the slide that prevents diagram confusion. NASA’s glossary defines EFFBD as a block diagram representing control flows and data flows as well as system functions and flow. Modern NASA guidance also treats model-based views as extractable artifacts from a shared model, not isolated diagrams. So the mature question is never “should we use diagrams?” It is “which view answers the uncertainty we actually have?” ([NASA][3])

**Visual**
A 5-row matrix: **artifact / question answered / best use**.

---

## Slide 5 — When FFBD is exactly the right tool

**On slide**

* Early **ConOps** and scenario definition
* **Logical decomposition** and requirement breakdown
* Cross-team design reviews before architecture hardens
* Operational procedure redesign when behavior changes
* Only where ambiguity is expensive

**Speaker notes**
NASA’s SysML handbook describes ConOps as the high-level concept of how the system will be used, usually in a time-sequenced manner. The Systems Engineering Handbook says logical decomposition creates the detailed functional requirements and that functional analysis is the primary method for decomposition. It also notes that additional logical decomposition can occur during operations, especially for procedures and user interfaces. So FFBD is not just an early concept artifact; it can return whenever the team needs to reason about behavior over time. ([standards.nasa.gov][4])

**Visual**
Lifecycle ribbon: **ConOps → decomposition → design review → ops updates**.

---

## Slide 6 — From classical diagrams to digital engineering

**On slide**

* Same philosophy, newer tooling
* From **document-centric** to **data-centric**
* From one-off diagrams to **generated views**
* From local artifacts to a **digital thread**

**Speaker notes**
This is where you bridge the old and the modern. NASA’s Digital Engineering work explicitly says the agency is moving from a primarily document-centric practice to a data-centric practice of engineering. NASA-HDBK-1009A says the modeling approach is tool-agnostic and that diagrams and tables can be generated from the system model to support reviews and informed management decisions. So the modern version of “draw it first” is not a static picture deck. It is a living model that can emit the right view for the right audience. ([NASA Technical Reports Server][5])

**Visual**
Timeline: **FFBD / N² → Stateflow / Simulink → SysML / MBSE / Digital Engineering**.

---

## Slide 7 — NASA examples that make this real

**On slide**

* **Deep Space 1 / Deep Impact**: Remote Agent autonomous planning (DS1); Stateflow auto-coding for fault protection (Deep Impact)
* **Orion GN&C**: Simulink graphical design + autocode
* **Mars Ascent Vehicle**: N² for interfaces, then formal traceability

**Speaker notes**
Deep Space 1 is notable for its Remote Agent experiment — one of the first autonomous planning and execution systems flown on a spacecraft. Deep Impact (Benowitz 2006) was the mission that used Stateflow auto-coding for fault protection; those statecharts were drawn in Stateflow and then post-processed into flight code. Orion GN&C used a model-based process in Simulink with automatic C generation via Embedded Coder. The Mars Ascent Vehicle work is especially good for your talk because it shows a modern hybrid practice: initial N² interface definition in Excel, then a move into MagicDraw and related interface views because untraced interface information quickly became inconsistent across artifacts. ([Modern Embedded Software | Quantum Leaps][6])

**Visual**
Three mini-case columns with “artifact used / purpose / lesson learned”.

---

## Slide 8 — Orion proves the “modern design” point

**On slide**

* Needed modeling standards, not just tools
* Reviewed **models**, not only code
* Model tests covered:

  * design requirements
  * MC/DC / coverage
  * error handling
  * limits / boundaries

**Speaker notes**
Orion is the modern anchor for the presentation. NASA/JSC material says the GN&C team developed flight software in the Simulink graphical design environment, automatically generated C code via Embedded Coder, and had to create aerospace-specific modeling standards. The same material says detailed inspections were performed on the models, not the autocode, and that model unit testing included design requirements, coverage, error handling, and limit/boundary criteria. That is a powerful lesson: the review center of gravity can move upstream, from code-only inspection to behavior-model inspection. ([NASA Technical Reports Server][7])

**Visual**
A pipeline: **requirements → model → model review → autocode → integration**.

---

## Slide 9 — Criticality: why some functions deserve heavier rigor

**On slide**

* Not all software is equally critical
* Hazard analysis identifies the dangerous parts
* Critical software needs:

  * known safe states
  * safe transitions
  * command sequencing discipline
  * stronger verification

**Speaker notes**
NASA defines safety-critical software as software determined by and traceable to a hazard analysis. For safety- or mission-critical software, NASA requires the software to initialize to a known safe state, transition safely between known states, reject hazardous out-of-sequence commands, perform integrity checks and error handling, and be able to place the system into a safe state. Safety-critical components also carry stronger verification expectations like 100% MC/DC coverage — a DO-178C Level A requirement commonly adopted by NASA safety-critical projects, though not universally mandated across all NASA software — and typical NASA project thresholds range from 10–20 for cyclomatic complexity, with 15 being a common project-specific limit. ([standards.nasa.gov][8])

**Visual**
Criticality pyramid: **low → medium → high** with rigor increasing upward.

---

## Slide 10 — Risk management: design decisions first, operations second

**On slide**

* **RIDM** = choose between alternatives with risk awareness
* **CRM** = continuously manage risks during implementation
* Early choices burn in later fragility
* Risk belongs in architecture, not only postmortems

**Speaker notes**
NASA’s risk handbook says risk management comprises both RIDM and CRM. RIDM is the front-end: compare alternatives with awareness of their risk consequences. CRM is the continuous process used once a path is chosen. The handbook also says early decisions can “burn in” the risk that must later be managed, and that preventing late design changes is a key lever on cost and schedule. This is directly applicable to platform architecture: many “operational” incidents are really consequences of earlier design choices. ([NASA][9])

**Visual**
Decision tree feeding into a risk register / mitigation loop.

---

## Slide 11 — The real lesson for software teams

**On slide**

* The lesson is not “visual programming”
* The lesson is **behavior-first engineering**
* Make:

  * sequence
  * modes
  * interfaces
  * failure handling
    visible before coding

**Speaker notes**
This is your synthesis slide. Say plainly: *“Do not copy NASA’s ceremony everywhere. Copy its discipline where rework is expensive.”* Low-risk CRUD features do not need a modeling religion. But cross-team, high-impact, high-change, failure-prone behavior absolutely benefits from an explicit functional view.

**Visual**
Two columns: **cargo-cult process** vs **targeted rigor**.

---

## Slide 12 — Apply the mindset to a Go API management platform

**On slide**

* This is a **system**, not a pile of endpoints
* Separate:

  * **data plane**
  * **control plane**
  * **operations / recovery**
* Define functions before packages and services

**Speaker notes**
Use functional language first, not code-organization language. Your system functions are things like:

* publish API/product
* issue and rotate credentials
* authenticate caller
* authorize policy
* meter and bill usage
* transform and route traffic
* observe behavior
* audit admin changes
* degrade safely under upstream failure

That changes the team’s thinking from “what service do we build?” to “what behavior must the platform guarantee?”

**Visual**
Three swimlanes labeled **data plane / control plane / ops**.

---

## Slide 13 — Example FFBD #1: request lifecycle

**On slide**

* Receive request
* Identify API / tenant / route
* Authenticate
* Authorize
* Resolve policy
* Check quota
* Transform request
* Forward upstream
* Transform response
* Emit logs / metrics / traces
* Return result

**Branches**

* auth fail → deny + audit
* quota fail → deny + meter
* upstream unhealthy → retry / fallback / circuit breaker

**Speaker notes**
Tell the audience this is the “what happens next?” diagram — not the package structure, not the class model, not the goroutine topology. The value is that everybody can now argue about behavior in one place: which checks are ordered, which are optional, what happens on failure, and which artifacts must be emitted.

**Visual**
A clean FFBD with a single happy path and 3 off-nominal branches.

---

## Slide 14 — Example FFBD #2 + state machine: config rollout and credentials

**On slide**
**Config rollout FFBD**

* Draft policy
* Review
* Validate
* Stage
* Canary deploy
* Monitor
* Promote **or** Roll back
* Audit closeout

**Credential state machine**

* Issued → Active → Rotating → Revoked / Expired

**Safe states**

* last-known-good config
* deny-by-default on ambiguity
* rollback target always present

**Speaker notes**
This is where the NASA “safe state” mindset becomes valuable in software. Most platform outages do not come from the core request path alone. They come from bad config, broken rollout logic, stale keys, or dangerous transitions. So combine an FFBD for the process with a state model for lifecycle-sensitive objects. ([standards.nasa.gov][8])

**Visual**
Left half = rollout FFBD. Right half = key lifecycle state machine.

---

## Slide 15 — Example N² matrix: interface discipline for the platform

**On slide**
**Diagonal entities**

* Gateway
* Auth
* Policy
* Quota
* Billing
* Audit
* Observability
* Upstream APIs

**For each filled cell capture**

* contract / schema
* direction
* owner
* timeout / retry
* idempotency
* auth context
* versioning
* failure policy

**Speaker notes**
N² is the right view when interface complexity is your real risk. NASA-linked guidance describes N² diagrams as a tool for developing interfaces, and the MAV example is a perfect software lesson: they started with an N² diagram for initial interface definition, but once change accelerated, interface data became inconsistent until formal tracing was created in MagicDraw. That is exactly what happens in platform teams when interface docs, code, and rollout rules diverge. Use the matrix early — but once it stabilizes, connect it to the actual contracts. ([extapps.ksc.nasa.gov][10])

**Visual**
A partial N² matrix with 4–5 meaningful filled cells.

---

## Slide 16 — Criticality map + mental model shift

**On slide**
**Tier 1 — highest rigor**

* authN / authZ
* policy evaluation
* key validation
* quota / billing correctness
* immutable audit trail
* config deploy / rollback

**Tier 2 — medium rigor**

* routing
* service discovery
* circuit breaking
* cache invalidation
* telemetry pipeline

**Tier 3 — standard product rigor**

* portal UX
* docs sync
* dashboards

**Close with this**

* From **components first** → **functions first**
* From **happy path first** → **off-nominal early**
* From **code as architecture** → **behavior as architecture**
* From **docs after coding** → **models as coordination artifacts**
* From **testing as cleanup** → **verification designed in**

**Speaker notes**
Make clear that these are not NASA classes; they are your internal adaptation of NASA’s criticality logic. The point is proportional rigor. Tier 1 gets explicit behavior models, tighter review, stronger fault injection, rollback rehearsal, and direct traceability from function to tests and alerts. Tier 3 stays lightweight. That is how you borrow the mindset without importing unnecessary ceremony. ([standards.nasa.gov][8])

**Visual**
Left: criticality tiers. Right: old mental model vs new mental model.

---

## Closing line for the talk

> **NASA’s edge is not that it draws more boxes.
> It is that it tries to make behavior auditable before code locks it in.**

## Minimal artifact kit for your Go team

Start with just five artifacts:

1. **One FFBD** for request handling
2. **One FFBD + state machine** for config rollout and credential lifecycle
3. **One N² matrix** for core platform interfaces
4. **One criticality map** for platform functions
5. **One trace table**: function → contract → owner → tests → alerts

That is enough to change the team’s mental model without forcing a full MBSE toolchain.

[1]: https://nodis3.gsfc.nasa.gov/displayDir.cfm?Internal_ID=N_PR_7150_002D_&page_name=Chapter3 "https://nodis3.gsfc.nasa.gov/displayDir.cfm?Internal_ID=N_PR_7150_002D_&page_name=Chapter3"
[2]: https://www.nasa.gov/wp-content/uploads/2018/09/nasa_systems_engineering_handbook_0.pdf "https://www.nasa.gov/wp-content/uploads/2018/09/nasa_systems_engineering_handbook_0.pdf"
[3]: https://www.nasa.gov/reference/system-engineering-handbook-appendix/ "https://www.nasa.gov/reference/system-engineering-handbook-appendix/"
[4]: https://standards.nasa.gov/system/files/tmp/2025-03-12-NASA-HDBK-1009A.pdf "https://standards.nasa.gov/system/files/tmp/2025-03-12-NASA-HDBK-1009A.pdf"
[5]: https://ntrs.nasa.gov/api/citations/20240005284/downloads/NASAs_Use_of_MBSE_and_SysML_Modeling.pdf "https://ntrs.nasa.gov/api/citations/20240005284/downloads/NASAs_Use_of_MBSE_and_SysML_Modeling.pdf"
[6]: https://www.state-machine.com/doc/Benowitz2006.pdf "https://www.state-machine.com/doc/Benowitz2006.pdf"
[7]: https://ntrs.nasa.gov/api/citations/20120013073/downloads/20120013073.pdf "https://ntrs.nasa.gov/api/citations/20120013073/downloads/20120013073.pdf"
[8]: https://standards.nasa.gov/sites/default/files/standards/NASA/B/0/NASA-STD-87398-Revision-B.pdf "https://standards.nasa.gov/sites/default/files/standards/NASA/B/0/NASA-STD-87398-Revision-B.pdf"
[9]: https://www.nasa.gov/wp-content/uploads/2023/08/nasa-risk-mgmt-handbook.pdf "https://www.nasa.gov/wp-content/uploads/2023/08/nasa-risk-mgmt-handbook.pdf"
[10]: https://extapps.ksc.nasa.gov/reliability/Documents/Functional_Analysis_Module_V10.pdf "https://extapps.ksc.nasa.gov/reliability/Documents/Functional_Analysis_Module_V10.pdf"


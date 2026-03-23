Yes — and I’d frame the deck around one big idea:

**FRET is not just a NASA tool. It is a way to turn behavior from ambiguous prose into something explicit, executable, reviewable, and testable.**

I’m assuming by “thread” you mean **FRET / FRETish requirements**.

Below is a **super-detailed presentation draft** you can almost turn straight into slides.

---

## Recommended title

**From Ambiguous Requirements to Executable Behavior**
**What NASA FRET Teaches Us About Building Critical Software — Even in a Go API Platform**

A shorter alternative:

**What Backend Teams Can Learn from NASA FRET**

---

## Suggested audience framing

This works best for:

* senior engineers
* architects
* tech leads
* product/engineering managers
* anyone dealing with complex, risky, or highly integrated behavior

The key is: **do not present this as “NASA tool for rockets.”**
Present it as:

> “A modern contract-first engineering approach for systems where ambiguity, integration drift, and regressions are expensive.”

---

# Slide-by-slide draft

## Slide 1 — Title / thesis

**On slide**

* From Ambiguous Requirements to Executable Behavior
* What NASA FRET teaches us about critical software
* Applied to classical engineering: a Go API management system

**Say**
This talk is not really about aerospace. It is about a development mindset. NASA’s FRET is a strong example because it forces one discipline: **behavior should exist as a first-class artifact**, not only in people’s heads, tickets, docs, or test code.

**Visual**
A simple three-layer diagram:
**Intent → Contract → Code**

---

## Slide 2 — The problem we actually have

**On slide**

* Code is precise, but requirements are often vague
* Tests are concrete, but usually incomplete
* Architecture docs are useful, but often drift
* Risk appears at boundaries, timing, retries, failure modes, and refactors

**Say**
Most expensive failures are not caused by one bad `if` statement. They come from:

* two teams interpreting behavior differently
* hidden assumptions at system boundaries
* retry/failover/timeout interactions
* large refactors that preserve types but change behavior
* “works in unit tests” but breaks at integration time

For a Go API platform, that means things like:

* revoked API keys still working briefly
* quota rules inconsistently enforced
* duplicate requests creating double side effects
* stale policy state after rollout
* retries bypassing intended guarantees

This is the gap FRET tries to reduce.

---

## Slide 3 — What FRET actually is

**On slide**

* Open-source NASA framework for requirements
* Uses **FRETish**: structured English
* Generates multiple synchronized views of the same requirement
* Supports hierarchy, analysis, and export to verification tools

**Say**
FRET, developed at NASA Ames Research Center's Robust Software Engineering group (part of the Software Verification and Validation team), is a framework for **elicitation, specification, formalization, and understanding** of requirements.
You write requirements in **FRETish**, a constrained English-like language. A requirement can contain fields such as:

* scope
* condition
* component
* shall
* timing
* response
* probability

These seven fields are the core FRETish fields. It then shows the same requirement as:

* readable natural language
* formal logic
* diagrams

So it is not “just text.” It is **controlled language with semantics**. It also supports hierarchical requirements and analysis features like realizability and test generation. ([GitHub][1]) ([GitHub][2])

### How FRET Fits Into NASA's Requirements Flow: SRS and “One Artifact, Three Consumers”

**Important clarification: FRET augments the SRS, it does NOT replace it.** The SRS remains the authoritative document. FRET formalizes the subset of requirements that have clear behavioral semantics.

**Context: The Software Requirements Specification (SRS)**

NASA doesn't use Jira tickets. They use formal **Software Requirements Specifications (SRS)** — comprehensive documents (often hundreds of pages) containing functional requirements, performance requirements, interface specs, safety requirements, design constraints, quality attributes, and traceability matrices. Every requirement has a unique ID, traceable to design, code, and tests. The traditional SRS flow:

1. Systems engineers write the SRS — formal reviews, sign-offs, configuration management
2. The SRS is published with unique IDs (e.g., FSW-REQ-0142)
3. Flight software engineers receive the SRS and implement each requirement in C/C++
4. They write tests tracing back to the requirement ID
5. IV&V independently verifies requirement → code → test

**The problem with traditional SRS:** English “shall” statements are ambiguous. *”The system shall enter safe mode upon detection of anomalous sensor readings”* — what's “anomalous”? How fast? Which sensor? The developer interprets, makes assumptions, and the IV&V team may interpret differently.

**Only a subset of the SRS is formalizable in FRET** (~40-60% of functional requirements, most safety requirements) — specifically, requirements with a clear trigger, component, timing, and behavioral response. Things FRET CANNOT formalize:
- “The system shall be maintainable” — subjective quality attribute
- “The FSW shall be written in C99” — design constraint (verified by inspection)
- “Shall communicate via SpaceWire at 100 Mbps” — interface/hardware spec
- “The UI shall be intuitive” — subjective

**Where FRET augments the SRS:** Requirements engineers identify the formalizable “shall” statements and translate them into FRETish — a **manual, expert step**. The original SRS requirement ID is preserved:

SRS requirement FSW-REQ-0100:
> *”The FSW shall transition to SAFE_MODE when any primary sensor reports a value exceeding the configured threshold for more than 3 consecutive cycles.”*

FRETish formalization (in FRET tool, tagged as FSW-REQ-0100):
> *”When sensor_A_exceeded_count >= 3, the FlightController shall within 1 cycle satisfy mode = SAFE_MODE.”*

Notice: “any primary sensor” became a specific variable. “More than 3 consecutive cycles” became `>= 3`. The translator made **design decisions** — generating questions back to systems engineers: “Which sensors are 'primary'? Is it ≥3 or >3?”

**The “questions back” loop — arguably the most valuable part:** Translating SRS → FRETish forces resolution of every ambiguity. Those questions go back to systems engineers, improving the SRS itself. Defects found at requirements stage are orders of magnitude cheaper to fix.

**Both artifacts live together, linked by requirement IDs:**
- SRS (authoritative, Word/PDF, config-managed): FSW-REQ-0100 → English “shall”
- FRET project (version-controlled): FSW-REQ-0100 → FRETish + CoCoSpec contract + temporal logic + trace diagram + realizability status
- Non-formalizable requirements stay as-is in the SRS with verification by inspection

**Key insight — one artifact, three consumers:**

| Consumer | How they use the FRET formalization |
|---|---|
| **Developer** (flight software engineer) | Reads it alongside the SRS — inputs, outputs, timing are explicit. Resolves ambiguities in the original “shall” statement. |
| **Tester** | MC/DC test cases derive directly from the conditions. Requirement IDs go in test names for traceability. |
| **Verifier** (IV&V) | FRET generates temporal logic → Kind 2 proves it. Copilot generates runtime monitors from the same spec. |

FRET doesn't add work — it replaces the ambiguity-resolution that already happens (informally, in people's heads) with a tool-supported version that produces machine-checkable artifacts as a byproduct.

| | Traditional SRS flow | SRS + FRET augmentation |
|---|---|---|
| **Requirement format** | English prose: *”The system shall enter safe mode upon detection of anomalous sensor readings”* | FRETish: *”When sensor_A > threshold, FlightController shall immediately satisfy mode = SAFE_MODE”* |
| **Ambiguity** | “Anomalous”? How fast? Which sensor? | Explicit: which variable, what condition, what timing, what output |
| **Developer reads it and...** | Interprets, asks questions, makes assumptions | Implements directly — inputs and outputs are named |
| **Testable?** | Only after developer interprets | Directly — the requirement IS the test spec |
| **Formally verifiable?** | No | Yes — FRET generates temporal logic for Kind 2 |
| **Traceability** | Manual: someone maintains a matrix linking requirement → test → code | Built-in: FRET IDs in tests, FRET contracts in verification |

**Who uses FRET at NASA?**

| Team | Uses FRET? | Relationship to FRET |
|---|---|---|
| **Systems engineers** | Not typically | Write the original SRS; receive questions back from FRET translation that improve the SRS |
| **Requirements engineers** | Yes — primary users | Translate SRS → FRETish, run realizability checks, validate trace diagrams |
| **GN&C engineers** | Not typically — use MathWorks tooling | Receive FRET requirements as their design spec; Simulink models checked against FRET contracts |
| **Flight software engineers** | Not typically — they write C code | Receive FRET formalization alongside the SRS as their implementation spec |
| **IV&V engineers** | Yes — primary power users | Use FRET contracts to independently verify everyone else's work with Kind 2 |

**Visual**
A FRETish sentence broken into colored fields.

---

## Slide 4 — What FRET gives you as outputs

**On slide**

* Requirement text with precise semantics
* Realizability / consistency checking
* Requirement-based test generation
* Export to analysis/runtime-monitoring backends
* Trace simulation and replay

**Say**
The real value is not that FRET stores requirements. The value is that it produces **evidence-generating artifacts**.

From the current FRET release and docs:

* it supports **requirement-based test case generation**
* uses **Kind 2** and **NuSMV**
* exports generated tests in **JSON**
* exports test obligations in **Lustre** or **SMV**
* lets you visualize generated tests in **LTLSIM**
* exports to tools such as **CoCoSim**, **Copilot**, and **R2U2**
* and FRET's outputs can feed into **Ogma** (a bridge tool in the Copilot ecosystem, not a direct FRET export target) which generates **Copilot** runtime monitors in C with explicit input streams and violation handlers. ([GitHub][3]) ([GitHub][4]) ([NASA Technical Reports Server][5])

**Visual**
Pipeline:
**FRETish → formal semantics → tests / monitors / analysis code**

---

## Slide 5 — FRET is not the same as BDD

**On slide**

* **BDD/Gherkin** = executable examples
* **FRET** = formalized behavioral requirements
* BDD is scenario-centric
* FRET is property/contract-centric

**Say**
BDD and FRET look similar because both use human-readable text.

But the fundamental difference is:

* In **BDD**, Gherkin scenarios are executable because each step is matched to a **step definition** in code.
* In **FRET**, the requirement itself has a **formal semantics**.

Gherkin is excellent for collaboration, business examples, and acceptance scenarios.
FRET is stronger when you care about:

* temporal guarantees
* system modes
* consistency between many requirements
* generated test obligations
* runtime monitoring

A useful line for the audience:

> BDD says “show me examples.”
> FRET says “state the behavioral contract precisely.” ([Cucumber][6]) ([Cucumber][6]) ([Cucumber][7])

**Visual**
Split slide:
**BDD = Given/When/Then + step definitions**
**FRET = Scope/Condition/Component/Shall/Timing/Response + formal semantics**

---

## Slide 6 — Where FRET sits in a modern engineering stack

**On slide**

* Requirements live with the codebase
* Traceability in Git
* Formalization in FRET
* Analysis / generated tests / monitors in CI
* Evidence feeds reviews, audits, and assurance

**Say**
The modern pattern is not:
“write giant requirements document, then throw it over the wall.”

The stronger pattern is:

* requirements versioned in Git
* formalized in a tool like FRET
* linked to code and tests
* checked continuously

Space ROS documents this clearly:

* **Doorstop + Git** for tracking and traceability
* **FRET** for formalization and analysis
* requirements stored in Git and operated on by either tool

NASA’s Troupe work also shows a broader modern systems approach:

* NASA lifecycle reviews still exist
* but product development uses agile practices
* MBSE is used for interfaces and decomposition
* and a **contract-based approach** replaces some ambiguity of document-only interface specs. ([space-ros.github.io][8]) ([NASA Technical Reports Server][9]) ([space-ros.github.io][10])

**Visual**
Git repo at center, with Doorstop/FRET/CI/Test/Monitoring around it.

---

## Slide 7 — When this approach is worth using

**On slide**
Use it when:

* failure is expensive
* behavior depends on timing, ordering, or modes
* multiple teams own interacting components
* refactors are large and risky
* integration bugs keep recurring
* you need evidence, not just confidence

Do **not** start with:

* trivial CRUD behavior
* UI wording
* low-risk one-off transformations
* places where the cost of formalization exceeds the risk

**Say**
A common mistake is to think:
“If this is good, we should use it everywhere.”

No.
Use it **selectively**, where ambiguity or failure has a real cost.

For a backend/API system, that usually means:

* authn/authz
* quota and policy enforcement
* billing and entitlement boundaries
* retries/idempotency
* failover and degradation modes
* audit/compliance-critical flows

---

## Slide 8 — Why it matters for criticality and risk management

**On slide**
FRET helps reduce:

* ambiguity risk
* contradiction risk
* integration risk
* regression risk
* evidence gap

**Say**
This is the risk-management slide.

Map each risk to what FRET changes:

* **Ambiguity risk**
  Two readers interpret one requirement differently.
  FRET forces structure and shows diagrams/logic.

* **Contradiction risk**
  Two requirements cannot both be satisfied.
  FRET supports realizability/consistency analysis.

* **Integration risk**
  Team A and Team B “agree in English” but disagree in behavior.
  FRET pushes behavior toward explicit, checkable contracts.

* **Regression risk during refactor**
  Refactor preserves interfaces but changes observable behavior.
  FRET-generated tests and monitors help detect this.

* **Evidence gap**
  You believe the system is safe/correct, but cannot show a chain of evidence.
  That matters in certification and increasingly in enterprise compliance, too.

NASA’s Troupe paper explicitly ties these kinds of artifacts to safety assurance cases, where evidence such as tests, simulations, and analysis supports the argument that the system is acceptably safe. ([NASA Technical Reports Server][9]) ([NASA Technical Reports Server][9])

**Visual**
Risk matrix with a new “contract/evidence” layer across it.

---

## Slide 9 — It does **not** replace classical testing

**On slide**
Keep:

* unit tests
* integration tests
* regression tests
* exploratory tests

Add:

* requirement-based tests
* runtime monitors
* consistency checks
* stronger traceability

**Say**
This is important to say clearly:

> FRET does not remove the need for unit and integration tests.

It changes their role.

* **Unit tests** still validate local code behavior:
  parsing, edge cases, algorithms, error handling, data conversion
* **Integration tests** still validate infrastructure seams:
  DBs, queues, retries, network failures, config, auth wiring

What FRET adds is:

* a better **source of truth** for externally observable behavior
* a better **oracle**
* and in some cases, auto-generated scenarios

NASA’s Troupe system explicitly kept **unit tests for all apps**, plus **automated integration tests and manual testing**, while also using FRET to formalize requirements and generate requirement-based tests and monitors. That is the right mental model: **complement, not replacement**. ([NASA Technical Reports Server][9])

**Visual**
Testing pyramid with a behavioral-contract layer crossing the middle and top.

---

## Slide 10 — How to scale when one feature has 50 or 100 behaviors

**On slide**

* Don’t write giant mega-requirements
* Prefer **atomic behaviors**
* Group them hierarchically
* Keep parent/child traceability
* Refactor requirements like code

**Say**
This is where many people worry the approach will collapse.

The answer is:

* write **small, atomic requirements**
* organize them under a **larger parent capability**
* maintain traceability across levels

So instead of one giant statement like:
“API Gateway shall do all auth, quota, logging, retries, and fallback correctly”

You break it into:

* auth correctness
* quota timing
* duplicate request behavior
* fallback rules
* audit guarantees
* admin override rules
* degraded-mode behavior

That is not a weakness. It is exactly what makes change manageable.

FRET supports hierarchical requirements, and case-study authors describe using parent-child relationships to group related requirements. A 2025 experience paper also notes that large requirement sets become real engineering artifacts that need maintenance and sometimes refactoring, and that limitations can appear around things like quantification and scalability with very large models. ([GitHub][11]) ([arXiv][12]) ([arXiv][12])

**Visual**
Tree view:
Capability → sub-capabilities → leaf requirements

---

## Slide 11 — The mental model shift

**On slide**
From this:

* code is the truth
* tests are examples
* docs explain afterward

To this:

* behavior contract is the truth
* code is one implementation
* tests and monitors are evidence
* docs, code, and verification all point to the same contract

**Say**
This is the most important slide in the deck.

The deep lesson from FRET-style development is not “formal methods everywhere.”
It is this:

> **Behavior should not be implicit.**

A better engineering model is:

* requirement = behavioral contract
* architecture = allocation of that contract to components
* code = implementation
* tests/monitors = evidence the implementation respects the contract

That is a very different way to think about refactors.
During a big refactor, the internal structure can change radically, but the **behavioral contract** should stay stable unless the product intent changes.

---

## Slide 12 — Why this is relevant to a Go API management system

**On slide**
High-value use cases:

* API key lifecycle
* authz and policy enforcement
* rate limiting and quotas
* idempotency and retries
* circuit breakers / failover
* audit and compliance guarantees

**Say**
At first glance, an API management system does not look like a NASA problem.

But structurally, it has many of the same difficulties:

* asynchronous components
* policies that must remain consistent
* timing windows
* distributed failure modes
* mode changes
* correctness defined by externally observable behavior, not by class structure

In other words, many backend problems are **temporal and contractual**, not purely algorithmic.

This is exactly where FRET-style thinking helps.

---

## Slide 13 — Concrete FRET-style examples for a Go API platform

**On slide**
Example requirements:

1. Invalid key → immediate 401
2. Exhausted quota → next request gets 429
3. Revoked key → denied everywhere within 5 seconds
4. Upstream failure threshold → breaker opens within 2 seconds
5. Duplicate idempotency key → no duplicate side effect

**Say**
Here are examples you can actually show.

**Auth**

> Globally, when `request_received` and `api_key_valid = false`, `Gateway` shall immediately satisfy `response_status = 401`.

**Quota**

> Globally, when `quota_remaining(key) = 0`, `Gateway` shall at the next timepoint satisfy `response_status = 429`.

**Revocation propagation**

> After `key_revoked(key)`, `AuthSubsystem` shall within 5 seconds satisfy `all new auth_decisions(key) = denied`.

**Circuit breaker**

> When `upstream_5xx_rate(service) > threshold` for 30 seconds, `Gateway` shall within 2 seconds satisfy `breaker_state(service) = open`.

**Idempotency**

> When `duplicate_idempotency_key(request)` within 24 hours, `BillingService` shall eventually satisfy `duplicate_side_effect = false`.

These are not implementation details.
They are **behavioral obligations**.

**Visual**
Show each requirement as:
Plain English → FRETish → what the monitor/test would observe

---

## Slide 14 — The natural instrumentation approach in Go

**On slide**
Do **not** instrument every function.
Instrument **stable boundaries**:

* HTTP middleware
* gRPC interceptors
* queue consumers/producers
* domain event emitters
* response wrappers
* telemetry pipeline

**Say**
This is where teams often think the approach becomes too heavy.

The natural version is:

* do not put formal checkers inside every class or function
* observe behavior at **stable seams**
* feed those signals into tests or monitors

For Go, that usually means:

* `net/http` middleware
* gRPC interceptors
* message consumer wrappers
* domain event publishers
* audit/event streams
* OpenTelemetry spans/attributes
* structured logs or metrics

That keeps the system largely black-box from the requirement perspective, which is actually good.
The requirement should care about **what the system does**, not how many structs or packages it used to get there.

---

## Slide 15 — Documenting signals and variables

**On slide**
Create a **Signals Catalog**

* name
* meaning
* type
* source
* owner
* stability
* linked requirements

**Say**
You asked the right question earlier:
“How do we document what signals exist and what can be monitored?”

This deserves its own artifact.

Example:

```yaml
signals:
  - name: request_received
    type: bool
    source: gateway middleware
    owner: platform team
    description: true when a request enters the gateway decision path

  - name: api_key_valid
    type: bool
    source: auth decision result
    owner: auth team
    description: result of API key validation for the current request

  - name: response_status
    type: int
    source: response writer wrapper
    owner: platform team
    description: final HTTP status returned to client
```

This catalog becomes the bridge between:

* architecture
* code
* requirements
* observability
* monitors/tests

FRET itself already has supporting concepts here: its variable glossary can show variables used by a component, the requirements that reference them, and attributes like variable type, assignment, model component, and description. The analysis portal also automatically extracts components, variables, functions, and modes from requirements. ([GitHub][2]) ([GitHub][4])

**Visual**
A neat table called “Signals Catalog.”

---

## Slide 16 — A practical delivery model for a Go team

**On slide**

1. Keep requirements in Git
2. Formalize critical ones in FRET
3. Record signals at boundaries
4. Generate tests / monitors where useful
5. Run them in CI and pre-release validation
6. Expand only where risk justifies it

**Say**
Do not start with the whole system.

Start with one high-risk flow:

* key revocation
* quota enforcement
* billing/idempotency
* failover

Then do this:

* define 10–15 atomic behavioral requirements
* create the Signals Catalog
* record signals at the gateway boundary
* run requirement-based tests and/or post-run checking
* keep classical tests in place
* grow only after the workflow proves useful

This keeps adoption practical and credible.

---

## Slide 17 — What we learn from this style of development

**On slide**

* requirements are software artifacts
* observability is part of correctness
* risk should drive precision
* refactors need behavioral contracts
* evidence matters as much as intent

**Say**
This is the “so what?” slide.

The biggest lesson is not “use NASA tooling.”
The biggest lesson is:

1. **Requirements should be versioned, reviewable artifacts.**
2. **Critical behavior should be machine-checkable.**
3. **Observability should be designed as part of correctness, not added later.**
4. **Large refactors are safer when behavior is explicit.**
5. **Teams should think in contracts at boundaries, not only code inside modules.**

That is a better mental model for any complex system.

---

## Slide 18 — Honest caveats

**On slide**

* There is a learning curve
* Not every requirement is worth formalizing
* Large specs need discipline and maintenance
* Some expressive gaps still exist
* Tooling integration must stay lightweight to succeed

**Say**
This is where you stay credible.

A good talk should say clearly:

* FRET is not free
* not every team is ready for it
* not every requirement deserves this treatment
* requirement sets can become large and need maintenance
* some case-study users reported expressiveness limits around quantifiers and challenges with large-model integrations

So the right message is not:
“Replace your current engineering process.”

It is:
“Use this for the parts of the system where ambiguity and change are most dangerous.” ([arXiv][12])

---

## Slide 19 — Closing line

**On slide**
**Don’t let behavior live only in prose or code.
Make it explicit, executable, and reviewable.**

**Say**
That is really the whole talk.

For a Go API management system, the win is not “formal methods everywhere.”
The win is:

* fewer hidden contracts
* safer refactors
* better risk control
* stronger engineering conversations
* and better evidence that the system does what you think it does

---

# Optional appendix slides

## Appendix A — FRET vs BDD in one slide

**On slide**

* BDD = examples, collaboration, executable scenarios
* FRET = constrained requirements, formal semantics, analyzable contracts
* Best combo: BDD for narratives, FRET for normative behavior

**Say**
BDD is how teams talk through examples.
FRET is how teams pin down the behavior they cannot afford to leave ambiguous.

---

## Appendix B — Source of truth slide

**On slide**
Three kinds of truth:

* behavioral truth = requirements
* design truth = architecture
* implementation truth = code

**Say**
The key shift is that code stops being the only thing people trust.
The behavioral contract becomes the thing code must satisfy.

---

## Appendix C — One-slide pilot recommendation

**On slide**
Pilot candidate:

* API key revocation propagation
* or rate limiting + policy consistency

**Why this pilot**

* critical
* easy to observe
* timing-sensitive
* cross-cutting
* often under-tested by examples alone

---

# A strong narrative you can repeat throughout the deck

Use this sentence more than once:

> **FRET is not mainly about generating artifacts. It is about changing where precision lives in the development process.**

And a second one:

> **The goal is not to formalize everything. The goal is to formalize the behaviors you cannot safely leave ambiguous.**

And for the Go audience:

> **For backend platforms, treat critical workflows like control systems: define the contract, expose the signals, and verify the behavior at the boundary.**

---

# If I were tightening this for delivery

The **core 10 slides** would be:

1. Title
2. Problem
3. What FRET is
4. What it outputs
5. FRET vs BDD
6. Risk management
7. Not a replacement for testing
8. Go API examples
9. Signals catalog / natural instrumentation
10. Closing lesson

That version would be cleaner for a live talk.

---

# The factual backbone for your deck

These are the most useful facts to anchor the talk:

* FRET is an open-source NASA framework for elicitation, specification, formalization, and understanding of requirements; it supports multiple representations and hierarchical requirements. ([GitHub][1]) ([GitHub][11])
* FRETish requirements use structured fields and current docs include an optional probability field. ([GitHub][2])
* FRET 3.0 added requirement-based test case generation, JSON export, LTLSIM trace handling, and probabilistic requirements. ([GitHub][3])
* FRET exports to external analysis/runtime tools such as CoCoSim, Copilot, R2U2, Kind, and SMV-related workflows. ([GitHub][4]) ([space-ros.github.io][8])
* Ogma/Copilot integration turns FRET component specs into runtime monitors with explicit input streams and C handlers. ([NASA Technical Reports Server][5])
* Space ROS uses Doorstop + Git for requirements traceability and FRET for formalization/analysis. ([space-ros.github.io][8]) ([space-ros.github.io][10])
* NASA’s Troupe project used FRET alongside unit tests, automated integration tests, and manual testing, which makes the complement-not-replace story especially strong. ([NASA Technical Reports Server][9])

The cleanest punchline for the deck is:

**FRET teaches us to move from “tests prove examples” to “contracts define behavior, and tests/monitors provide evidence.”**

[1]: https://github.com/NASA-SW-VnV/fret/blob/master/fret-electron/docs/_media/userManual.md "https://github.com/NASA-SW-VnV/fret/blob/master/fret-electron/docs/_media/userManual.md"
[2]: https://github.com/NASA-SW-VnV/fret/blob/master/fret-electron/docs/_media/user-interface/writingReqs.md "https://github.com/NASA-SW-VnV/fret/blob/master/fret-electron/docs/_media/user-interface/writingReqs.md"
[3]: https://github.com/NASA-SW-VnV/fret/releases "https://github.com/NASA-SW-VnV/fret/releases"
[4]: https://github.com/NASA-SW-VnV/fret/blob/master/fret-electron/docs/_media/ExportingForAnalysis/analysis.md "https://github.com/NASA-SW-VnV/fret/blob/master/fret-electron/docs/_media/ExportingForAnalysis/analysis.md"
[5]: https://ntrs.nasa.gov/api/citations/20220000049/downloads/Technical_Report_Copilot_FRET%20%284%29.pdf "https://ntrs.nasa.gov/api/citations/20220000049/downloads/Technical_Report_Copilot_FRET%20%284%29.pdf"
[6]: https://cucumber.io/docs/gherkin/reference/ "https://cucumber.io/docs/gherkin/reference/"
[7]: https://cucumber.io/docs/cucumber/step-definitions "https://cucumber.io/docs/cucumber/step-definitions"
[8]: https://space-ros.github.io/docs/rolling/Related-Projects/FRET.html "https://space-ros.github.io/docs/rolling/Related-Projects/FRET.html"
[9]: https://ntrs.nasa.gov/api/citations/20240000218/downloads/SciTech_2024_TroupeSystem.pdf "https://ntrs.nasa.gov/api/citations/20240000218/downloads/SciTech_2024_TroupeSystem.pdf"
[10]: https://space-ros.github.io/docs/rolling/Introduction/How-Space-ROS-Differs.html "https://space-ros.github.io/docs/rolling/Introduction/How-Space-ROS-Differs.html"
[11]: https://github.com/NASA-SW-VnV/fret "https://github.com/NASA-SW-VnV/fret"
[12]: https://arxiv.org/html/2503.24040v1 "https://arxiv.org/html/2503.24040v1 [citation to be verified against published proceedings]"

---

## Technical Deep Dive: How FRET Actually Works (added 2026-03-16)

### Variable Binding — Not Free-Form Text

FRETish variable names (e.g., `voltage`, `breaker_state`, `diff_setNL_observedNL`) are identifiers typed by the user. FRET does NOT automatically import them from code or models. Instead:

1. Variables go into a **Glossary** tracked per project
2. Each variable is classified by role: **Input** (environment), **Output** (component produces), **Internal** (state — requires Lustre assignment expression), **Function** (Lustre library nodes)
3. Data types are assigned: boolean, integer, double, real
4. Glossary provides **autocomplete** filtered by type category — prevents typos and enforces consistency across hundreds of requirements

For **Simulink integration**, FRET maps Simulink port types: Inport→Input, Outport→Output, internal signals→Internal variables. Simulink data types map to Lustre types: Boolean→bool, int8/uint8→int, double/single→real, enum→enum, bus→struct.

### Formalization Output

For each FRETish requirement, FRET generates formulas in **past-time metric Linear Temporal Logic (pmLTL)** and future-time LTL. Supported operators include boolean/arithmetic (`!`, `&`, `|`, `xor`, `=>`, `=`, `!=`, `<`, `>`, `<=`, `>=`, `+`, `-`, `*`, `/`, `mod`, `^`) and nine built-in temporal predicates (`preBool`, `preInt`, `preReal`, `persisted`, `occurred`, `persists`, `occurs`, `prevOcc`, `nextOcc`).

### Two Distinct Analysis Paths

**Path A: Design-Time Proof (via CoCoSim + Simulink)**
1. FRETish requirements → pmLTL formulas
2. Combined with variable mapping → **CoCoSpec** monitors (extension of Lustre for mode-aware assume-guarantee contracts)
3. CoCoSpec monitors + Simulink model → **CoCoSim** translates entire Simulink model to equivalent Lustre code
4. **Kind 2** / JKind / Zustre perform SMT-based model checking on generated Lustre
5. FRET supports Kind 2 v2.2.0 specifically (v2.3.0 NOT supported)

**Path B: Runtime Monitoring (via Ogma + Copilot)**
1. FRETish requirements → pmLTL formulas
2. FRET exports **JSON file** containing: formalizations in SMV and Lustre syntax, variable metadata (names, types), function definitions
3. **Ogma** consumes this JSON directly
4. Ogma generates **Copilot specification** (Haskell EDSL)
5. **Copilot compiler** produces C99 runtime monitors — constant memory, constant time, zero dynamic allocation
6. Ogma wraps monitors into complete platform applications:
   - **ROS 2:** CMakeLists.txt, copilot_monitor.cpp, copilot_logger.cpp, package.xml, Dockerfile (Space ROS container)
   - **NASA cFS:** C application with CFE_SB_Subscribe() and message handlers
   - **F Prime:** .fpp port definitions, C++ implementation, CMake config

Full pipeline: **FRETish → pmLTL → JSON → Ogma → Copilot Haskell spec → Copilot compiler → C99 → C compiler → executable**

### Realizability Checking

FRET uses Kind 2 directly (outside CoCoSim) for realizability analysis — checking whether requirements can be simultaneously satisfied by any implementation given arbitrary environment inputs. Two modes:
- **Monolithic:** single-pass checking of all requirements
- **Compositional:** automatic decomposition into connected components (subsets over disjoint outputs), enabling parallel analysis

When requirements are unrealizable, FRET diagnoses **minimal conflicting requirement sets** and generates counterexample execution traces. Results visualized as chord diagrams, exportable as JSON.

### Doorstop Connection

Doorstop stores requirements as individual YAML/Markdown files in git (one file per requirement, organized in directories). The FRET↔Doorstop connection is **bidirectional via Markdown import/export**: Doorstop requirements can be imported into FRET for formalization, and FRET requirements exported back for traceability management. They share the same git repository. Doorstop has NO direct connection to Ogma, Copilot, Kind 2, or Lustre — it is purely upstream in the requirements management layer.

### Complete Data Flow

```
Doorstop (YAML/Markdown in git — requirements tracking + traceability)
    |  <-- bidirectional Markdown import/export -->
    v
FRET (FRETish → pmLTL formalization, variable glossary, realizability)
    |
    +---> Path A: CoCoSpec/Lustre export
    |         |
    |         v
    |     CoCoSim + Simulink model (Simulink → Lustre translation)
    |         |
    |         v
    |     Kind 2 / JKind / Zustre (SMT model checking — proves ALL states)
    |
    +---> Path B: JSON export (SMV + Lustre formalizations + variable metadata)
              |
              v
          Ogma (consumes JSON, generates Copilot specs + platform glue)
              |
              v
          Copilot (Haskell EDSL → C99 runtime monitors)
              |
              v
          Target platform (ROS 2 node / NASA cFS app / F Prime component)
```

Sources: FRET GitHub docs (writingReqs.md, copilot.md, cocosim.md, realizabilityManual.md), Ogma GitHub, Copilot GitHub, Space ROS docs, NTRS technical reports.

---

## Architectural Prerequisite: Modularity and Component Boundaries (added 2026-03-16)

### The Fundamental Assumption

FRET and the entire Lustre/Copilot verification ecosystem assume a **modular, component-based architecture with well-defined interfaces**. This is not incidental — it is a structural requirement of the approach:

1. **FRET's fundamental unit is the "component."** Every FRETish requirement is written about a specific component with typed inputs and outputs. The variable glossary enforces this: each variable is classified as Input (from environment), Output (produced by component), or Internal (state). There is no concept of "call this external API and see what happens."

2. **The Lustre/Copilot world is synchronous.** Everything operates on a logical clock tick. External third-party state (async API calls, network delays, eventual consistency) does not naturally fit this model. The QFCS case study authors explicitly noted that synchronous execution was a fair assumption for their flight control design, and that support for asynchronous or quasi-synchronous components was still being added.

3. **The assume/guarantee pattern requires isolation.** You *assume* what the environment provides (your inputs), you *guarantee* what your component does (your outputs). This only works when you can actually reason about one component without knowing the internals of another.

### What Works Well vs. What Requires Careful Modeling

| Works well | Requires careful modeling | Does not fit naturally |
|---|---|---|
| Local state machines (auth decisions, circuit breakers) | Caches with TTLs (model TTL as stream countdown) | Distributed consensus |
| Mode-based behavior (normal/degraded/recovery) | External service health (model as boolean input stream) | Eventual consistency guarantees |
| Timing invariants within one component | Retries (model retry count as internal state) | Cross-service transactions |
| Policy evaluation with known inputs | Queue consumers (model as discrete events) | Unbounded async workflows |
| Sequential request processing | Timeout behavior (model with "within N" timing) | Shared mutable state across services |

### How to Handle External / Third-Party State

External state is modeled as **inputs with assumptions**, not as something you control:

- **External service health** → boolean Input: `auth_backend_up`
- **Cache freshness** → boolean Input: `cache_fresh` (with assumption: `cache_fresh => cache_age < ttl`)
- **Network latency** → real Input: `response_time_ms` (with assumption: bounded range)
- **Third-party API response** → enum Input: `upstream_status` ∈ {ok, error, timeout}

The key insight: you do not model the external system's internals. You model **what your component observes** and **what assumptions you make about those observations**. If an assumption is wrong, realizability analysis will expose the contradiction.

### Architecture Requirements for Effective Use

To use FRET and the verification toolchain effectively, a system needs:

1. **Clear component boundaries** — each component has defined inputs and outputs, not implicit dependencies through shared databases or global state
2. **Observable interfaces** — you can actually measure the variables you write requirements about (this connects directly to the "Signals Catalog" concept)
3. **Isolation** — you can reason about one component without knowing the internals of another
4. **Stable seams for instrumentation** — HTTP middleware, gRPC interceptors, message bus consumers, event emitters — places where you can observe Input/Output streams

### The Design Feedback Effect

The NASA Inspection Rover case study explicitly states that **"developing with formal methods in mind from the outset can influence the design"** and make it more amenable to verification. This means:

- Systems designed for verification tend to be **more modular**
- Components have **clearer interfaces** with explicit input/output contracts
- State management becomes **more explicit** (no hidden shared state)
- Failure modes are **named and handled** (modes in Lustre/FRET)

This is a feature, not a bug. The exercise of trying to write FRET requirements for a tightly coupled system will show you exactly where your boundaries are unclear. The requirements become a forcing function for better architecture.

### Implications for Backend/API Systems

For a Go API management platform or similar backend system:

**Natural component boundaries exist at:**
- Gateway ingress (HTTP middleware)
- Auth/AuthZ decision point
- Policy evaluation engine
- Rate limiter / quota manager
- Circuit breaker per upstream
- Config distributor
- Audit event emitter

**Each of these can be modeled as a FRET component** with:
- Inputs: request data, external service status, config state, time
- Outputs: decisions (allow/deny/throttle), state transitions, events
- Internal state: counters, caches, mode flags

**What does NOT fit easily:**
- Cross-service consistency guarantees ("auth and billing always agree")
- Distributed rollout atomicity ("all nodes see same config simultaneously")
- End-to-end latency guarantees across multiple async hops
- Database transaction semantics

For these, FRET/Lustre is the wrong tool. Use distributed systems testing (Jepsen-style), chaos engineering, or TLA+ for reasoning about distributed protocols. The key is knowing which tool fits which problem.

### Real-World Example: Refactoring a Go Middleware for FRET Coverage (added 2026-03-16)

A detailed worked example of applying FRET and MC/DC to a real Go API gateway middleware function (`createMiddleware`) is documented in `research_testing_as_evidence.md`, section 1.4.7. The key findings:

1. **Original function:** ~80-line HTTP handler closure with 6 interleaved boolean decisions tangled with side effects (tracing, logging, metrics, error handling). FRET could model only ~30-40% of the behavior because decisions were inseparable from side effects.

2. **Refactoring pattern: Decide → Plan → Execute**
   - Extract ALL decision logic into pure functions that take struct inputs and return a "plan" struct
   - The plan struct fields ARE the FRET Output variables
   - An executor mechanically carries out the plan — one field → one action, no branching
   - The orchestrator gathers inputs, calls decision functions, passes plan to executor

3. **After refactoring:** FRET covers 100% of decision logic. MC/DC is table-driven unit tests with zero mocks. 7 FRETish requirements map directly to the pure decision functions.

4. **FRET modeling:**
   - `MiddlewareInputs` fields → FRET Glossary Input variables
   - `MiddlewarePlan` fields → FRET Glossary Output variables
   - `PlanBeforeProcess` and `PlanAfterProcess` → FRET components
   - FRETish requirements like: `When cors_passthrough is true & request_method = "OPTIONS", PlanBeforeProcess shall immediately satisfy passthrough_cors = true & call_next = true`

5. **The insight:** This is the same principle as FRET's component model applied at the function level. Separating **what to do** (pure decisions) from **how to do it** (side effects) is what makes any code FRET-coverable. The pattern applies to HTTP handlers, gRPC interceptors, queue consumers, event processors — anywhere decisions are tangled with effects.

See the full worked example with complete Go code, MC/DC test tables, FRET glossary mappings, and before/after comparison in `research_testing_as_evidence.md`.

### The Honest Caveat for Presentations

When presenting this toolchain, the credible position is:

> "This approach works best when your architecture has clear component boundaries with typed interfaces. If it doesn't, the exercise of trying to write FRET requirements will show you exactly where your boundaries are unclear. That is a feature, not a bug — but it means you may need to refactor before you can verify."

The QFCS case study (quad-redundant flight control) and the Lift-Plus-Cruise aircraft work both operated on systems with well-defined component hierarchies. The Troupe project (NASA cFS-style middleware) was explicitly designed as modular — which the authors noted made it naturally amenable to formal methods integration.


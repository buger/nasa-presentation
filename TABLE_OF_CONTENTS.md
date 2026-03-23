# High-Assurance Software in the AI Era

## What NASA, Automotive, and Safety-Critical Engineering Can Teach Modern Software Teams

**Internal Reference — Table of Contents**

---

### Preface: Why This Book Exists

- The gap between "move fast and break things" and "failure is not an option"
- Who this is for: platform engineers, API teams, infrastructure builders, engineering leaders
- How to use this reference: not a compliance manual — a thinking toolkit
- The running example: a Go API management platform (routing, auth, policy, config, observability)

---

## Part I — Foundations: The High-Assurance Mental Model

### Chapter 1: Why High-Assurance Thinking Matters for Software Teams

> **Source material:** [general.md](general.md) (slides 1-2), [general_ai.md](general_ai.md) (section 1)

- 1.1 What "high assurance" actually means (not "zero defects" — disciplined control of consequence)
- 1.2 The evidence economy: progress measured by verified work products, not velocity alone
- 1.3 Consequence-first thinking vs. feature-first thinking
- 1.4 The core loop: Claim → Control → Evidence → Decision
- 1.4b The safety case pattern: Goal Structuring Notation (GSN) and Claims-Arguments-Evidence (CAE) — the formal name for the Claim → Control → Evidence → Decision pattern
- 1.5 Why this matters now: AI accelerates creation but not confidence
- 1.6 The myth of "normal software with stricter QA"

### Chapter 2: The Standards Landscape — NASA, Automotive, and AI Governance

> **Source material:** [general_ai.md](general_ai.md) (sections 2-3), [general.md](general.md) (slides 3, 9)

- 2.1 **NASA standards ecosystem**
  - NPR 7150.2D — software engineering requirements, Requirements Mapping Matrix, software classes A-E
  - NASA-STD-8739.8 Rev B — software assurance, safety, IV&V
  - NASA Software Engineering Handbook (SWEHB) — including AI/ML guidance
  - CMMI-DEV — capability maturity (Level 3 for Class A, Level 2 for Class B)
- 2.2 **Automotive standards ecosystem**
  - ISO 26262 — functional safety (Parts 2-8: management, concept, system, hardware, software, production, supporting processes)
  - ISO 21448 (SOTIF) — safety of the intended functionality, triggering conditions, foreseeable misuse
  - ISO/PAS 8800 — AI-based safety-related vehicle systems (and its explicit gaps)
  - Automotive SPICE 4.0 — process capability assessment with ML extensions
  - MISRA C:2012 AMD4 and MISRA Compliance:2020 — coding guidelines and enforcement plans
  - UN R155 (cybersecurity) and UN R156 (software updates) — entered into force 22 Jan 2021
- 2.3 **AI governance frameworks**
  - NIST AI RMF — Govern/Map/Measure/Manage structure
  - EU AI Act — risk-based classification, cars as high-risk product domain
  - ISO/IEC 42001 — AI management system requirements
- 2.6 **Avionics: DO-178C and DO-330**
  - DO-178C — Software Considerations in Airborne Systems and Equipment Certification
  - DO-330 — Software Tool Qualification Considerations (five TQL levels)
  - The most influential high-assurance software standard globally — origin of MC/DC, structural coverage, and tool qualification concepts
  - IEC 61508 — the parent standard behind ISO 26262, applicable across industrial, rail, nuclear, and medical domains
- 2.7 How these standards relate to each other and where the gaps are
- 2.8 What a platform team should actually read (a curated reading list)

### Chapter 3: Classify Before You Engineer — Criticality-Driven Rigor

> **Source material:** [general.md](general.md) (slide 3, 13), [general_ai.md](general_ai.md) (section 2), [ffdb.md](ffdb.md) (criticality tier map)

- 3.1 NASA's classification model: Classes A through E
  - What each class means in practice (human-rated → exploratory)
  - The "higher class wins" rule for ambiguous components
  - Class E cannot be safety-critical — must be upgraded if it becomes operational
- 3.2 Automotive ASIL levels: how HARA determines rigor
  - Severity × Exposure × Controllability → ASIL A-D or QM
- 3.3 Building a local classification: the P0-P3 model
  - P0 (critical): authN/authZ, policy evaluation, key validation, audit trail, config deploy/rollback
  - P1 (important): routing, service discovery, circuit breaking, billing correctness
  - P2 (standard): caching, telemetry pipeline, dashboards
  - P3 (experimental): prototypes, internal tools, design explorations
- 3.4 How classification drives everything else: review depth, test rigor, deployment process, AI usage permissions
- 3.5 Running the classification exercise with your team
- 3.6 Tailoring: NASA's approach to scaling requirements by class (with rationale and approval)

---

## Part II — Engineering Disciplines

### Chapter 4: Requirements as Contracts — SRS, FRET, and Behavioral Specification

> **Source material:** [fret_slides.md](fret_slides.md), [research_testing_as_evidence.md](research_testing_as_evidence.md) (section 1.2.1)

- 4.1 The requirements gap: ambiguity between prose and code
  - Most expensive failures come from misinterpretation, hidden assumptions, boundary interactions
  - "Exceeding the threshold" — `>` or `>=`? Most bugs trace to requirements ambiguity, not coding errors
- 4.2 **The Software Requirements Specification (SRS): structure and purpose**
  - What an SRS actually looks like (IEEE 830 / ISO/IEC/IEEE 29148): introduction, overall description, specific requirements, traceability matrix
  - Section 3 breakdown: functional (formalizable), performance (some), interface (mostly not), safety (almost always), design constraints (not), quality attributes (not)
  - Only 40-60% of functional requirements are FRET-formalizable — the rest stay as traditional SRS text
  - The SRS is the authoritative document — FRET augments it, does NOT replace it
- 4.3 **SRS structure for multi-component systems**
  - The requirements hierarchy: Business Requirements → System Requirements Document (SyRD) → Component SRS (one per deployable service) → Interface Control Document (ICD)
  - Document structure mirrors architecture — one SRS per component, system-level for the glue
  - Three tests for deciding where a requirement lives: (1) Can you assign ONE owner? → Component SRS. (2) Requires multiple components? → System SyRD. (3) About the contract between them? → ICD.
  - **Applied example: Gateway ↔ Dashboard** — system requirement SyRD-REQ-0080 ("≤60s API definition staleness") decomposes into Dashboard SRS (DASH-REQ-0040, 0041, 0042), Gateway SRS (GW-REQ-0100 through 0105), and ICD (ICD-GW-DASH-001, 002)
  - Math verification: 5s publish + 30s poll + retry ≈ under 60s budget
  - Traceability across the hierarchy: system req → component reqs → tests → code locations
  - Grey areas: fault tolerance involving another component, shared infrastructure requirements, tightly coupled components (architecture smell, not requirements problem)
  - ISO/IEC/IEEE 29148:2018 — the standard that defines this decomposition
- 4.4 **How the SRS evolves: bugs, features, extensions**
  - The SRS is a living document under configuration management (DOORS tracks every change)
  - Bug fix flow: Problem Report → root cause analysis (code bug vs. requirements bug vs. ambiguity) → CCB approval → SRS versioned → FRET updated → tests updated → traceability updated
  - New feature flow: new requirement IDs added to existing SRS → FRET formalization → realizability check catches conflicts with existing requirements → normal verification flow
  - Extension flow: impact analysis first (DOORS change impact + FRET realizability across old + new) → modify + add requirements → re-verify
  - The "questions back" loop: FRET translation forces ambiguity resolution, generating questions to systems engineers — arguably more valuable than the formal verification itself
- 4.5 What FRET is: NASA's Formal Requirements Elicitation Tool
  - FRETish structured English: scope, condition, component, shall, timing, response, probability
  - Four synchronized outputs per requirement: FRETish text, semantic explanation, temporal logic formula, trace diagram
  - FRET trace diagrams: evaluates the *requirement*, not the system — toggle inputs, see if requirement is satisfied or violated. "Given these inputs, what does the requirement *expect*?"
  - Multi-view semantics: four forms simultaneously catch mismatches between what you *wrote* and what you *meant*
  - Vacuity detection: flags requirements that are trivially true (trigger condition never occurs)
  - Completeness gaps via realizability: identifies input combinations where no requirement specifies what should happen
- 4.6 FRET vs. BDD/Gherkin
  - BDD: scenario-centric, example-driven (Given/When/Then)
  - FRET: property/contract-centric with formal semantics
  - When each is stronger: BDD for user-facing flows, FRET for temporal/modal/safety properties
- 4.7 Realizability and consistency analysis
  - Can the requirement actually be implemented? Are requirements contradictory?
  - Takes ALL requirements together — catches conflicts before code exists
  - Diagnostic traces show the specific input combination that's problematic
- 4.8 **Who uses FRET at NASA — the multi-team pipeline**
  - Systems engineers: write the original SRS; receive questions back from FRET translation
  - Requirements engineers: primary FRET authors — translate SRS → FRETish, run realizability, validate trace diagrams
  - GN&C engineers: use Simulink (visual block diagrams for control algorithms), NOT FRET — Simulink auto-generates Lustre
  - Flight software engineers: write hand-written C/C++ — receive FRET formalization alongside SRS as implementation spec
  - IV&V engineers: primary FRET power users — verify everyone else's work with Kind 2
  - One artifact, three consumers: developer (implementation spec), tester (MC/DC derivation), verifier (Kind 2 + Copilot)
- 4.9 The Signals Catalog: bridging architecture, code, requirements, and monitoring
  - Signal name, meaning, type, source, owner, stability, linked requirements
- 4.10 FRET in a modern engineering stack: requirements in Git, formalization in tooling, verification in CI
  - Space ROS's approach: Doorstop + Git + FRET
  - **For teams without DOORS:** SyRD → ADRs + OpenAPI; Component SRS → Jira epics with acceptance criteria; ICD → OpenAPI/protobuf/AsyncAPI; Traceability → Jira links + requirement IDs in test names; CCB → architectural PR reviews
- 4.11 When to formalize and when not to
  - Use for: timing/ordering/mode-dependent behavior, expensive failures, multi-team integrations
  - Skip for: trivial CRUD, UI copy, low-risk one-offs
- 4.12 **Applied examples for API platforms**
  - Invalid API key → immediate 401
  - Revoked key denied everywhere within 5 seconds
  - Upstream failure threshold → circuit breaker open within 2 seconds
  - Duplicate idempotency key → no duplicate side effect
  - Gateway ↔ Dashboard API definition loading (full worked example with decomposition)

### Chapter 5: Behavior Before Code — Functional Decomposition and MBSE

> **Source material:** [ffdb.md](ffdb.md)

- 5.1 The difference between drawings, models, and generated code
- 5.2 FFBD (Functional Flow Block Diagram): function-first, time-sequenced system behavior
  - When to use: ConOps, logical decomposition, design reviews, ops procedure redesign
- 5.3 The diagram taxonomy: which question each answers
  - FFBD → "what happens in what order?"
  - EFFBD → "what resources, data, and controls flow between functions?"
  - N-squared → "who talks to whom and through what interface?"
  - State machines → "what modes exist and what triggers transitions?"
  - SysML/MBSE → "how does it all connect in a single data model?"
- 5.4 From classical diagrams to digital engineering (document-centric → data-centric)
- 5.5 **NASA case studies**
  - Deep Space 1: auto-coding from statecharts for fault protection
  - Orion GN&C: Simulink models → automatic C++ generation, inspections on models not autocode
  - Mars Ascent Vehicle: N-squared in Excel → MagicDraw when untraced interfaces diverged
- 5.6 The five mental model shifts for software teams
  - Components first → Functions first
  - Happy path first → Off-nominal early
  - Code as architecture → Behavior as architecture
  - Docs after coding → Models as coordination artifacts
  - Testing as cleanup → Verification designed in
- 5.7 **Applied: FFBD for an API request lifecycle**
  - Receive → Identify → Authenticate → Authorize → Resolve Policy → Check Quota → Transform → Forward → Emit Telemetry → Return
- 5.8 **Applied: N-squared matrix for platform interfaces**
- 5.9 Data plane / control plane / operations-recovery separation

### Chapter 6: Formal Verification for Mortals — Lustre, Kind 2, and Contracts

> **Source material:** [lustre.md](lustre.md)

- 6.1 Why reactive systems need different thinking
  - Continuous interaction, timing constraints, sequence-dependent failures
- 6.2 Lustre: synchronous dataflow language
  - Variables as streams over logical time, nodes as components
  - Core operators: `pre` (previous value), `->` (initialization/recurrence)
- 6.3 The contract system: assumptions, guarantees, and modes
  - Assumptions: what the environment must satisfy
  - Guarantees: what the component promises
  - Modes: named conditional behavior (normal, startup, degraded, recovery, failover)
  - Realizability: can any implementation satisfy this contract for all allowed inputs?
- 6.4 Model checking: Kind 2 vs. JKind
  - Kind 2: multi-engine (BMC, k-induction, IC3/PDR), richer contract/post-analysis workflow
  - JKind: stronger usability, traceability, integration story
  - Inductive Validity Cores, counterexample smoothing, proof certificates
- 6.5 NASA's toolchain pipeline: FRET → AGREE → CoCoSim → Copilot
  - **Lustre is not always hand-written:** GN&C engineers use Simulink → auto-generated Lustre; SCADE → certified C. Lustre is the intermediate representation, like assembly.
  - **GN&C vs. flight software:** GN&C = continuous math, dataflow, Simulink-native; flight software = event-driven state machines, hand-written C, same gap as commercial software
  - **Simulink's role:** visual programming for control systems — block diagrams map 1:1 to Lustre's synchronous dataflow semantics
  - **The spec-to-implementation gap:** closed for SCADE (auto-generated code), open for hand-written code (NASA flight software AND our Go). Mitigated with six-layer process controls.
- 6.6 **Case studies**
  - Quad-Redundant Flight Control System: AGREE contracts found contradictory requirements
  - Lift-Plus-Cruise Aircraft: realizability analysis guided requirements evolution
  - Inspection Rover: AdvoCATE + FRET + CoCoSim + Kind 2 + Event-B
- 6.7 The discipline, not the language: what to copy
  - Design reviews → "what are the assumptions?"
  - Incidents → "what invariant failed?"
  - Rollouts → "what mode are we in?"
  - Architecture → "can top-level claims be supported compositionally?"
- 6.8 **Applied: API gateway contracts**
  - Forwarding safety, single terminal outcome, no partial config visibility, revocation safety, degraded-mode guardrails, audit completeness
  - Deliberately unrealizable requirement as a teaching example

---

## Part III — AI Governance

### Chapter 7: AI Governance — Deterministic Gates for Nondeterministic Tools

> **Source material:** [general_ai.md](general_ai.md) (sections 4-6), [general.md](general.md) (slides 10, 15), [general_ai_slides.md](general_ai_slides.md)

- 7.1 Two faces of AI: AI in the product vs. AI as development tooling
- 7.2 AI in the product: data dependence, uncertainty, drift
  - ISO/PAS 8800 for AI-based vehicle systems (and what it explicitly doesn't cover)
  - Automotive SPICE 4.0 ML extensions: ML requirements, architecture, training, testing, data management
  - NIST AI RMF: trustworthiness as a governance problem, not a model-quality problem
- 7.3 AI as development tooling: generated artifacts, prompt/model variability, reviewability
  - NASA's auto-generated code requirements as a template for LLM governance
  - V&V of the tool, configuration management of inputs/outputs, defined limits/scope
  - Verification of generated code to same standard as hand-written code
- 7.4 The core principle: "Nondeterministic generation requires deterministic acceptance gates"
- 7.5 AI usage policy by zone
  - Green (free): scaffolding, boilerplate, docs, tests for non-critical code
  - Yellow (restricted): business logic, data transformations, integration code
  - Red (prohibited without full evidence): authZ logic, policy evaluation, concurrency, key management, rollout state machines
- 7.6 What "AI can propose, humans admit" means in practice
  - AI-generated code = adopted/reused code: human must explain, test, trace, defend
  - All AI artifacts must be marked, versioned, human-owned, tested, independently reviewed for P0/P1
- 7.7 Configuration management for AI tools
  - Model identity/version, prompting policies, retrieval sources, fine-tuning/custom instructions as configuration items
- 7.8 The evidence burden: AI makes fluency cheap, admissibility is still expensive
- 7.9 NASA SWEHB position: "For safety-critical applications, AI/ML is not recommended today"
- 7.10 Data governance for AI: training data quality, provenance, bias, and data lifecycle management

---

## Part IV — Operational Disciplines

### Chapter 8: Testing as Evidence, Not Just Confidence

> **Source material:** [research_testing_as_evidence.md](research_testing_as_evidence.md) (new research), [mcdc_middleware_refactoring.html](mcdc_middleware_refactoring.html) (interactive demo), scattered references in [general.md](general.md) (slide 7), [fret_slides.md](fret_slides.md) (slide 9)

- 8.1 NASA's testing philosophy: verification ("built right") vs. validation ("right product built")
- 8.2 Requirements-based testing and structural coverage (MC/DC)
  - N+1 tests for N conditions — how MC/DC reduces test count while maintaining rigor
  - Independence pairs, baselines, and what MC/DC does NOT test (all combinations)
  - Numeric/non-boolean conditions: boundary value analysis
  - Coupled/dependent conditions: design feedback, not just test feedback
  - Negated conditions: treated as atomic booleans
- 8.3 **Real-world example: Applying MC/DC and FRET to a Go middleware function**
  - The Decide → Plan → Execute refactoring pattern: separate pure decisions from side effects
  - Before: 80-line handler, 6 interleaved decisions, ~30% coverable
  - After: pure functions (MiddlewareInputs → MiddlewarePlan), 100% decision logic coverable
  - FRET requirements R1-R7 derived from the pure functions
  - MC/DC test tables: 11 test cases covering all 7 requirements
  - The Lustre connection: pure Go → Lustre nodes with CoCoSpec contracts → Kind 2 proves all 256 states
  - Three-layer verification: MC/DC (CI) + Kind 2 (design-time) + Copilot (runtime)
  - **The spec-to-implementation gap:** honest about what's closed (SCADE) and what's mitigated (hand-written code — same as NASA flight software). Six-layer mitigation matching NASA practice.
  - Interactive HTML demo: [mcdc_middleware_refactoring.html](mcdc_middleware_refactoring.html)
- 8.4 What a "test evidence pack" looks like: traceability, pass/fail criteria, off-nominal coverage, target realism
- 8.5 Automotive testing methods by ASIL (ISO 26262 Part 6)
- 8.6 Property-based testing and fuzzing as high-assurance techniques
- 8.7 Runtime verification: extending testing into production
- 8.8 Test traceability: the bidirectional requirements-to-tests-to-results chain
- 8.9 The testing pyramid in a high-assurance context
- 8.10 Applied: testing an API platform's critical paths

### Chapter 9: Runtime Monitoring and Observability as Assurance

> **Source material:** [research_runtime_monitoring.md](research_runtime_monitoring.md) (new research), [lustre.md](lustre.md) (Copilot/R2U2 references), [fret_slides.md](fret_slides.md) (signals catalog)

- 9.1 NASA runtime monitoring tools: Copilot, R2U2, Ogma
- 9.2 From formal specs to production monitors: the FRET → Copilot pipeline
- 9.3 Automotive runtime fault detection and diagnostic coverage
- 9.4 Observability as structured evidence: logs, metrics, traces as verification
- 9.5 Health monitoring patterns: circuit breakers, invariant checking, canary analysis, SLOs
- 9.6 The Signals Catalog as a living artifact
- 9.7 Applied: monitoring auth decisions, config propagation, rate limits, tenant isolation

### Chapter 10: Deployment as a Safety-Critical Operation

> **Source material:** [research_deployment_safety.md](research_deployment_safety.md) (new research), [ffdb.md](ffdb.md) (config rollout state machine)

- 10.1 NASA mission operations: FRR, LRR, Go/No-Go decisions
- 10.2 Automotive production and OTA updates: ISO 26262 Part 7, UN R156 (SUMS)
- 10.3 Progressive rollout as risk control: canary, blue-green, feature flags as mode control
- 10.4 Configuration deployment safety: immutable snapshots, validation, dry-run, "last known good"
- 10.5 Release as a governed decision: evidence packs and Release Readiness Reviews
- 10.6 Rollback and recovery: NASA abort modes applied to deployment
- 10.7 Applied: API gateway config rollout, policy updates, credential rotation, multi-region coordination

### Chapter 11: Incident Analysis and Learning Loops

> **Source material:** [research_incident_analysis.md](research_incident_analysis.md) (new research)

- 11.1 NASA's mishap investigation framework (NPR 8621.1): boards, classification, root cause
- 11.2 Fault Tree Analysis (FTA): top-down deductive analysis for software failures
- 11.3 Event Tree Analysis: forward-looking from initiating events
- 11.3b James Reason's Swiss Cheese Model — defense in depth, latent conditions, and hole alignment
- 11.4 Automotive HARA and FMEA applied to software
- 11.5 Normalization of deviance: Diane Vaughan's Challenger analysis applied to software teams
- 11.6 Learning loops: NASA LLIS, corrective vs. preventive actions, closing the loop
- 11.7 Applied: post-incident review for API platform failures, fault trees for multi-tenant isolation

---

## Part V — Governance and Organization

### Chapter 12: Organizational Independence and Team Design

> **Source material:** [research_org_independence.md](research_org_independence.md) (new research), [general.md](general.md) (slide 6)

- 12.1 NASA IV&V: three dimensions of independence (technical, managerial, financial)
- 12.2 Automotive independence requirements by ASIL
- 12.3 Decision-rights engineering: who can approve what, dissent mechanisms, escalation paths
- 12.4 Cognitive safety: confirmation bias, groupthink, automation bias, normalization of deviance
- 12.5 Review structures: code review as "structured challenge," lifecycle reviews (SRR, PDR, CDR, TRR)
- 12.6 Training and competency frameworks
- 12.7 Applied: lightweight independence for a platform team — review separation, security cadence, on-call as independence

### Chapter 13: Dependency and Supply Chain Governance

> **Source material:** [research_dependency_governance.md](research_dependency_governance.md) (new research), [general.md](general.md) (slide 9, Appendix C)

- 13.1 NASA COTS management: evaluating and qualifying third-party software
- 13.2 Automotive supplier qualification: ASPICE, DIA, tier management
- 13.3 Tool qualification: NASA and ISO 26262 Tool Confidence Levels
- 13.4 Open-source as COTS: SBOM, SLSA, Sigstore, vulnerability tracking
- 13.5 The Tool Confidence Register (worked example)
- 13.6 Applied: qualifying API gateway dependencies, Go modules, OpenAPI generators, AI assistants

### Chapter 14: Threat Modeling Meets Hazard Analysis

> **Source material:** [research_threat_modeling.md](research_threat_modeling.md) (new research)

- 14.1 NASA hazard analysis: PHA, SSHA, SHA — identification, classification, tracking
- 14.2 Automotive HARA: severity × exposure × controllability → ASIL
- 14.3 SOTIF analysis: triggering conditions, known/unknown unsafe scenarios
- 14.4 Software threat modeling: STRIDE, attack trees, LINDDUN
- 14.4b STPA (Systems-Theoretic Process Analysis) — Leveson's alternative to FTA/FMEA for software-intensive systems, including STPA-Sec for security
- 14.5 Unifying safety and security: ISO 26262 + ISO/SAE 21434 convergence
- 14.6 Fault trees for software failure modes (worked example)
- 14.7 Applied: threat modeling an API gateway, hazard analysis for multi-tenant isolation

### Chapter 15: Metrics That Matter

> **Source material:** [research_metrics.md](research_metrics.md) (new research)

- 15.1 NASA's measurement program (NPR 7150.2D Chapter 5)
- 15.2 Automotive safety metrics: fault metrics, diagnostic coverage
- 15.3 Evidence coverage metrics: requirements coverage, hazard coverage, traceability completeness
- 15.4 Defect metrics: escape rate, containment effectiveness, discovery profiles
- 15.5 Process health: requirements volatility, unresolved assumptions, rework rate
- 15.6 Operational metrics with safety framing: MTTR, MTTD, change failure rate
- 15.7 Anti-metrics and Goodhart's Law
- 15.8 Applied: building a metrics dashboard as a lightweight safety case

---

## Part VI — Putting It All Together

### Chapter 16: The Mental Model Shift

> **Source material:** [general.md](general.md) (slide 16), [general_ai_slides.md](general_ai_slides.md), [lustre.md](lustre.md) (closing)

- Features → Consequences
- Tickets → Claims
- Code → Configuration items
- Code review → Structured challenge
- Tests → Evidence
- Incidents → Process feedback
- Velocity → Safe learning rate
- AI output → "Inadmissible until justified"
- "Code is the truth" → "Behavioral contract is the truth; code is one implementation"

### Chapter 17: A Practical Adoption Playbook

> **Source material:** [research_adoption_playbook.md](research_adoption_playbook.md) (new research), [general.md](general.md) (slide 17)

- 17.1 NASA's tailoring approach: rigor proportional to consequence
- 17.2 Self-assessment: where does your team stand today? (CMMI/ASPICE mapping)
- 17.3 Phase 1 — Classify (Month 1): criticality exercise, hazard identification, risk register
- 17.4 Phase 2 — Control (Month 2): evidence requirements, two-person review, config-as-code, tool register
- 17.5 Phase 3 — Verify (Month 3): requirement-based tests, runtime monitor, rollback rehearsal, first RRR
- 17.6 Phase 4 — Sustain (Month 4+): expand scope, signals catalog, structured incidents, AI policy
- 17.7 Common pitfalls: over-adoption, checkbox compliance, cultural resistance, ossification
- 17.8 Success indicators: how to know it's working

### Chapter 18: Closing — The Future of Software Quality Is Better Evidence

> **Source material:** [general_ai_slides.md](general_ai_slides.md) (closing), [general.md](general.md) (slide 18)

- AI made software faster. It did not make it more trustworthy.
- The scarce resource is shifting from creation capacity to justified confidence.
- High-assurance teams trust: classified rigor, explicit assumptions, independent challenge, evidence that survives scrutiny.
- "AI makes fluency cheap. High-assurance engineering reminds us that admissibility is still expensive, and should be."

---

## Appendices

### Appendix A: Worked Example — Cross-Tenant Request Leakage Hazard
> **Source:** [general.md](general.md) (Appendix B)

### Appendix B: Tool Confidence Register Template
> **Source:** [general.md](general.md) (Appendix C)

### Appendix C: FRET vs. BDD Detailed Comparison
> **Source:** [fret_slides.md](fret_slides.md) (Slide 5, Appendix A)

### Appendix D: Pseudo-Lustre Contract — API Gateway Example
> **Source:** [lustre.md](lustre.md) (Appendix C)

### Appendix E: FFBD Examples for API Request Lifecycle
> **Source:** [ffdb.md](ffdb.md) (Slides 13-14)

### Appendix F: Standards Quick-Reference Card
> Condensed one-page per standard: what it covers, key sections, where to find it

### Appendix G: Worked Example — SRS Decomposition for Gateway ↔ Dashboard
> **Source:** [research_testing_as_evidence.md](research_testing_as_evidence.md) (section 1.2.1), [mcdc_middleware_refactoring.html](mcdc_middleware_refactoring.html) (section 10)
- System requirement (SyRD-REQ-0080) → component requirements → ICD → traceability tree
- Full Gateway/Dashboard example: API definition loading, fault tolerance, staleness budget
- Three decision tests: one owner → component SRS; multiple components → SyRD; contract → ICD
- DOORS + FRET project structure for multi-component systems
- Adaptation for teams without DOORS: ADRs, OpenAPI, Jira, protobuf

### Appendix H: Worked Example — MC/DC and FRET Applied to Go Middleware
> **Source:** [research_testing_as_evidence.md](research_testing_as_evidence.md) (section 1.4.7), [mcdc_middleware_refactoring.html](mcdc_middleware_refactoring.html)
- Before/after code: 80-line tangled handler → Decide → Plan → Execute pattern
- FRET requirements R1-R7, MC/DC test tables, Lustre nodes with CoCoSpec contracts
- Three-layer verification: MC/DC + Kind 2 + Copilot
- The spec-to-implementation gap: honest assessment and six-layer mitigation

### Appendix I: Glossary of Terms
> All terms from across chapters: ASIL, BMC, CMMI, ConOps, EFFBD, FFBD, FRETish, HARA, IV&V, MC/DC, MBSE, RIDM, SOTIF, SysML, etc.

---

## Source File Index

| File | Content | Used in Chapters |
|------|---------|-----------------|
| [general.md](general.md) | High-assurance overview slide deck (18+3 slides) | 1, 2, 3, 7, 8, 12, 16, 17, App A-B |
| [general_slides.md](general_slides.md) | **Near-duplicate of general.md — recommend consolidating into one canonical file** | Same as general.md |
| [general_ai.md](general_ai.md) | Long-form article on AI-era high-assurance practices | 1, 2, 7 |
| [general_ai_slides.md](general_ai_slides.md) | Slide deck on AI-era practices (different framing) | 7, 16, 18 |
| [fret_slides.md](fret_slides.md) | FRET deep dive slide deck (19+3 slides) | 4, 8, 9, App C |
| [ffdb.md](ffdb.md) | FFBD/MBSE slide deck (16 slides) | 5, 10, App E |
| [lustre.md](lustre.md) | Lustre/Kind2 deep dive (20+3 slides) | 6, 9, App D |
| [research_testing_as_evidence.md](research_testing_as_evidence.md) | **New research** — MC/DC, FRET, SRS, requirements hierarchy, middleware example | 4, 8 |
| [mcdc_middleware_refactoring.html](mcdc_middleware_refactoring.html) | **Interactive demo** — before/after middleware refactoring, MC/DC, FRET, Lustre, SRS hierarchy | 4, 6, 8 |
| [research_org_independence.md](research_org_independence.md) | **New research** | 12 |
| [research_runtime_monitoring.md](research_runtime_monitoring.md) | **New research** | 9 |
| [research_deployment_safety.md](research_deployment_safety.md) | **New research** | 10 |
| [research_incident_analysis.md](research_incident_analysis.md) | **New research** | 11 |
| [research_dependency_governance.md](research_dependency_governance.md) | **New research** | 13 |
| [research_metrics.md](research_metrics.md) | **New research** | 15 |
| [research_threat_modeling.md](research_threat_modeling.md) | **New research** | 14 |
| [research_adoption_playbook.md](research_adoption_playbook.md) | **New research** | 17 |

---

## Notes

- **Duplication:** `general.md` and `general_slides.md` are near-identical. Recommend consolidating into one canonical file.
- **Overlap:** `general_ai.md` (long-form) and `general_ai_slides.md` (slides) cover similar ground but with different depth/framing. Both are useful — article for Chapter 2 depth, slides for Chapter 7 practical framing.
- **DO-178C gap closed**: DO-178C and DO-330 are now referenced across Ch. 2, 8, 13, and relevant research files.
- **Safety case terminology added**: GSN/CAE pattern named in Ch. 1 and referenced throughout.
- **All existing files** are slide deck drafts. Book chapters will need to be rewritten as prose, expanding on the slide content.
- **Applied examples** should use a consistent fictional API platform throughout (keep the Go API management platform framing).

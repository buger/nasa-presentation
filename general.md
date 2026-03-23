Below is a full deck draft you can almost drop into slides.

I’m assuming the same modern editorial direction as the previous one: dark background, oversized typography, one dominant visual or diagram per slide, very little dense text, and a small “evidence strip” at the bottom of factual slides.

The story arc should be:

1. High-assurance software is not “normal software with stricter QA.”
2. It is a different mental model: consequence first, evidence first, assumptions explicit.
3. That model matters even more in the AI era.
4. We should not copy the bureaucracy literally.
5. We should borrow the consequence-aware rigor and apply it to our Go API platform.

---

## Deck title

**High-Assurance Software in the AI Era**
**What NASA and automotive engineering can teach a Go API platform team**

Subtitle:
**From evidence-driven safety to better product, testing, and engineering decisions**

Visual: split hero image — mission control / automotive validation lab / abstract API topology overlay.

---

## Slide 1 — Opening frame

**On slide**

**When failure is unacceptable, software stops being “just code.”**
It becomes a governed system of claims, evidence, and risk decisions.

**Talk track**

Open with the strongest reframe: the difference is not that NASA or automotive teams are “more careful.” The difference is that they develop software inside a system where consequence changes everything: org design, review structure, documentation, testing, tooling, release decisions, and even what counts as a valid artifact.

**Visual**

Full-bleed photo, with one sentence only.

---

## Slide 2 — Kill the biggest myth first

**Title**

**Myth: high-assurance means “zero defects”**
**Reality: it means disciplined control of consequence**

**On slide**

Left side, “Myth”:

* perfect software
* no mistakes
* just more process

Right side, “Reality”:

* reduce unreasonable risk
* justify residual risk
* scale rigor to consequence
* produce evidence, not just code

**Talk track**

This slide is important because it keeps the whole presentation honest. High-assurance standards do not claim that compliance magically produces error-free software. MISRA explicitly says adherence does not in itself ensure error-free robust software. NASA’s own software requirements are built around tailoring, acceptable risk, approvals, and formal risk acceptance. So the real target is not perfection; it is controlled, explicit, reviewable risk reduction. That is a much stronger and more useful idea, especially when we talk about AI. ([misra.org.uk][1])

**Visual**

A clean contrast slide: “Perfect software” crossed out; “Justified software” highlighted.

---

## Slide 3 — When is this actually used?

**Title**

**Not all software gets the same rigor**

**On slide**

Three bands:

**1. Operationally safety/mission critical**
Human life, vehicle control, mission success, irreversible harm

**2. Operationally high consequence**
Major outage, security breach, regulatory failure, cascading loss

**3. Exploratory / prototype / research**
Useful, but not allowed to silently become operational truth

**Talk track**

A key lesson from NASA is that rigor is classified, not sprayed everywhere. NASA explicitly scales requirements by software class through its Requirements Mapping Matrix. Class A covers human-rated space software; Class B covers non-human space-rated and large-scale aeronautics; Class E covers exploratory/design-concept software and cannot be safety-critical. If Class E software becomes operational, it has to be upgraded to the proper class. DO-178C (Software Considerations in Airborne Systems and Equipment Certification) is arguably the most influential high-assurance software standard globally, originating in avionics. Many NASA concepts discussed here — MC/DC coverage, tool qualification, structural coverage analysis — trace their lineage to DO-178C and its companion DO-330 (tool qualification). MC/DC (Modified Condition/Decision Coverage) is a DO-178C Level A requirement frequently adopted by NASA for safety-critical software, though not universally mandated across all NASA projects. Automotive does something similar differently: ISO 26262 applies to safety-related E/E systems and starts with item definition, hazard analysis and risk assessment, and functional safety concept. ISO 26262 uses ASIL levels (A through D, plus QM for non-safety) determined by Hazard Analysis and Risk Assessment (HARA) based on Severity, Exposure, and Controllability. SOTIF exists because ISO 26262 does not cover hazards from nominal-performance insufficiencies; it is especially aimed at systems needing situational awareness from complex sensors and algorithms, such as emergency intervention and automated driving. ISO/PAS 8800 extends this discussion to AI-based safety-related vehicle systems. ([nodis3.gsfc.nasa.gov][2])

**Visual**

A vertical “criticality ladder” with NASA and automotive examples placed on it.

---

## Slide 4 — The deepest difference vs standard software

**Title**

**The product is not only software**
**The product is an evidence-backed decision**

**On slide**

A five-row contrast:

* **Standard practice:** “Does it work?”
  **High-assurance:** “What claim are we making?”

* **Standard practice:** code is the main artifact
  **High-assurance:** code + assumptions + traceability + evidence

* **Standard practice:** team reviews itself
  **High-assurance:** independent challenge is built in

* **Standard practice:** tests increase confidence
  **High-assurance:** tests are verification evidence

* **Standard practice:** release is a delivery event
  **High-assurance:** release is a risk-acceptance event

**Talk track**

NASA’s systems engineering material makes the distinction very clear: verification asks “Was the end product realized right?” while validation asks “Was the right end product realized?” NASA IV&V then adds a third layer: objective, independent examination that can support or refute the belief that the system is correct. That is the shift. In mainstream software, we often ship when we feel confident enough. In high-assurance work, you are expected to show what was required, what was built, what was tested, what assumptions were made, and who independently challenged it. ([NASA][3])

**Visual**

A horizontal flow from “claim” to “evidence” to “approval.”

---

## Slide 5 — Engineering angle: what gets engineered is the control structure

**Title**

**Architecture is a risk-control system**

**On slide**

Hazard / mission objective
→ requirement
→ architecture control
→ implementation
→ verification
→ residual risk decision

Side notes:

* assumptions are first-class
* interfaces are safety boundaries
* traceability is mandatory on the critical path

**Talk track**

High-assurance engineering is different because it forces architecture to carry explicit control responsibilities. NASA requires software requirements to include software-related safety constraints, controls, mitigations, and assumptions between hardware, operator, and software. It also requires bidirectional traceability between higher-level requirements, software requirements, system hazards, design components, code, verifications, and nonconformances. NASA’s configuration management scope is also broader than many product teams expect: code, data, tools, models, scripts, and settings are all configuration items. Automotive SPICE 4.0 pushes the same logic into ML: ML requirements must be traced to software requirements and architecture, and ML testing traces back to both ML requirements and ML data requirements. ([NASA-STD-8739.8B][4])

**Visual**

A clean traceability chain diagram, not a giant matrix.

---

## Slide 6 — People angle: the org chart is part of the safety mechanism

**Title**

**Independence is not overhead — it is a control**

**On slide**

Three blocks:

* Development
* Assurance / Safety / Cybersecurity
* Independent V&V

Bottom strip:

* supplier capability
* escalation paths
* approved dissent

**Talk track**

This is one of the most important human lessons. NASA defines IV&V independence in three dimensions: technical, managerial, and financial. Technical independence means the IV&V team is not involved in development. Managerial independence means it is not in the same reporting chain and chooses its own analysis and test focus. Financial independence means budget pressure cannot quietly shut scrutiny down. NASA peer-review guidance also explicitly suggests bringing testing, system testing, software assurance, software safety, software cybersecurity, and IV&V personnel into reviews. And NASA expects maturity from suppliers: for Class A software, CMMI-DEV Level 3 or higher; for Class B, Level 2 or higher. Automotive SPICE exists for a similar reason: it is a capability assessment model, not just a coding guide. The big lesson is that high-assurance teams do not let one local team certify its own worldview. ([NASA-STD-8739.8B][4])

**Visual**

Triangle of roles with a bold center label: **“No single team self-certifies.”**

---

## Slide 7 — Testing angle: tests are evidence, not comfort

**Title**

**Testing gets more structured, more adversarial, and more traceable**

**On slide**

Testing must show:

* requirements coverage
* hazard coverage
* pass/fail criteria
* off-nominal conditions
* boundary conditions
* repeatability
* target platform realism
* regression proof
* code coverage with rationale

**Talk track**

NASA’s software assurance standard reads very differently from normal QA checklists. Test procedures must cover software requirements, include pass/fail criteria, include operational and off-nominal conditions including boundary conditions, and cover hazards. Unit-test results must be repeatable. Safety-critical testing is witnessed. Software must be placed under configuration management before testing. Validation is expected on the target platform or high-fidelity simulation. Code coverage must be selected, measured, tracked, and unexplained uncovered code has to be assessed for risk. NASA also requires acceptance tests for loaded or uplinked data, rules, scripts, and code that affect software behavior, and reused/COTS components are to be tested to the same level as custom software for their intended use. This is a very different attitude from “CI is green, ship it.” ([NASA-STD-8739.8B][4])

**Visual**

A layered test pyramid, but with traceability lines overlaid.

---

## Slide 8 — Product management angle: PM becomes risk governance

**Title**

**In high-assurance work, product management governs risk posture**

**On slide**

PM is responsible for:

* classifying consequence
* defining acceptance criteria
* deciding what rigor applies
* documenting tailoring
* owning residual risk decisions
* tracking quality and requirements volatility

**Talk track**

The PM lesson is subtle but huge. In ordinary software, PM often trades quality, scope, and time informally. In high-assurance work, those trades become governed decisions. NASA’s tailoring rules require rationale, risk evaluation, approvals, archival of the requirements mapping matrix, and formal acceptance of tailoring risk by the responsible manager. NASA also requires measurement programs aimed at quality, capability, process improvement, and requirements volatility. ISO 26262 Part 2 frames functional safety management as both product work and organizational capability work. So product management shifts from “prioritize the roadmap” to “manage the risk budget and evidence budget of the roadmap.” ([nodis3.gsfc.nasa.gov][5])

**Visual**

A simple loop: classify → plan → verify → accept → monitor.

---

## Slide 9 — Tooling and external V&V: tools are inside the trust boundary

**Title**

**A tool is not neutral just because it is popular**

**On slide**

For critical workflows, every important tool needs answers to:

* what is it allowed to do?
* which version/configuration is approved?
* how do we know it detects what we claim?
* what happens when it changes?

**Talk track**

This is one of the most underrated lessons for modern teams. MISRA Compliance requires a guideline enforcement plan that records tool versions, configurations, options, and evidence that the tool can detect the guideline violations it is supposed to check. NASA requires validation and accreditation of tools used to develop or maintain software. For auto-generated source code, NASA requires validation and verification of the generation tools, configuration management of tool inputs and outputs, defined limits on use, and V&V of generated code to the same standards as hand-written code. ISO 26262 Part 8 likewise explicitly includes confidence in the use of software tools as a supporting process. That logic maps directly to code generators, schema generators, CI/CD logic, static analyzers, simulators, and now AI development tools. ([misra.org.uk][6])

**Visual**

A toolchain diagram with “qualification / versioning / evidence / monitoring” tags.

---

## Slide 10 — AI changes the problem, but not the discipline

**Title**

**AI is not a replacement for rigor**
**It is a stress test of rigor**

**On slide**

Two lanes:

**AI in the product**

* data dependence
* uncertainty
* hard-to-prove behavior
* drift / unseen cases

**AI in development**

* generated artifacts
* prompt/model variability
* reviewability problems
* tool-confidence problems

Bottom line:
**Nondeterministic generation requires deterministic acceptance gates**

**Talk track**

This is where the presentation becomes contemporary. NASA’s software engineering handbook is blunt: for safety-critical or other high-criticality applications, AI/ML is not recommended today; where used as an advisor, its results should be confirmed by other means. The same handbook says that for systems requiring 100% deterministic confidence, AI/ML may not be recommended. On the development side, NASA says general non-mission-specific AI-generated code should be treated similarly to reused/open-source code, and mission-specific work should use approved secure tools. It also explicitly places AI/ML under the auto-generated source code requirement and says the data, model files, and AI-generated code all fall under that rigor. Automotive is evolving in the same direction: ISO/PAS 8800 applies to AI-based safety-related vehicle systems, and Automotive SPICE 4.0 adds ML requirements, ML architecture, ML training, ML model testing, and ML data management with explicit data-quality and traceability expectations. NIST’s AI RMF frames the broader goal as managing AI risks to improve trustworthiness. ([swehb.nasa.gov][7])

**Visual**

A split slide with “AI in the product” and “AI in the toolchain.”

---

## Slide 11 — The key takeaway for ordinary engineering teams

**Title**

**Borrow the selectivity, not the bureaucracy**

**On slide**

Six practices worth borrowing:

1. classify consequence first
2. make assumptions explicit
3. use stronger independence on critical changes
4. treat configs, rules, and data as software
5. require evidence packs on high-risk changes
6. close the loop on severe defects

**Talk track**

This is the bridge slide. The point is not to cosplay NASA. The point is to stop pretending every code path deserves the same process. High-assurance development is useful because it shows how to scale rigor according to consequence. That is exactly the discipline mainstream teams need as systems get more complex, more AI-assisted, and more dependent on invisible tooling.

**Visual**

A single strong statement with six icons, not a dense list.

---

## Slide 12 — Apply it to our case: API management in Golang

**Title**

**An API management system is a trust-and-control system**

**On slide**

Critical functions:

* authorization and policy decisions
* routing and traffic shaping
* rate limiting / quota enforcement
* config publication and rollout
* secrets / certificates / keys
* auditability of privileged changes

Possible failure modes:

* cross-tenant access
* wrong route / wrong backend
* stale or split-brain config
* rate-limit bypass
* rollback failure
* missing audit trail

**Talk track**

This is where the deck gets concrete. An API management platform is not just a convenience layer. It is the control surface for trust, traffic, isolation, and operational policy. A defect here can become a security incident, a regulatory incident, or a fleet-wide outage. So the right mental model is not “we are building an internal tool.” The right mental model is “we are building a control plane whose mistakes can propagate system-wide.”

**Visual**

Clean control-plane / data-plane diagram with red callout labels on failure points.

---

## Slide 13 — Build your own classification model

**Title**

**Create local software classes for the platform**

**On slide**

**P0 — Critical decision path**
authz engine, policy compiler/interpreter, routing decision engine, config application, key handling

**P1 — High-impact control path**
rollout controller, discovery adapters, migrations, audit ingest

**P2 — Support path**
admin UI, analytics, dashboards, docs

**P3 — Experimental path**
prototypes, internal experiments, AI-generated scaffolds, one-off utilities

Rules:

* higher consequence wins
* if a component influences P0 behavior, treat it as P0/P1
* P3 may not silently become operational

**Talk track**

This is the single most practical lesson to steal from NASA. Classify the software first, then decide the rigor. Use the “higher class wins” rule for ambiguous components. Borrow the Class E idea directly: experiments are allowed, but they are not allowed to become operational by accident. That one distinction alone improves clarity around prototypes, AI-generated helpers, and internal tooling. ([nodis3.gsfc.nasa.gov][2])

**Visual**

Architecture diagram with subsystems color-coded P0–P3.

---

## Slide 14 — What changes for the Go engineering model?

**Title**

**Move from “best practices” to “approved patterns” on the critical path**

**On slide**

For **P0/P1** code:

* explicit invariants
* constrained language patterns
* deterministic configs
* explicit concurrency ownership
* reproducible builds
* stronger release evidence

**Talk track**

For the Go team, this means defining a safer subset and a smaller set of approved patterns for critical modules. Examples:

* Ban or severely restrict `unsafe`, reflection-heavy logic, and hidden global state in P0 code.
* Make `context` usage mandatory and auditable for all networked operations.
* Use immutable config snapshots and monotonic config versioning.
* Define concurrency ownership rules so no critical goroutine lifecycle is implicit.
* Make error classes explicit: retryable, terminal, security-relevant, policy-relevant.
* Require deterministic serialization and schema versioning on all config and policy artifacts.
* Make reproducible builds, pinned dependencies, provenance, and dependency review mandatory on P0/P1.

That is the Go equivalent of “language subset + approved patterns + tool discipline.”

**Visual**

Four-quadrant slide: Spec / Build / Verify / Release.

---

## Slide 15 — An AI usage policy for the Go platform team

**Title**

**AI can propose. Humans admit.**

**On slide**

**Green**

* docs
* tests
* boilerplate adapters
* low-risk internal utilities

**Yellow**

* integration glue with full review and evidence

**Red**

* policy logic
* authz decisions
* rollout state machines
* key management
* security-sensitive migrations
* incident automation without human ownership

Required whenever AI is used:

* mark artifact as AI-assisted
* record tool/model/version
* assign human owner
* add tests and rationale
* require independent review for P0/P1

**Talk track**

This is where the NASA guidance becomes directly useful. Treat AI-generated code like adopted or reused code, not like trusted authorship. On critical paths, the bar is not “did AI help?” The bar is “can a human explain it, test it, trace it, and defend its admission?” For P0/P1, AI should help with supporting work, not silently author the logic that decides authorization, routing, or rollout behavior. NASA’s auto-generation rules and current AI handbook support exactly this direction. ([swehb.nasa.gov][7])

**Visual**

A clean green/yellow/red policy table.

---

## Slide 16 — The mental model shifts

**Title**

**How the team should think differently**

**On slide**

From → To

* **features** → **consequences**
* **tickets** → **claims**
* **code** → **configuration items**
* **code review** → **structured challenge**
* **tests** → **evidence**
* **incidents** → **process feedback**
* **velocity** → **safe learning rate**
* **AI output** → **inadmissible until justified**

**Talk track**

This is the “roots” slide. The real lesson from NASA/automotive is not paperwork. It is a more serious epistemology. You do not ask only “did we build something clever?” You ask “what are we asserting, what evidence supports it, what assumptions does it rest on, and who independently challenged those assumptions?”

**Visual**

Minimal, elegant from/to pairs.

---

## Slide 17 — A practical 90-day adoption plan

**Title**

**What this looks like in practice**

**On slide**

**Month 1 — classify**

* define P0–P3
* map top 10 hazards / failure modes
* define invariants for P0/P1

**Month 2 — control**

* evidence pack template
* review-role separation
* tool confidence register
* AI usage policy
* config/data/version controls

**Month 3 — verify**

* property tests
* fuzzing
* shadow/differential testing
* rollout rehearsal
* audit completeness checks

Metrics:

* % P0 changes with evidence pack
* P0 defect escape rate
* requirements volatility on P0/P1
* unresolved assumption count
* time to explain a critical incident

**Talk track**

Start small and surgical. Do not rewrite the whole org. First classify the platform. Then create a thin evidence model for critical changes. Then harden verification and release gates only where consequence justifies it. NASA’s own measurement model is useful here because it treats measurements as a way to manage quality, process capability, and improvement — not just output metrics — and it explicitly includes requirements volatility. ([nodis3.gsfc.nasa.gov][8])

**Visual**

Three-stage roadmap with one metric strip at the bottom.

---

## Slide 18 — Close

**Title**

**The point is not to make every team NASA**
**The point is to make consequence visible before failure does**

**On slide**

High-assurance development teaches four durable lessons:

* classify rigor
* make assumptions visible
* require independent challenge
* admit artifacts only with evidence

**Talk track**

End here: AI makes fluency cheap. High-assurance engineering reminds us that admissibility is still expensive, and should be. That is not a bug in the process. That is what protects teams from mistaking polished output for justified truth.

**Visual**

Minimal closing slide. One line only.

---

# Three appendix slides worth adding

## Appendix A — Example artifact stack

Show a simple stack:

* system definition
* hazard / failure-mode log
* requirements map
* traceability map
* release evidence pack
* tool confidence register
* AI usage register

Purpose: make the audience see that “rigor” is a set of visible artifacts, not an abstract slogan.

---

## Appendix B — One concrete example

**Hazard:** cross-tenant request leakage
**Goal:** no request can be evaluated under another tenant’s policy context
**Requirements:** immutable tenant context propagation, deterministic policy evaluation, schema compatibility rules
**Evidence:** property tests, fuzzing, shadow traffic, audit checks, rollback test

This appendix makes the philosophy tangible.

---

## Appendix C — Tool confidence register example

Columns:

* tool
* version
* purpose
* criticality
* approved scope
* validation method
* known limitations
* change owner
* next requalification date

Rows:

* OpenAPI generator
* policy compiler
* DB migration tool
* CI pipeline templates
* AI assistant / code generator

This is a strong bridge from NASA/automotive thinking to modern platform work.

---

# Design notes for the modern style

Use a dark editorial theme, large titles, and one visual idea per slide. Avoid compliance-heavy tables on the main path. Use diagrams instead:

* Slide 3: criticality ladder
* Slide 5: traceability chain
* Slide 6: org-control triangle
* Slide 7: evidence pyramid
* Slide 12: API control-plane hazard map
* Slide 13: subsystem classification map
* Slide 17: 90-day roadmap

The strongest recurring visual motif is:
**Claim → Control → Evidence → Decision**

This pattern is known formally as a safety case (or assurance case), often structured using Goal Structuring Notation (GSN) or Claims-Arguments-Evidence (CAE) frameworks.

That motif ties engineering, testing, PM, and AI together.

---

# The core message to keep repeating in the talk

**High-assurance teams do not trust process theater.**
They trust classified rigor, explicit assumptions, independent challenge, and evidence that survives scrutiny.

That is exactly the mindset worth bringing back into everyday software engineering — especially for an API platform team building increasingly AI-assisted systems.

[1]: https://www.misra.org.uk/app/uploads/2023/03/MISRA-C-2012-AMD4.pdf "https://www.misra.org.uk/app/uploads/2023/03/MISRA-C-2012-AMD4.pdf"
[2]: https://nodis3.gsfc.nasa.gov/displayDir.cfm?Internal_ID=N_PR_7150_002D_&page_name=AppendixD "https://nodis3.gsfc.nasa.gov/displayDir.cfm?Internal_ID=N_PR_7150_002D_&page_name=AppendixD"
[3]: https://www.nasa.gov/reference/5-3-product-verification/ "https://www.nasa.gov/reference/5-3-product-verification/"
[4]: https://standards.nasa.gov/sites/default/files/standards/NASA/B/0/NASA-STD-87398-Revision-B.pdf "https://standards.nasa.gov/sites/default/files/standards/NASA/B/0/NASA-STD-87398-Revision-B.pdf"
[5]: https://nodis3.gsfc.nasa.gov/displayDir.cfm?Internal_ID=N_PR_7150_002D_&page_name=Chapter2 "https://nodis3.gsfc.nasa.gov/displayDir.cfm?Internal_ID=N_PR_7150_002D_&page_name=Chapter2"
[6]: https://misra.org.uk/app/uploads/2021/06/MISRA-Compliance-2020.pdf "https://misra.org.uk/app/uploads/2021/06/MISRA-Compliance-2020.pdf"
[7]: https://swehb.nasa.gov/plugins/viewsource/viewpagesrc.action?pageId=187203738 "https://swehb.nasa.gov/plugins/viewsource/viewpagesrc.action?pageId=187203738"
[8]: https://nodis3.gsfc.nasa.gov/displayDir.cfm?Internal_ID=N_PR_7150_002D_&page_name=Chapter5 "https://nodis3.gsfc.nasa.gov/displayDir.cfm?Internal_ID=N_PR_7150_002D_&page_name=Chapter5"


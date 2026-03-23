Below is a **super-detailed iceberg-style presentation draft** you can turn into slides. I wrote it so the audience can start with zero background, then descend into semantics, tooling, NASA usage, and finally the **“what should a Go/API team learn from this?”** section.

A good visual treatment is to make the deck itself feel like an iceberg: light, spacious slides at the surface; darker, denser slides as you go down; one small “depth marker” in a corner that moves deeper each slide. Keep the first five slides mostly conceptual, and save code, contracts, and counterexamples for later.

---

## Surface

### Slide 1 — Title

**Lustre, Contracts, Kind 2, JKind — and What a Go Team Can Steal from Safety-Critical Engineering**

**On the slide**

* Lustre = a synchronous dataflow language
* Contracts = explicit assumptions + guarantees
* Kind 2 / JKind = proof engines for safety properties
* Goal: a better mental model for systems that evolve over time

**Talk track**
Open by disambiguating: this is **not** the Lustre filesystem. This talk is about the Lustre programming language for **reactive systems**—systems that continuously interact with an environment—and the verification ecosystem around it. Lustre was created by Nicolas Halbwachs, Paul Caspi, and colleagues at Verimag/CNRS in Grenoble, France, starting in the mid-1980s. The big idea is that the same discipline used in flight-critical and model-based engineering can teach software teams to think more clearly about time, modes, assumptions, and interface behavior. Lustre also sits inside industrial environments like SCADE (Safety-Critical Application Development Environment), by Ansys/Esterel Technologies, which is the industrial/commercial embodiment of Lustre, widely used in DO-178C-certified avionics software. NASA-facing workflows use related tools such as FRET, AGREE, and CoCoSim. ([Mathematical Sciences Homepage][1])

**Visual**

* One-line subtitle: “From requirements → contracts → proofs → monitors”
* Tiny note at bottom: “Not the filesystem”

---

### Slide 2 — Why this family of tools exists

**Why ordinary software thinking is not enough for reactive systems**

**On the slide**

* Reactive systems live in continuous interaction
* Time matters as much as logic
* Many failures are about **sequences**, not single states
* English requirements often hide contradictions

**Talk track**
Lustre was designed for systems that do not run once and terminate, but instead **continuously react** to an environment that cannot wait. The classic Lustre paper frames these as systems with timing constraints, parallel interaction, and heavy reliability demands—automatic control, monitoring, signal processing, communication protocols, and other fast-reacting systems. NASA and AGREE case studies also show that the act of formalizing requirements often exposes errors before code is even involved. ([Mathematical Sciences Homepage][1])

**Visual**

* Left side: “CRUD / transformational software”
* Right side: “Reactive / ongoing behavior”
* Timeline graphic with “input → state → output” repeated at each tick

---

### Slide 3 — The core Lustre mental model

**Think in streams, not in statements**

**On the slide**

* A variable is a **stream** of values over logical time
* A node is a **component** with inputs, outputs, and memory
* `pre x` = previous value
* `a -> b` = initial value, then recurrence

**Talk track**
The mental move is simple but powerful: in Lustre, variables are not “boxes” that get mutated line by line; they are **time-indexed signals**. A node is a component defined by equations over those streams. This rests on the synchronous hypothesis — the assumption that computation completes within one logical clock tick, which simplifies reasoning about timing but requires careful mapping to real-time systems. This style was deliberately made close to formalisms familiar to engineers—block diagrams, operator networks, and even differential-equation style thinking—which is one reason it translates so naturally into control and safety engineering. ([www-verimag.imag.fr][2])

**Visual**

* A timing diagram with a few signals across ticks 0, 1, 2, 3
* Small annotation for `pre` and `->`

---

### Slide 4 — Tiny example

**A system of equations with memory**

**On the slide**

```lustre
node counter(step: int) returns (out: int);
let
  out = 0 -> pre(out) + step;
  --%PROPERTY out >= 0;
tel
```

**Talk track**
Use this to show the feel of the language. `out` starts at `0`, then at each tick becomes its old value plus `step`. The property line asks the checker to prove the invariant. Note that with `step` unconstrained, this property will produce a counterexample (if step can be negative, out can go below zero). This is intentional — it demonstrates how the checker works. That immediately gives you the two core outcomes of the ecosystem: either the property is proven for all executions, or the tool returns a counterexample trace showing how it fails. Kind 2 also supports explicit `check` syntax, reachability properties, and conditional checks like `check A provided B;` to guard against vacuous truths. ([Kind UIowa][3])

**Visual**

* Animate the value of `out` across a few ticks
* Then show a green “proved” or red “counterexample” fork

---

### Slide 5 — Why engineers love this style

**It feels more like classical engineering than ordinary application code**

**On the slide**

* Close to block diagrams
* Time is explicit
* Side effects are minimized
* The same formalism can express both behavior and properties

**Talk track**
This is where you bridge to classical engineering. The original Lustre work explicitly says the language is close to common description tools in control and monitoring domains, and that its synchronous interpretation makes time manageable in programs. It also notes that the formalism is close to temporal logic, which helps unify “what the system does” and “what must always be true about it.” That is a huge mindset shift compared with ordinary backend code, where behavior and requirements are usually split across prose docs, tests, and implementation. ([Mathematical Sciences Homepage][1])

**Visual**

* Side-by-side: block diagram vs Lustre equations
* Caption: “software as a dynamical system”

---

## Just below the waterline

### Slide 6 — Contracts

**Assumptions, guarantees, and realizability**

**On the slide**

* **Assume**: what the environment must satisfy
* **Guarantee**: what the component promises
* **Mode**: a named situation → behavior rule
* **Realizability**: can any implementation satisfy the contract?

**Talk track**
This is the most important slide. In Kind 2’s contract model, assumptions describe legal use; guarantees describe behavior under those assumptions; and modes let you name case-based behavior as “when this situation holds, that response must hold.” Assumptions cannot depend on current outputs, because the environment cannot control them. Realizability then asks a deeper question than consistency: **is there any implementation at all** that could satisfy the contract for every allowed input? ([Kind UIowa][3])

**Visual**

* A box with inputs on the left, outputs on the right
* “Environment assumptions” above the inputs
* “Component guarantees” above the outputs
* “Modes” as colored overlays

---

### Slide 7 — Modes are the hidden superpower

**Most requirements are really mode logic**

**On the slide**

* Normal operation
* Startup
* Degraded mode
* Recovery / failover
* Safety latch / fallback

**Talk track**
Kind 2 extends plain assume/guarantee contracts with **modes** because many real requirements are not absolute; they are conditional: “if we are in this situation, then the component must behave like this.” Kind 2 also performs defensive checks: it checks that modes are exhaustive enough under the assumptions and that they are reachable, so the spec does not silently pass because an important case was forgotten. This is a big improvement over burying all behavior in ad hoc `if situation => behavior` formulas. ([Kind UIowa][4])

**Visual**

* A state/mode diagram with arrows labeled by requires/ensures
* Caption: “Modes make requirements legible”

---

### Slide 8 — Kind 2

**What Kind 2 is good at**

**On the slide**

* Multi-engine parallel SMT-based model checking
* Strong contract and compositional workflow
* Built-in support for modes, contract checking, test generation
* Advanced extras: proof certificates, contract monitor, assumption generation

**Talk track**
Kind 2 is a **multi-engine, parallel, SMT-based** checker for Lustre programs. By default it runs bounded model checking, k-induction, invariant generation, and IC3-style engines in parallel. What makes it especially interesting for a presentation is how contract-centric the workflow is: you get compositional reasoning over subnodes by contract abstraction, contract realizability checking, mode-based test generation, contract monitoring for executables, proof certificates, and even **assumption generation** to help discover missing environmental assumptions. ([Kind UIowa][5])

**Visual**

* Engine cloud: BMC / k-induction / IC3 / invariants
* Then arrows to: proofs, counterexamples, tests, monitors, certificates

---

### Slide 9 — JKind

**What JKind is good at**

**On the slide**

* Infinite-state safety model checker for Lustre
* Parallel engines: k-induction, PDR, invariants
* Strong usability story
* Signature features: IVCs and counterexample smoothing

**Talk track**
JKind is also an SMT-based checker for Lustre, but its design emphasis is especially visible in the **quality of feedback**. The JKind paper highlights two standout features: **Inductive Validity Cores (IVCs)**, which tell you which parts of the model were actually needed for a proof, and **counterexample smoothing**, which makes failing traces easier for humans to understand and easier to use for testing. IVCs were pioneered by JKind; Kind 2 later added IVC support as well. JKind was designed to be embedded in user-facing tools, and it is used as a backend for AGREE, SpeAR, SIMPAL, and internal certification/test-generation workflows. ([arXiv][6])

**Visual**

* One green path labeled “Proof” with a tiny “IVC”
* One red path labeled “Failure” with “smoothed trace”

---

### Slide 10 — Kind 2 vs JKind

**How to explain the difference without making it tribal**

**On the slide**

* Kind 2: stronger contract workflow and post-analysis ecosystem
* JKind: stronger usability, traceability, and integration story
* Both: Lustre + SMT + proofs/counterexamples
* In practice: many toolchains use one or both

**Talk track**
Do not frame this as a winner-loser slide. Frame it as “different strengths.” Kind 2’s current documentation exposes a wider set of contract-centric features—contract checking, assumption generation, test generation, contract monitoring, proof certificates, IVCs, minimal cut sets. JKind’s published identity emphasizes a compact, user-facing, integration-friendly model checker with particularly strong proof traceability and human-friendly counterexamples. NASA’s FRET ecosystem even supports **both** Kind 2 and JKind for realizability analysis. ([Kind UIowa][7])

**Visual**

* Two columns, but not a scorecard
* Tagline: “Two lenses on the same discipline”

---

## Deeper down

### Slide 11 — Where NASA and related workflows use this

**Requirements → architecture → model → monitor**

**On the slide**

* **FRET**: structured natural-language requirements + realizability
* **AGREE**: architectural assume/guarantee reasoning over AADL
* **CoCoSim**: Simulink/Stateflow → Lustre → model checking
* **Copilot/monitoring**: runtime monitors from requirements

**Talk track**
This is the lifecycle slide. FRET, developed at NASA Ames, lets engineers write requirements in restricted natural language (“FRETish”), formalize them, and analyze consistency/realizability. AGREE works at the architecture level: it annotates AADL components with assumptions and guarantees, translates to Lustre, and uses a backend model checker—AGREE historically used JKind as its primary backend but can also use Kind 2—to prove layer-by-layer properties. CoCoSim translates Simulink and Stateflow models to Lustre, annotates them with assume/guarantee contracts, and verifies them with tools such as Kind 2 and JKind. FRET also connects to Copilot to generate runtime monitors for C programs. ([NASA Technical Reports Server][8])

**Visual**

* Horizontal pipeline diagram:

  * Requirements (FRET)
  * Architecture (AGREE/AADL)
  * Model (CoCoSim/Simulink)
  * Executable + monitors

---

### Slide 12 — Case study 1: Quad-Redundant Flight Control System

**Why compositional verification matters**

**On the slide**

* NASA Transport Class Model flight-control example
* AGREE contracts across hierarchy
* Formalization found requirement defects
* Model checking found requirement/implementation mismatch
* Realizability found contradictory requirements

**Talk track**
This case is gold for your presentation because it shows the full value chain. The AGREE/QFCS study used both Kind 2 and JKind on a NASA flight-control architecture. The team reports that errors were found in three ways: during formalization of English requirements, during property proofs against the design, and during realizability analysis. One striking example: two requirements about actuator gain became contradictory when two failure conditions held simultaneously; realizability exposed the contradiction, and the fix was to introduce a clear order of precedence. The authors’ lesson is exactly the kind of thing a software team should hear: high-level requirements must be **precise but abstract enough** to compose, and proof failures often reveal requirement problems rather than code problems. ([loonwerks.com][9])

**Visual**

* Hierarchical component view: FCS → FCC → subcomponents
* One red “contradiction” example box

---

### Slide 13 — Case study 2: Lift-Plus-Cruise aircraft requirements

**Realizability before implementation**

**On the slide**

* Requirements captured in FRETish
* Mode-heavy behavior for aircraft phases
* Realizability guided requirement evolution
* The same formalization later supported monitor generation

**Talk track**
The Lift-Plus-Cruise work is useful because it shows that the point is not only proving code. The report says realizability analysis was **crucial for guiding the evolution of the requirements** themselves. In other words, formal analysis is not just a final gate; it is a design partner. The same FRET workflow was then used to generate runtime monitors, which reinforces the idea that a good specification can serve multiple roles: clarification, analysis, testing, and runtime checking. ([NASA Technical Reports Server][10])

**Visual**

* Aircraft mode graphic: hover / transition / forward flight
* Below it: “requirements → realizability → monitors”

---

### Slide 14 — Case study 3: Inspection Rover

**Formal methods influence the design itself**

**On the slide**

* AdvoCATE + FRET + CoCoSim + Kind 2 + Event-B
* Modular robotic / cFS-style architecture
* Assurance case integration
* Designing with formal methods in mind changed the system design

**Talk track**
This case study is especially relevant to software teams because it is about integration. The report says robotic systems and cFS-like middleware are naturally modular, which helps an integrated verification approach. It also explicitly says that **developing with formal methods in mind from the outset can influence the design** and make it more amenable to verification. That is a profound lesson: this style is not only a checking toolchain; it is a way of shaping architecture early. ([NASA Technical Reports Server][11])

**Visual**

* Toolchain map feeding an assurance case
* Emphasize “early design influence”

---

## Deep water

### Slide 15 — What this style teaches any engineering team

**The mental model shift**

**On the slide**

* From “functions” to **behavior over time**
* From hidden dependencies to **explicit assumptions**
* From giant integration tests to **compositional reasoning**
* From “the spec is a PDF” to **the spec is executable**
* From pass/fail to **proofs, counterexamples, traceability, monitors**

**Talk track**
This is your thesis slide. The lesson is not “everyone should become a formal-methods specialist.” The lesson is that high-reliability engineering gets better when assumptions are explicit, modes are named, properties are stated over time, and architecture is designed so that local contracts can support system-level claims. The QFCS work shows how formalization, proof, and realizability expose different kinds of defects. JKind’s IVC work shows that proof traceability matters. Kind 2’s contract-monitor workflow shows the spec can survive past design time and become a test oracle or runtime checker. ([loonwerks.com][9])

**Visual**

* Five “from → to” arrows
* The center label: “Discipline of behavior”

---

### Slide 16 — Applying this to a Go API management system

**Do not copy the language; copy the discipline**

**On the slide**

* Treat the system as a set of **temporal components**
* Model explicit **modes**
* Give each component **assumptions and guarantees**
* Define a few non-negotiable **system invariants**
* Turn important guarantees into **tests and monitors**

**Talk track**
For a Go API management system, I would not argue for rewriting the whole product in Lustre. I would argue for borrowing the **contract-first, time-aware, mode-aware** way of thinking. Your system still has streams: requests, config versions, token revocations, quota counters, rollout events, backend health, retry behavior. Your architecture still has components: ingress, router, authn/authz, policy engine, rate limiter, config distributor, circuit breaker, audit pipeline. The NASA rover work is a strong reminder that designing with analyzability in mind changes the architecture for the better; the FRET/Copilot and Kind 2 monitor workflows show that specifications can keep paying dividends after design. ([NASA Technical Reports Server][11])

**Visual**

* Component map for an API gateway/control plane
* Small labels: assumptions / guarantees / modes

---

### Slide 17 — Concrete examples for your API system

**What the contracts might look like**

**On the slide**

* **Normal mode**: all dependencies healthy, fresh policy snapshot loaded
* **Degraded mode**: auth backend down, cache allowed under TTL
* **Rollout mode**: config changing, old/new snapshots coexist
* **Recovery mode**: dependency restored, cache gradually drained

**Speaker examples**
These are **my proposed translations** of the Lustre/contract mindset into your domain:

1. **Forwarding safety**
   `forwarded(req) => route_exists(req) and authz_ok(req) and quota_ok(req)`

2. **Single terminal outcome**
   Every request must end in exactly one of: forwarded, rejected, timed_out.

3. **No partial configuration visibility**
   A request must be evaluated against one complete policy snapshot, never a half-applied rollout.

4. **Revocation safety**
   After `revocation_ack(key)`, no later request using that key may be forwarded.

5. **Degraded-mode guardrail**
   In degraded mode, forwarding is allowed only when the cached authorization decision is still fresh.

6. **Audit completeness**
   Every forwarded or rejected request must produce an audit event with the same correlation id.

Then add one deliberately impossible requirement to teach realizability:
“Never reject a valid request, never exceed quota, add no latency, and keep serving normally through total datastore outage.”
That sounds good in a meeting and is exactly the kind of thing realizability analysis is meant to punish.

**Talk track**
Explain that the point is to convert vague operational goals into explicit behavior claims over time. Realizability thinking is especially valuable here because backend teams often write contradictory reliability goals without noticing: “always available,” “strictly consistent,” “never stale,” “instant rollback,” “no performance hit.” The QFCS case is the cautionary tale: contradictory requirements often look harmless until a checker forces them into the same state. ([Kind UIowa][12])

**Visual**

* A request life-cycle diagram with invariant callouts
* A red “unrealizable wish list” box

---

### Slide 18 — What changes in day-to-day engineering

**The practical team habits to adopt**

**On the slide**

* Design reviews ask: “what are the assumptions?”
* Incidents ask: “what invariant failed?”
* Rollouts ask: “what mode are we in?”
* Architecture asks: “can top-level claims be supported compositionally?”
* Monitoring asks: “which guarantees should survive into production?”

**Talk track**
This is where you make it feel operational rather than academic. In this mindset, a design review is not only “is the code clean?” but also “what assumptions about clocks, caches, retries, ordering, and dependency health are we making?” A production incident is not only “what exception happened?” but “which invariant or contract clause was violated?” JKind’s proof-traceability idea maps naturally to policy and compliance work: which rules really support which guarantees? Kind 2’s contract monitor idea maps naturally to replay-based verification and runtime checking. ([arXiv][6])

**Visual**

* Five icons: review, incident, rollout, architecture, monitoring

---

### Slide 19 — Adoption plan

**How to pilot this without boiling the ocean**

**On the slide**

* Pick one slice: auth + policy, or rollout safety
* Write 10–20 structured requirements
* Turn them into assumptions, guarantees, and modes
* Review counterexamples with the team
* Turn the strongest guarantees into runtime monitors/tests

**Talk track**
Start small. The best pilot is a narrow path with expensive failures: configuration rollout, authorization/policy enforcement, or quota/rate-limit enforcement. Force the team to write explicit assumptions and named modes. Then use failing traces and contradictions as design-review inputs, not as proof that the exercise failed. The FRET and monitor-generation workflows are a good model here: one formalization can serve analysis first and monitoring later. ([NASA Technical Reports Server][8])

**Visual**

* Five-step pilot loop:

  * requirements
  * contract
  * analyze
  * refine
  * monitor

---

### Slide 20 — Limits and honesty

**What not to oversell**

**On the slide**

* This style is strongest for clean, stateful, temporal behavior
* It is not a silver bullet for all distributed-systems complexity
* Asynchrony, retries, partitions, and eventual consistency need careful modeling
* The goal is sharper design, not magic certainty

**Talk track**
Be explicit about the limits. The QFCS study notes that synchronous execution was a fair assumption for that design, while support for asynchronous or quasi-synchronous components was still being added. That is the right note of humility for your Go audience: Lustre’s synchronous worldview is a fantastic discipline for sampled, stateful, mode-driven behavior, but distributed backend behavior often needs additional abstractions. The real takeaway is not “pretend your system is synchronous”; it is “make time, assumptions, and behavior explicit enough that you can reason about them.” ([loonwerks.com][9])

**Visual**

* Green zone: stateful control logic, rollout logic, policy logic
* Yellow zone: distributed coordination, partitions, eventual consistency

---

## Appendix / Q&A backup

### Appendix A — When to choose Kind 2 vs JKind

**Kind 2 first**

* You want richer contract workflows
* You care about contract realizability checks, assumption generation, test generation, contract monitoring, proof certificates, or a larger post-analysis toolbox

**JKind first**

* You want especially good human feedback from proofs/failures
* You care about IVC traceability, smoothed counterexamples, Java embedding, and integration into user-facing tools

**Both**

* Your surrounding workflow already supports both, as in FRET realizability

These are not mutually exclusive ecosystems; they are overlapping tools with different strengths. ([Kind UIowa][5])

---

### Appendix B — Advanced features worth showing if the audience is strong

**Kind 2**

* Compositional reasoning by contract abstraction
* Contract checking with deadlocking traces for unrealizable contracts
* Assumption generation for missing environment constraints
* Contract monitor for checking executable I/O traces against guarantees and modes
* Proof certificates in SMT-LIB 2 and LFSC formats

**JKind**

* Inductive Validity Cores for proof traceability
* Counterexample smoothing
* Advice/re-verification workflows
* Backend role in AGREE, SpeAR, and other user tools

These are the slides that make the deck feel “serious” to a technical audience. ([Kind UIowa][13])

---

### Appendix C — One pseudo-Lustre slide for the Go audience

**Title:** “A gateway contract, written like an engineer would write a control contract”

```lustre
node gateway(req_ok, route_ok, auth_ok, quota_ok,
             auth_backend_up, cache_fresh: bool)
returns (allow: bool);
(*@contract
  guarantee allow => req_ok and route_ok and quota_ok;

  mode normal (
    require auth_backend_up;
    ensure  allow => auth_ok;
  );

  mode degraded (
    require not auth_backend_up and cache_fresh;
    ensure  allow => route_ok and quota_ok;
  );
*)
let
  allow = req_ok and route_ok and quota_ok and
          (auth_ok or (not auth_backend_up and cache_fresh));
tel
```

**Talk track**
Tell the audience this is not production code. It is a way of saying: “Here is the behavior claim we think we are implementing.” The benefit is that architecture, code, tests, and runtime checking now have one conceptual anchor. The shape of this example is adapted from Lustre’s assume/guarantee and mode style rather than copied from a NASA artifact. Its purpose is to show how a backend rule set can be made explicit, not to claim that the backend is literally synchronous. The underlying contract and mode style comes directly from Kind 2’s input and semantics model. ([Kind UIowa][3])

---

## Good opening line

“Most software teams treat requirements as prose, architecture as boxes, and correctness as testing. This ecosystem asks a harsher question: **what behavior over time are we actually promising, under which assumptions, and can that promise even be implemented?**”

## Good closing line

“The deepest lesson from Lustre and its tooling is not a language choice. It is an engineering posture: **make time explicit, make assumptions explicit, make modes explicit, and let counterexamples argue with your requirements before production does.**”

My recommendation is to build **slides 1–14 as the main talk** and use **slides 15–20 as the custom section for your Golang/API audience**.

[1]: https://homepage.cs.uiowa.edu/~tinelli/classes/181/Spring08/Papers/Halb91.pdf "https://homepage.cs.uiowa.edu/~tinelli/classes/181/Spring08/Papers/Halb91.pdf"
[2]: https://www-verimag.imag.fr/The-Lustre-Programming-Language-and "https://www-verimag.imag.fr/The-Lustre-Programming-Language-and"
[3]: https://kind.cs.uiowa.edu/kind2_user_doc/2_input/1_lustre.html "https://kind.cs.uiowa.edu/kind2_user_doc/2_input/1_lustre.html"
[4]: https://kind.cs.uiowa.edu/kind2_user_doc/9_other/2_contract_semantics.html "https://kind.cs.uiowa.edu/kind2_user_doc/9_other/2_contract_semantics.html"
[5]: https://kind.cs.uiowa.edu/kind2_user_doc/home.html "https://kind.cs.uiowa.edu/kind2_user_doc/home.html"
[6]: https://arxiv.org/pdf/1712.01222 "https://arxiv.org/pdf/1712.01222"
[7]: https://kind.cs.uiowa.edu/kind2_user_doc/ "https://kind.cs.uiowa.edu/kind2_user_doc/"
[8]: https://ntrs.nasa.gov/citations/20220007610 "https://ntrs.nasa.gov/citations/20220007610"
[9]: https://loonwerks.com/publications/pdf/backes2015nfm.pdf "https://loonwerks.com/publications/pdf/backes2015nfm.pdf"
[10]: https://ntrs.nasa.gov/api/citations/20220017032/downloads/TechnicalReport_Lift_Plus_Cruise_FRET_case_study%20%284%29.pdf "https://ntrs.nasa.gov/api/citations/20220017032/downloads/TechnicalReport_Lift_Plus_Cruise_FRET_case_study%20%284%29.pdf"
[11]: https://ntrs.nasa.gov/api/citations/20205011049/downloads/FOLRover_TR_NASATemplate%20%284%29.pdf "https://ntrs.nasa.gov/api/citations/20205011049/downloads/FOLRover_TR_NASATemplate%20%284%29.pdf"
[12]: https://kind.cs.uiowa.edu/kind2_user_doc/9_other/12_contract_check.html "https://kind.cs.uiowa.edu/kind2_user_doc/9_other/12_contract_check.html"
[13]: https://kind.cs.uiowa.edu/kind2_user_doc/1_techniques/1_techniques.html "https://kind.cs.uiowa.edu/kind2_user_doc/1_techniques/1_techniques.html"

---

## Technical Deep Dive: Simulink, CoCoSim, and the Complete Toolchain (added 2026-03-16)

### How Simulink Connects to the Lustre Ecosystem

Many NASA flight systems are designed as **Simulink** block diagrams. The toolchain connects as follows:

1. **FRET** formalizes requirements and maps variables to Simulink ports (Inport→Input, Outport→Output)
2. **CoCoSim** translates the entire Simulink model into equivalent **Lustre** code, and attaches FRET's **CoCoSpec** contracts (an extension of Lustre for mode-aware assume-guarantee reasoning)
3. **Kind 2** / JKind / Zustre perform SMT-based model checking on the generated Lustre code

This means engineers can write requirements in FRET, model the system in Simulink, and prove that the Simulink model satisfies ALL requirements for ALL possible inputs — mathematical proof, not testing.

### CoCoSpec: The Contract Language

CoCoSpec extends Lustre to support:
- **Assume/guarantee contracts** on Lustre nodes
- **Mode-aware contracts** (different guarantees in different operating modes)
- **Compositional verification** (prove subsystem contracts, then compose at system level)

### FRET's Two Analysis Paths

FRET produces formulas in past-time metric LTL (pmLTL). These feed two distinct paths:

**Path A (Design-Time Proof):** pmLTL → CoCoSpec contracts → combined with Simulink model via CoCoSim → translated to Lustre → Kind 2 proves properties for ALL states using SMT solvers

**Path B (Runtime Monitoring):** pmLTL → JSON export (SMV + Lustre syntax + variable metadata) → Ogma consumes JSON → generates Copilot Haskell spec → Copilot compiles to C99 runtime monitors (constant memory, zero allocation) → deployed to ROS 2 / NASA cFS / F Prime

### Ogma: The Platform Glue Layer

Ogma accepts FRET JSON, Copilot specs, Lustre specs, or diagrammatic formats (DOT/Mermaid). For each target platform it generates a complete application scaffold:

- **ROS 2:** CMakeLists.txt, C++ monitoring node (subscribes to topics, converts to C types, calls Copilot step(), publishes violations), Dockerfile
- **NASA cFS:** C application with CFE_SB_Subscribe(), message dispatching, global C variables, step() calls
- **F Prime:** .fpp port definitions, C++ implementation, CMake config

Ogma uses a **Handlebars template system** with variables like `{{variables}}`, `{{msgIds}}`, `{{triggers}}`.

### Doorstop's Role

Doorstop is purely a requirements management tool — YAML/Markdown files in git with traceability links. It connects to FRET via **bidirectional Markdown import/export**. No direct connection to Lustre, Kind 2, Copilot, or Ogma. In the Space ROS toolchain: Doorstop handles tracking/traceability, FRET handles formalization/analysis.

### Variable Binding in FRET

Variables are NOT imported from code automatically. They are free-form identifiers classified in FRET's **Glossary**:
- Role: Input / Output / Internal (needs Lustre assignment) / Function
- Types: boolean, integer, double, real
- Autocomplete from glossary for consistency
- For Simulink: maps directly to port types

Internal variables require assignment expressions written in **Verimag Lustre v6 syntax** — this is where the Lustre language directly enters FRET's workflow.

Sources: FRET GitHub (writingReqs.md, copilot.md, cocosim.md, realizabilityManual.md), NASA Ogma GitHub, Copilot GitHub, Space ROS docs, NTRS 20220000049, NTRS 20220007510.

---

## Architectural Prerequisite: Why Modularity Is Required (added 2026-03-16)

### The Synchronous Assumption and Its Limits

Lustre's core abstraction — variables as streams over a logical clock — is a **synchronous** model. Every computation completes within one tick. This is a powerful simplification for:

- Flight control systems (sampled at fixed rates)
- Sensor processing pipelines
- State machines with well-defined transitions
- Mode-based behavior (normal/degraded/recovery)

But it creates a **fundamental mismatch** with:

- Asynchronous distributed systems (network delays, message reordering)
- Eventually consistent data stores
- Cross-service transactions
- Unbounded retry/backoff patterns

The QFCS case study authors explicitly noted that synchronous execution was a fair assumption for their flight control design, while async/quasi-synchronous support was still being developed. The Lustre ecosystem paper similarly frames the language as designed for "systems that continuously react to an environment" with timing constraints — not for loosely-coupled distributed architectures.

### The Assume/Guarantee Pattern Requires Boundaries

The entire contract system (assume/guarantee with modes) depends on a clean separation:

- **Your component** has outputs you control and guarantee
- **The environment** has inputs you observe and make assumptions about
- **Assumptions cannot depend on current outputs** — the environment does not control them

This only works when:
1. **Component boundaries are explicit** — defined inputs and outputs, not implicit dependencies through shared databases or global state
2. **Interfaces are observable** — you can actually measure the variables in your requirements
3. **Components are isolated** — you can reason about one without knowing another's internals

### How External State Is Modeled

External/third-party state is modeled as **environment inputs with assumptions**, not as something the component controls:

```lustre
-- External service health modeled as boolean input stream
node CircuitBreaker(upstream_healthy: bool; error_count: int)
returns (breaker_open: bool)
(*@contract
  -- Assume: environment provides health signal
  assume upstream_healthy or error_count >= 0;

  -- Guarantee: breaker opens when errors exceed threshold
  guarantee error_count > 5 => breaker_open;
  guarantee upstream_healthy and error_count = 0 => not breaker_open;
*)
```

Typical mappings for backend systems:
- **External service health** → `bool` Input
- **Cache freshness** → `bool` Input with assumption: `cache_fresh => cache_age < ttl`
- **Network latency** → `real` Input with bounded range assumption
- **Third-party API response** → `enum` Input ∈ {ok, error, timeout}

The key: you model what your component **observes**, not the external system's internals. If an assumption is wrong, realizability analysis exposes the contradiction.

### The Design Feedback Effect

The NASA Inspection Rover case study explicitly states: **"developing with formal methods in mind from the outset can influence the design"** — making it more amenable to verification. This creates a virtuous cycle:

1. You try to write FRET requirements → discover your boundaries are unclear
2. You refactor to create clearer component interfaces
3. Now FRET requirements are writable and verifiable
4. The architecture is better regardless of whether you use formal tools

This is the deepest practical lesson: the **discipline of trying to formalize** is valuable even if you never run Kind 2. The formalization forces explicit boundaries, named modes, typed interfaces, and stated assumptions.

### What Fits and What Doesn't

**Natural fit for Lustre/FRET/Copilot:**
- Local state machines (auth decisions, circuit breakers, quota enforcement)
- Mode-based behavior (normal/degraded/recovery/maintenance)
- Timing invariants within one component ("respond within 500ms", "deny within 5s of revocation")
- Policy evaluation with known inputs
- Sequential request processing at a gateway boundary

**Requires careful modeling (possible but needs abstraction):**
- Caches with TTLs → model TTL as stream countdown with `pre` operator
- External service health → boolean input with mode transitions
- Retry behavior → internal counter with bounded assumptions
- Queue consumers → discrete events modeled as input streams
- Timeout behavior → "within N time units" timing in FRET

**Wrong tool — use something else:**
- Distributed consensus → TLA+ or formal protocol verification
- Eventual consistency guarantees → Jepsen-style testing
- Cross-service transactions → saga pattern design + integration testing
- Shared mutable state across services → redesign the architecture
- Unbounded async workflows → process calculi (CSP, pi-calculus)

### For Backend/API Systems Specifically

Natural component boundaries that map well to FRET:

| Component | Inputs | Outputs | State |
|---|---|---|---|
| **Auth decision** | request, token, key_status | allow/deny, reason | token cache |
| **Rate limiter** | request, quota_remaining | allow/throttle, new_quota | counters per key |
| **Circuit breaker** | upstream_status, error_count | open/closed/half-open | state machine |
| **Policy engine** | request, policy_snapshot | decision, matched_rules | none (stateless) |
| **Config distributor** | new_config, node_status | config_version per node | rollout state |

Each of these can have FRET requirements with clear variables, typed glossary entries, and verifiable guarantees. Cross-cutting concerns (end-to-end latency, distributed consistency) need different tools.

### Real-World Example: Making a Go Middleware FRET-Coverable

A complete worked example of applying the Decide → Plan → Execute pattern to a real Go API gateway middleware is documented in `research_testing_as_evidence.md`, section 1.4.7. The pattern demonstrates that separating pure decision logic from side effects makes any function modelable as a FRET component, with `MiddlewareInputs` mapping to FRET Input variables and `MiddlewarePlan` fields mapping to Output variables. See also the cross-reference in `fret_slides.md`.

### The Honest Position

> "FRET and Lustre assume a modular architecture with clear component boundaries. If your system is a tightly coupled monolith where everything calls everything else and state is shared through a database, these tools won't help much until you refactor boundaries. But the act of trying to write formal requirements will show you exactly where those boundaries need to be — and that's valuable even without running a model checker."


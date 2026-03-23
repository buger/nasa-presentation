# Runtime Monitoring and Observability as a Safety Assurance Discipline

## Internal Reference: Applying NASA/Automotive Engineering Lessons to Software Engineering

---

## 1. NASA Runtime Monitoring Tools

### 1.1 Copilot: Haskell-Based Runtime Monitor Generator

**What it is.** Copilot is a stream-based domain-specific language (DSL) embedded in Haskell, developed originally by Galois, Inc. in collaboration with NASA Langley Research Center. It is designed for writing and generating runtime monitors for safety-critical hard real-time systems.

**Core design.** Copilot programs define *streams* of values over discrete time steps and *triggers* that fire when Boolean stream expressions become true. The language is purely functional: monitors are defined as Haskell expressions over typed streams (Bool, Int8, Int16, Int32, Int64, Word8, Word16, Word32, Word64, Float, Double). Streams can reference their own past values (using temporal offsets), enabling stateful monitoring without mutable state.

A Copilot specification looks like:

```haskell
spec :: Spec
spec = do
  trigger "alert_overspeed"
    (speed > 100 && duration speed (> 100) > 5)
    -- Note: `duration` is shown as illustrative pseudo-code. In actual
    -- Copilot, this would be implemented using stream combinators
    -- (`++`, conditional increment).
    [arg speed, arg altitude]
```

This declares that whenever speed exceeds 100 for more than 5 consecutive time steps, a C function `alert_overspeed` should be called with the current speed and altitude as arguments.

**Code generation pipeline.** Copilot compiles specifications into constant-time, constant-space C99 code. The generated C code:

- Uses no dynamic memory allocation
- Contains no recursion
- Has bounded execution time per step (critical for hard real-time scheduling)
- Uses only static arrays for stream history buffers
- Produces a `step()` function that is called once per monitoring period

The compilation path is: Haskell Copilot DSL --> Copilot Core (intermediate representation) --> copilot-c99 backend --> C99 source files.

**Supported temporal constructs:**

- `(++)` — append initial values to a stream (like Lustre's `->` operator)
- `drop` — `drop k s` discards the first `k` values from stream `s`, effectively shifting it forward in time. Combined with `(++)` for initialization, this enables expressing recurrences and temporal offsets.
- `[e] ++ s` — provide initial value then continue with stream s
- Arithmetic, Boolean, comparison operators lifted to streams
- `extern` — declare external input streams sampled from the environment
- `trigger` — declare a monitoring action with a guard condition and arguments
- `observer` — declare a named output stream for logging/debugging

**History and provenance.** The original Copilot work was published around 2010-2011 by Lee Pike, Alwyn Goodloe, Robin Morisset, and Sebastian Niller at Galois and NASA. Key publications include:

- Pike, L., Goodloe, A., Morisset, R., Niller, S. "Copilot: A Hard Real-Time Runtime Monitor." RV 2010 (Runtime Verification).
- Pike, L., Wegmann, N., Niller, S., Goodloe, A. "Copilot: Monitoring Embedded Systems." Innovations in Systems and Software Engineering, 2013.
- Perez, I., Dedden, F., Goodloe, A. "Copilot 3." NASA Technical Report, 2020.

The project is maintained as open source: https://github.com/Copilot-Language/copilot

**Why C from Haskell.** The choice of Haskell as the specification language and C as the target is deliberate. Haskell provides strong static typing, referential transparency, and a natural embedding for stream-based DSLs. C is the deployment target because safety-critical embedded systems (flight controllers, avionics) are almost universally programmed in C, and the generated code must meet constraints like MISRA C compliance and deterministic resource usage.

**Relationship to offline model checking.** Copilot monitors complement tools like Kind 2, JKind, and NuSMV by operating at a different point in the verification lifecycle:

| Aspect | Model Checking (Kind 2, NuSMV) | Runtime Monitoring (Copilot) |
|---|---|---|
| When | Design/pre-deployment | Deployment/operations |
| Coverage | Exhaustive (all reachable states) | Partial (only observed executions) |
| State space | Can handle finite/infinite state models | Monitors only the actual execution trace |
| Cost | High computational cost, state explosion | Constant-time per step, minimal overhead |
| Guarantees | Universal (for all inputs) | Trace-specific (universal over the observed prefix, but only for this particular execution trace) |
| Requirements | Complete formal model needed | Only the property + signal interface needed |

The insight is that model checking proves properties *before deployment* over all possible executions, but may require simplifications or abstractions. Runtime monitoring checks properties *during deployment* on the actual execution, catching violations that escaped modeling assumptions, environmental changes, or hardware faults. The combination provides defense in depth.

### 1.2 R2U2: Realizable, Responsive, Unobtrusive Unit

**What it is.** R2U2 (Realizable, Responsive, Unobtrusive Unit) is a runtime verification framework developed at the University of Iowa and NASA Ames Research Center. It is designed to monitor safety properties of cyber-physical systems in real time, with particular focus on flight-critical avionics.

**Architecture.** R2U2 has a unique dual-layer architecture:

1. **Signal processing layer (Bayesian network evaluation):** Processes raw sensor data and computes probabilistic state estimates. This layer can assess sensor health, detect anomalies, and produce Boolean or real-valued signals from noisy inputs.

2. **Temporal logic monitoring layer (MTL/pt-MTL evaluation):** Takes the processed signals and evaluates them against Metric Temporal Logic (MTL) or past-time MTL specifications. This layer implements efficient online algorithms for checking bounded temporal properties.

**Target platforms.** R2U2 is designed to run on:

- **FPGAs (Field-Programmable Gate Arrays):** The original target. FPGA implementation enables truly parallel evaluation of multiple properties with deterministic timing, important for DO-254 (hardware assurance) considerations.
- **Embedded processors:** C implementations for conventional embedded targets.
- **Software-in-the-loop:** For testing and development.

The FPGA targeting is particularly significant because it allows monitors to run on dedicated hardware, completely isolated from the monitored flight software. This achieves hardware-level "freedom from interference" — the monitor cannot corrupt the system under test, and the system under test cannot corrupt the monitor.

**Specification language.** R2U2 accepts properties written in:

- **MTL (Metric Temporal Logic):** An extension of LTL with bounded temporal operators. For example: `G[0,100](sensor_healthy -> F[0,5] reading_valid)` means "globally within the first 100 steps, if the sensor is healthy, then within 5 steps a valid reading must appear." Some R2U2 publications use "Mission-time Temporal Logic" in the context of mission-bounded checking, but the canonical meaning of MTL in the formal methods community is Metric Temporal Logic (Koymans, 1990).
- **Past-time MTL (pt-MTL):** Properties over the past execution trace, which are often more natural for monitoring (since the monitor can only observe the past and present, not the future).

**Key publications:**

- Reinbacher, T., Rozier, K.Y., Schumann, J. "Temporal-Logic Based Runtime Observer Pairs for System Health Management of Real-Time Systems." TACAS 2014.
- Moosbrugger, P., Rozier, K.Y., Schumann, J. "R2U2: Monitoring and Diagnosis of Security Threats for Unmanned Aerial Systems." FMCAD 2017.
- Jones, P., Rozier, K.Y. "R2U2 Version 3.0." Runtime Verification (RV) 2023.

**NASA applications.** R2U2 has been applied to:

- UAS (Unmanned Aerial Systems) monitoring for detect-and-avoid safety properties
- Rover health management
- Generic avionics bus monitoring
- Security threat detection for autonomous systems

The project is open source: https://github.com/R2U2/r2u2

### 1.3 Ogma: Bridge from FRET to Copilot

**What it is.** Ogma is a NASA tool that serves as a translation bridge between requirements specification tools (primarily FRET) and runtime monitoring frameworks (primarily Copilot). It automates the conversion of formal requirements into executable runtime monitors.

**The pipeline Ogma enables:**

```
FRET (FRETish requirements)
  --> FRET Component Specification (JSON export)
    --> Ogma
      --> Copilot Haskell specification
        --> copilot-c99 compiler
          --> C runtime monitor code
```

**What Ogma does specifically:**

1. Reads FRET's component-based specification export (which contains the component name, input variables, output variables, and temporal logic properties formalized from FRETish requirements).
2. Maps FRET variables to Copilot external streams, with type information.
3. Translates FRET's temporal logic formulas into Copilot stream expressions.
4. Generates a complete Copilot Haskell module with triggers for property violations.
5. Optionally generates integration scaffolding for specific middleware targets (e.g., ROS, cFS — NASA's core Flight System).

**Integration targets.** Ogma can generate integration code for:

- **Robot Operating System (ROS/ROS 2):** Generates ROS nodes that subscribe to relevant topics, sample data, feed it to the Copilot monitor, and publish violation alerts.
- **NASA cFS (core Flight System):** Generates cFS application scaffolding for flight software integration.
- **Standalone C:** Plain C integration for generic embedded targets.

**Key publication:**

- Perez, I., Goodloe, A. "From Requirements to Autonomous Flight: An Overview of the Monitoring ICAROUS Project." NASA Technical Report, NTRS 20220000049.

The project is open source: https://github.com/nasa/ogma

**Why Ogma matters for the pipeline.** Without Ogma, the gap between "I have requirements in FRET" and "I have C monitors running on my embedded system" would require manual translation — error-prone and difficult to maintain as requirements evolve. Ogma closes this gap, making the pipeline from natural-language-like requirements to deployed monitors *automated and repeatable*. This is a concrete example of the "requirements as first-class engineering artifacts" philosophy: change the requirement in FRET, re-run the pipeline, and the monitor updates.

### 1.4 How Runtime Monitors Complement Offline Model Checking

The NASA verification ecosystem uses a layered strategy:

**Layer 1: Requirements analysis (FRET + Kind 2/JKind).** Before any code exists, check whether the requirements themselves are consistent and realizable. FRET exports to Kind 2 and JKind for realizability analysis. This catches contradictory requirements early — for example, the QFCS (Quad-Redundant Flight Control System) case study found requirements about actuator gain that became contradictory under certain failure combinations.

**Layer 2: Model checking (Kind 2, NuSMV, CoCoSim).** Given a formal model of the system (in Lustre, Simulink, or similar), exhaustively check whether safety properties hold for all reachable states. This is the strongest guarantee but requires a complete and accurate model.

**Layer 3: Runtime monitoring (Copilot, R2U2).** Deploy monitors alongside the actual system. These catch:

- Violations that escaped model checking due to modeling abstractions
- Environmental conditions not captured in the model
- Hardware faults or degradation
- Integration errors between components that were verified separately
- Requirement changes that invalidated previous proofs

**The defense-in-depth argument.** No single verification technique is sufficient for safety-critical systems. Model checking may miss environmental factors; testing samples only finite executions; runtime monitoring sees only the current run. Together, they form a layered safety argument where each technique covers gaps left by the others. This is formalized in safety cases (using Goal Structuring Notation or similar) where different evidence types support different sub-claims in the overall safety argument.

---

## 2. Automotive Monitoring: ISO 26262 and Runtime Fault Detection

### 2.1 ISO 26262 Requirements for Runtime Fault Detection

ISO 26262 ("Road vehicles — Functional safety") is the primary standard governing safety-related electrical/electronic (E/E) systems in automotive. It establishes requirements for runtime monitoring as a fundamental safety mechanism.

**ASIL levels and monitoring requirements.** ISO 26262 classifies hazards by Automotive Safety Integrity Level (ASIL A through D, with D being the most stringent). The ASIL level directly determines:

- **Diagnostic coverage requirements:** The fraction of dangerous faults that must be detected by safety mechanisms. ASIL D requires the highest diagnostic coverage (typically >99% for certain fault categories).
- **Fault detection time intervals:** Maximum time between fault occurrence and detection. Lower for higher ASIL levels.
- **Safety mechanism complexity:** Higher ASIL levels may require more sophisticated monitoring approaches.

**Part 5 (Hardware) monitoring requirements.** ISO 26262 Part 5 defines specific diagnostic coverage metrics:

- **Single-point fault metric (SPFM):** Percentage of single-point faults covered by safety mechanisms. ASIL D requires >= 99%.
- **Latent fault metric (LFM):** Percentage of latent (undetected multi-point) faults covered. ASIL D requires >= 90%.
- **Probabilistic metric for random hardware failures (PMHF):** Maximum rate of dangerous failures. ASIL D requires < 10^-8 per hour.

**Part 6 (Software) monitoring expectations.** ISO 26262 Part 6 addresses software development and implicitly requires:

- Error detection at software interfaces
- Range checks on inputs and outputs
- Plausibility checks on sensor data
- Program flow monitoring
- Data integrity checks (e.g., stored data verification)
- Diverse software monitoring for high-ASIL functions

### 2.2 Watchdog Mechanisms

**Hardware watchdog timers.** The most fundamental runtime monitoring mechanism in automotive:

- A counter that must be periodically reset ("kicked") by the monitored software
- If the software fails to reset the counter within the timeout period, the watchdog triggers a safe-state transition
- Provides protection against software hangs, infinite loops, and crash failures

**Window watchdog.** More sophisticated than simple watchdog:

- The software must kick the watchdog within a defined *time window* (not too early, not too late)
- Detects both stuck software and software executing too fast (which may indicate control flow corruption)

**Logical program flow monitoring.** ISO 26262 recommends monitoring beyond simple liveness:

- **Program flow monitoring:** Verify that the software executes the expected sequence of program blocks. Implemented via checksums, signatures, or tokens that are accumulated as execution proceeds and verified at checkpoints.
- **Temporal monitoring:** Verify that execution completes within expected time bounds.
- **Combination:** Many automotive safety platforms combine watchdog timers with logical flow monitoring to detect both timing and sequence violations.

### 2.3 Safety-Relevant Diagnostic Coverage

Diagnostic coverage is calculated as:

```
DC = (dangerous faults detected by safety mechanisms) / (total dangerous faults)
```

ISO 26262 defines categories of diagnostic coverage:

| Coverage Level | DC Range |
|---|---|
| Low | >= 60% |
| Medium | >= 90% |
| High | >= 99% |

For each safety mechanism, the standard requires:

1. **Identification of fault modes** the mechanism is intended to detect
2. **Analysis of detection effectiveness** for each fault mode
3. **Quantification of coverage** considering detection latency and reliability of the mechanism itself
4. **Documentation** linking safety mechanisms to the faults they address

### 2.4 E2E Protection for Safety-Critical Communication

**The problem.** In distributed automotive systems (multiple ECUs connected via CAN, Ethernet, FlexRay), communication can be corrupted by:

- Bit errors in transmission
- Message loss
- Message repetition
- Message reordering
- Message delay
- Message insertion (from a faulty sender)
- Message corruption in memory

**AUTOSAR E2E (End-to-End) protection.** The AUTOSAR standard defines E2E protection profiles that add safety-related information to messages:

- **Counter:** Monotonically increasing value to detect loss, repetition, and reordering
- **CRC (Cyclic Redundancy Check):** Detects data corruption
- **Data ID:** Identifies the specific signal/message to detect insertion or masquerading
- **Alive counter:** Detects communication loss (similar to heartbeat)
- **Timeout monitoring:** Detects delayed messages

E2E profiles (Profile 1, 2, 4, 5, 6, 7, 11, etc.) combine these mechanisms differently depending on the communication protocol and safety requirements.

**Relevance to software.** E2E protection is implemented in software (sender wraps, receiver checks) and is a concrete example of runtime monitoring embedded in the data path. It directly parallels API-level integrity checking: message authentication, sequence numbers, checksums, and timeout monitoring.

### 2.5 Freedom from Interference

**Definition.** ISO 26262 defines "freedom from interference" as the absence of cascading failures between elements of different ASIL levels or between safety-related and non-safety-related elements.

**Why it matters.** In a system where ASIL-D safety functions coexist with QM (Quality Management, i.e., non-safety) functions on the same hardware:

- A fault in the QM function must not corrupt the ASIL-D function
- Shared resources (CPU, memory, communication) must be partitioned or monitored
- The burden of proof is on demonstrating that interference cannot occur or is detected and handled

**Mechanisms for achieving freedom from interference:**

1. **Spatial partitioning:** Memory protection units (MPUs), virtual machines, or separate hardware preventing one partition from accessing another's memory.
2. **Temporal partitioning:** Time-triggered scheduling, execution time monitoring, preventing one partition from consuming another's CPU budget.
3. **Communication partitioning:** Firewall-style filtering of messages between partitions, preventing data corruption across boundaries.
4. **Runtime monitoring:** Watchdogs, memory checks, and flow monitors that detect interference violations.

**Software architectural patterns:**

- **Safety-related software element (ASIL decomposition):** Split a high-ASIL requirement into redundant elements at lower ASIL levels, each independently developed and monitored.
- **Safety mechanism at the boundary:** A monitor that checks the outputs of a non-safety element before they can influence a safety function.
- **Diverse redundancy:** Two independent implementations of the same function, with a comparator (itself at the required ASIL) checking agreement.

**Analogy to API platforms.** Freedom from interference maps directly to tenant isolation, privilege separation, and blast-radius containment in multi-tenant platforms. The question "can a bug in Tenant A's custom plugin corrupt Tenant B's traffic?" is structurally identical to "can a fault in a QM function corrupt an ASIL-D function?"

---

## 3. From Formal Specs to Production Monitors

### 3.1 The Requirements-to-Monitors Pipeline

The NASA toolchain demonstrates a concrete pipeline from human-readable requirements to deployed runtime monitors:

```
Step 1: Requirements Elicitation (FRET)
  Engineer writes in FRETish:
  "After key_revoked(key), AuthSubsystem shall within 5 seconds
   satisfy all_new_auth_decisions(key) = denied"

Step 2: Formalization (FRET internals)
  FRET translates to past-time LTL / future-time LTL:
  G(key_revoked(key) -> F[0,5](all_new_auth_decisions(key) = denied))

Step 3: Analysis (FRET + Kind 2/JKind)
  - Realizability: Can any implementation satisfy all requirements?
  - Consistency: Do requirements contradict each other?
  - Vacuity: Are any requirements trivially true?

Step 4: Export (FRET Component Specification)
  JSON export containing:
  - Component name
  - Input variables with types
  - Output variables with types
  - Temporal logic properties

Step 5: Translation (Ogma)
  Converts FRET export to Copilot Haskell specification:
  - Maps FRET variables to Copilot external streams
  - Translates temporal formulas to stream expressions
  - Generates trigger declarations

Step 6: Compilation (Copilot + copilot-c99)
  Generates C99 code:
  - step() function called each monitoring period
  - Static memory allocation
  - Trigger callbacks on violation

Step 7: Integration
  Generated C code linked into the target system:
  - Input streams connected to actual system signals
  - Trigger callbacks connected to alert/logging/safe-state mechanisms
  - Monitor scheduled alongside application code
```

### 3.2 What Can and Cannot Be Monitored at Runtime

**Can be monitored (decidable at runtime):**

- **Safety properties (finite-trace approximation):** "Nothing bad has happened so far." Any violation of a safety property is observable in finite time, making it ideal for runtime monitoring. Examples: no unauthorized access has occurred, no rate limit has been exceeded without logging, no response took longer than the SLA threshold.

- **Bounded liveness properties:** "Something good happens within N time units." The bound makes it finite and observable. Example: "After a key is revoked, all gateways must deny that key within 5 seconds."

- **Past-time properties:** Any property stated over the past execution trace. The monitor has complete information about the past. Example: "Every request that was forwarded in the last 10 seconds had a valid auth token at the time of forwarding."

- **Statistical/aggregate properties:** Properties over distributions, counts, and rates, computed over sliding windows. Example: "The 99th percentile latency over the last 5 minutes is below 200ms."

- **State invariants:** Properties that must hold at every observation point. Example: "The config version is monotonically increasing across checkpoints."

**Cannot be monitored (or requires approximation):**

- **Unbounded liveness properties:** "Eventually, something good will happen" (with no time bound). At any finite point, you cannot distinguish "hasn't happened yet" from "will never happen." You can only report a *potential* violation after a timeout.

- **Universally quantified properties over infinite domains:** "For all possible inputs, the system responds correctly." Runtime monitoring only sees the inputs that actually arrive.

- **Hyperproperties:** Properties relating multiple execution traces (e.g., noninterference, information-flow security). A single runtime monitor sees only one trace. Requires specialized multi-trace monitoring or architectural support (like comparing parallel executions).

- **Exact coverage of rare events:** Properties about behaviors that occur with very low probability may never be exercised during monitoring.

- **Future-time properties (general):** Any property that requires knowing the future to evaluate. Runtime monitors can only approximate these using bounded lookahead or by delaying verdicts.

### 3.3 Monitoring Coverage vs. Performance Overhead Trade-off

**The fundamental tension.** Every monitored signal costs:

- **CPU time:** Evaluating the monitor logic
- **Memory:** Storing signal history for temporal properties
- **Bandwidth:** Transmitting signals from the monitored system to the monitor (if separated)
- **Latency:** If monitoring is in the critical path, it adds latency
- **Interference risk:** The monitor itself could affect the system's timing behavior

**Copilot's approach to managing overhead.** Copilot addresses this by generating constant-time, constant-space C code. The overhead is predictable and can be bounded at compile time by analyzing the generated code:

- Each stream with history depth N requires an array of N elements
- Each `step()` call performs a fixed number of operations
- No dynamic allocation, no recursion, no unbounded loops
- This makes Copilot monitors amenable to WCET (Worst-Case Execution Time) analysis

**R2U2's approach.** R2U2 on FPGA achieves near-zero overhead on the monitored system because:

- The monitor runs on separate hardware
- Signal sampling uses existing bus interfaces
- Evaluation is parallel across all monitored properties
- Timing is deterministic and independent of the monitored software

**Practical strategies for managing the trade-off:**

1. **Prioritize by ASIL/criticality:** Monitor ASIL-D/P0 properties with full coverage; sample or reduce frequency for lower-criticality properties.

2. **Temporal granularity:** Not every property needs to be checked every millisecond. Match monitoring frequency to the property's time bounds.

3. **Hierarchical monitoring:** Use cheap checks (heartbeat, watchdog) for broad coverage and expensive checks (full temporal property evaluation) for critical properties.

4. **Offline augmentation:** Collect traces and evaluate expensive properties offline, using runtime monitoring only for the properties that require immediate detection.

5. **Adaptive monitoring:** Increase monitoring detail when anomalies are detected (analogous to adaptive sampling in observability systems).

---

## 4. Observability as Structured Evidence

### 4.1 Observability Beyond Debugging

Traditional observability (logs, metrics, traces) is designed to answer "what happened when something went wrong?" The safety-assurance perspective reframes observability as *ongoing verification evidence*: "what evidence do we continuously produce that the system is operating correctly?"

**The shift:**

| Traditional Observability | Evidence-Oriented Observability |
|---|---|
| Reactive (investigate after incident) | Proactive (continuously verify) |
| Unstructured (grep through logs) | Structured (typed, schematized signals) |
| Coverage is ad hoc | Coverage traces to requirements |
| Quality is best-effort | Quality is a safety argument input |
| Retained for debugging | Retained for audit and assurance |

### 4.2 Structured Logging as an Audit Trail

**Requirements for safety-grade logging:**

1. **Completeness:** Every safety-relevant decision must produce a log entry. The set of loggable events should trace to the requirements (e.g., every FRET requirement that references an observable signal should have a corresponding log event).

2. **Immutability:** Log entries, once written, must not be modifiable. Append-only storage, cryptographic chaining (like a blockchain or Merkle tree), or write-once storage.

3. **Structured schema:** Every log entry should conform to a known schema with typed fields. This enables automated analysis and property checking over log data.

4. **Causal ordering:** Logs must carry sufficient information to reconstruct causal order. This means at minimum: monotonic timestamps, correlation IDs, and ideally vector clocks or Lamport timestamps for distributed systems.

5. **Tamper evidence:** It should be detectable if logs have been altered or entries removed. Important for regulatory compliance (SOX, GDPR audit, PCI-DSS).

6. **Retention policy:** Aligned with regulatory and safety-case requirements, not just storage cost optimization.

**Example: Safety-grade auth decision log schema:**

```json
{
  "event_type": "auth_decision",
  "timestamp": "2026-03-16T14:22:03.445Z",
  "trace_id": "abc-123-def",
  "request_id": "req-789",
  "tenant_id": "tenant-42",
  "api_key_id": "key-555",
  "decision": "denied",
  "reason": "key_revoked",
  "key_revocation_time": "2026-03-16T14:21:58.100Z",
  "latency_since_revocation_ms": 5345,
  "policy_version": "v2.3.1",
  "gateway_instance": "gw-us-east-1a-07",
  "config_snapshot_id": "snap-9012"
}
```

Every field in this schema connects to a monitorable property: the `latency_since_revocation_ms` field directly supports checking the "denied within 5 seconds of revocation" requirement.

### 4.3 Metrics as Invariant Monitors

Metrics, when designed with safety assurance in mind, become continuous invariant monitors:

**Counter-based invariants:**

- `auth_decisions_total{decision="allow"} + auth_decisions_total{decision="deny"} == requests_reaching_auth_total` (no request silently bypasses the auth decision)
- `audit_events_emitted_total >= auth_decisions_total` (every auth decision produces an audit event)

**Gauge-based invariants:**

- `config_version_current >= config_version_minimum_required` (no gateway is running a config version below the required minimum)
- `active_connections_per_tenant <= max_connections_per_tenant` (tenant isolation limit is respected)

**Histogram-based properties:**

- `histogram_quantile(0.99, request_duration_seconds) < slo_latency_threshold` (SLO compliance)
- `rate(5xx_responses_total[5m]) / rate(responses_total[5m]) < error_budget_threshold` (error budget not exhausted)

**The key insight.** Each of these metrics expressions is a runtime monitor in disguise. By expressing them as alerting rules (in Prometheus, Datadog, etc.), you create a lightweight runtime monitoring system. The difference from ad hoc alerting is *traceability*: each alert rule should trace to a requirement, and the set of alert rules should provide coverage over the critical requirements.

### 4.4 Distributed Tracing as Causal Evidence

Distributed tracing (OpenTelemetry, Jaeger, Zipkin) provides causal evidence about how requests flow through the system:

**What traces prove:**

- **Execution path:** Which components handled the request, in what order
- **Timing:** How long each component took, where delays occurred
- **Decision points:** What decisions were made (auth, routing, rate limiting) and their outcomes
- **Propagation:** How context (tenant ID, auth token, config version) propagated across boundaries
- **Error attribution:** Where in the chain a failure originated vs. where it manifested

**Traces as safety evidence.** For a safety-critical requirement like "no request shall be evaluated under another tenant's policy context," distributed tracing can provide evidence by:

1. Recording the tenant context at each boundary crossing
2. Verifying (via offline analysis or real-time checking) that tenant context is consistent across all spans in a trace
3. Flagging any trace where tenant context changes unexpectedly

**Trace-based runtime monitoring.** OpenTelemetry's span events and attributes can be designed to carry the same signal information that a Copilot monitor would sample. A trace processor can then evaluate temporal properties over the span sequence. This is analogous to offline runtime verification: collect the trace, then check properties post-hoc. The trade-off is latency of detection (not real-time) but zero performance impact on the critical path.

---

## 5. Health Monitoring Patterns

### 5.1 Circuit Breakers as Safety Mechanisms

The circuit breaker pattern (popularized by Michael Nygard's "Release It!" and implemented in libraries like Hystrix, resilience4j, gobreaker) is structurally a safety mechanism in the ISO 26262 sense:

**Mapping to safety concepts:**

| Safety Concept | Circuit Breaker Equivalent |
|---|---|
| Fault detection | Error rate exceeds threshold |
| Safe state transition | Circuit opens, requests fail fast |
| Degraded mode | Half-open state, limited probe traffic |
| Recovery | Successful probes cause circuit to close |
| Fault detection time interval | Monitoring window + threshold evaluation time |

**What circuit breakers monitor:**

- Error rate (5xx responses, timeouts, exceptions)
- Latency (slow responses as a precursor to failure)
- Concurrency (too many in-flight requests)

**What circuit breakers do NOT monitor (but should):**

- **Correctness of successful responses:** A 200 OK with wrong data is not detected
- **Semantic degradation:** The upstream responds quickly but with stale data
- **Partial failure:** Some endpoints on the upstream fail while others succeed
- **Byzantine failures:** The upstream actively returns misleading results

**Improvement: augment circuit breakers with correctness checks.** Combine circuit breakers with lightweight response validation (schema checks, canary comparison, invariant checks on response fields) to detect semantic failures, not just transport-level failures.

### 5.2 Heartbeat/Liveness vs. Correctness Monitoring

**Liveness monitoring** answers: "Is the component still running?"

- Heartbeat signals (periodic "I'm alive" messages)
- Health check endpoints (HTTP 200 from `/healthz`)
- Watchdog timers
- Process-level monitoring (is the PID alive?)

**Correctness monitoring** answers: "Is the component doing the right thing?"

- Invariant checking on outputs
- Property evaluation on behavior traces
- Comparison with a reference implementation (diverse redundancy)
- Self-test / built-in test (BIT) execution

**The gap.** Most production systems have extensive liveness monitoring but minimal correctness monitoring. A service can be "alive" (responding to health checks) while:

- Returning stale data from a broken cache
- Applying an outdated policy version
- Silently dropping audit events
- Allowing requests that should be denied

**Bridging the gap:** Design health checks that verify correctness, not just liveness:

```go
// Bad: liveness-only health check
func healthHandler(w http.ResponseWriter, r *http.Request) {
    w.WriteHeader(http.StatusOK)
}

// Better: correctness-aware health check
func healthHandler(w http.ResponseWriter, r *http.Request) {
    checks := map[string]error{
        "config_version":    verifyConfigVersion(),
        "auth_backend":      verifyAuthBackendReachable(),
        "policy_loaded":     verifyPolicySnapshotValid(),
        "audit_pipeline":    verifyAuditPipelineDraining(),
        "cert_expiry":       verifyCertsNotExpiringSoon(),
    }
    // Report individual check results for structured evidence
}
```

### 5.3 Anomaly Detection vs. Invariant Checking

| Approach | Anomaly Detection | Invariant Checking |
|---|---|---|
| Knowledge required | Historical baseline data | Formal property specification |
| What it detects | Deviations from learned normal | Violations of stated rules |
| False positives | Common (novel-but-valid behavior) | Rare (property is either violated or not) |
| False negatives | Possible (anomaly within "normal" range) | Only if the invariant is incomplete |
| Adaptability | Adapts to changing baselines | Fixed unless spec changes |
| Explainability | Often opaque ("this is unusual") | Clear ("requirement X was violated") |
| Best for | Unknown-unknowns, novel failure modes | Known-critical properties |
| NASA equivalent | R2U2's Bayesian layer | Copilot's temporal logic monitors |

**Recommendation: use both, for different purposes.**

- **Invariant checking** for properties derived from requirements (the "known-important" properties). These are your safety monitors.
- **Anomaly detection** for discovering new failure modes that were not anticipated in the requirements. These feed back into the requirements process.

### 5.4 Canary Analysis as Runtime Verification

Canary deployments are a form of runtime verification in disguise:

**The verification argument:** "If the new version satisfies the same behavioral properties as the old version when exposed to real traffic, then it is likely correct."

**What makes canary analysis rigorous:**

1. **Explicit success criteria:** Define metrics and thresholds *before* deployment (not post-hoc).
2. **Statistical significance:** Use proper statistical tests (Mann-Whitney U, Kolmogorov-Smirnov) to compare canary vs. baseline, not eyeballing dashboards.
3. **Automated rollback:** The canary system should automatically roll back if criteria are violated, making it a closed-loop safety mechanism.
4. **Property coverage:** The canary metrics should trace to requirements. If a requirement says "99th percentile latency < 200ms," the canary analysis should explicitly check that property.

**Canary analysis as a bridge to formal runtime verification.** Automated canary systems like Kayenta (Netflix/Spinnaker) or Flagger (Kubernetes) implement a simplified form of the NASA monitoring pipeline:

- Properties defined before deployment (like FRET requirements)
- Signals collected during deployment (like Copilot input streams)
- Properties evaluated against signals (like Copilot trigger evaluation)
- Automated response on violation (like safe-state transition)

### 5.5 SLO-Based Monitoring as a Simplified Safety Case

Service Level Objectives (SLOs) can be viewed as a simplified safety case:

**SLO structure mapped to safety case structure:**

| Safety Case Element | SLO Equivalent |
|---|---|
| Top-level claim | "The service is reliable enough for its users" |
| Sub-claims | Individual SLOs (availability, latency, correctness) |
| Evidence | SLI measurements over the compliance period |
| Argument | "If all SLOs are met, the service is acceptably reliable" |
| Context | Assumptions about user behavior, traffic patterns, dependencies |

**Error budgets as residual risk management.** The error budget concept (100% minus SLO target = allowable unreliability) is conceptually identical to ISO 26262's approach to residual risk: you explicitly quantify how much failure is acceptable, track consumption against that budget, and take action (slow down releases, prioritize reliability work) when the budget is depleted.

**Limitations of SLOs as safety cases:**

- SLOs typically cover only a few dimensions (availability, latency, error rate)
- They don't capture semantic correctness ("responses are correct" is rarely an SLI)
- They're statistical, not per-request (a 99.9% SLO allows 0.1% failures — but which 0.1%?)
- They don't address timing properties, ordering, or causal relationships

**Improvement: augment SLOs with invariant-based monitors** for the properties that SLOs cannot capture. SLOs handle the statistical properties; invariant monitors handle the per-request correctness properties.

---

## 6. The Signals Catalog Concept

### 6.1 What a Signals Catalog Is

A Signals Catalog is a dedicated engineering artifact that documents every observable signal in the system that is relevant to monitoring, verification, or assurance. It serves as the bridge between requirements (what must be true), architecture (where signals originate), implementation (how signals are collected), and monitoring (how signals are checked).

**Conceptual origin.** FRET's variable glossary already implements a partial version of this concept. In FRET, each component has associated variables with attributes including:

- Variable name
- Variable type (input, output, internal, mode)
- Assignment (how the variable gets its value)
- Model component (which part of the system owns it)
- Description
- Linked requirements (which FRETish requirements reference this variable)

FRET's analysis portal also automatically extracts components, variables, functions, and modes from the set of requirements. The Signals Catalog generalizes this concept beyond FRET into a standalone, maintainable artifact for production systems.

### 6.2 Signals Catalog Schema

```yaml
signals_catalog:
  version: "1.3.0"
  last_updated: "2026-03-16"
  owner: "platform-reliability-team"

  signals:
    - name: request_received
      type: bool
      data_type: event
      source: "gateway HTTP middleware"
      collection_method: "OpenTelemetry span start event"
      owner: "platform-team"
      stability: stable  # stable | experimental | deprecated
      sampling_rate: "100%"
      latency_budget_ms: 0  # overhead added by collection
      description: >
        Emitted when a new HTTP request enters the gateway decision path.
        Does not fire for health checks or internal probes.
      linked_requirements:
        - REQ-AUTH-001: "Every request shall receive an auth decision"
        - REQ-AUDIT-003: "Every request shall produce an audit event"
      linked_monitors:
        - MON-COMPLETENESS-001: "audit_events >= requests"
      schema_ref: "schemas/request_received.v2.json"

    - name: auth_decision
      type: enum [allow, deny]
      data_type: event
      source: "auth service response"
      collection_method: "structured log + metric counter"
      owner: "auth-team"
      stability: stable
      sampling_rate: "100%"
      latency_budget_ms: 0
      description: >
        The final auth decision for a request. Emitted after token
        validation and policy evaluation complete.
      linked_requirements:
        - REQ-AUTH-001: "Every request shall receive an auth decision"
        - REQ-AUTH-005: "Revoked keys denied within 5s"
      linked_monitors:
        - MON-AUTH-LATENCY-001: "auth_decision_latency < 50ms p99"
        - MON-REVOCATION-001: "revoked key denied within 5s"
      schema_ref: "schemas/auth_decision.v3.json"

    - name: config_version_applied
      type: int64
      data_type: gauge
      source: "config distributor"
      collection_method: "Prometheus gauge metric"
      owner: "platform-team"
      stability: stable
      sampling_rate: "per config application event"
      latency_budget_ms: 0
      description: >
        The monotonic version number of the configuration snapshot
        currently active on a given gateway instance.
      linked_requirements:
        - REQ-CONFIG-002: "Config version monotonically increasing"
        - REQ-CONFIG-004: "All gateways converge within 30s"
      linked_monitors:
        - MON-CONFIG-DRIFT-001: "max version - min version < threshold"
      schema_ref: null  # simple scalar, no complex schema

    - name: rate_limit_remaining
      type: int32
      data_type: gauge
      source: "rate limiter module"
      collection_method: "per-request structured log field"
      owner: "traffic-team"
      stability: stable
      sampling_rate: "100%"
      latency_budget_ms: 0
      description: >
        Remaining request quota for the current key/tenant
        at the time of the rate limit check.
      linked_requirements:
        - REQ-RATE-001: "Requests exceeding quota receive 429"
        - REQ-RATE-003: "Rate limit accuracy within 1% of configured limit"
      linked_monitors:
        - MON-RATE-ACCURACY-001: "actual_allowed <= configured_limit * 1.01"
      schema_ref: "schemas/rate_limit_check.v1.json"
```

### 6.3 How to Build and Maintain a Signals Catalog

**Step 1: Inventory existing signals.** Survey the system for all existing observable outputs:

- Structured log fields
- Metric names and labels
- Trace span names and attributes
- Health check outputs
- Audit event types
- Error codes and categories

**Step 2: Map signals to requirements.** For each requirement (especially those formalized in FRETish or equivalent structured form), identify which signals provide evidence of satisfaction or violation. Mark requirements with no corresponding signals as *unmonitorable* — these are coverage gaps.

**Step 3: Identify ownership.** Each signal must have a clear owner (team or individual) responsible for:

- The signal's correctness (does it accurately represent what it claims?)
- The signal's availability (is it reliably collected?)
- The signal's stability (will it continue to exist and have the same semantics?)
- The signal's schema (are consumers notified of changes?)

**Step 4: Define stability contracts.** Signals should be classified by stability:

- **Stable:** The signal name, type, and semantics are committed. Changes require a deprecation process.
- **Experimental:** The signal exists but may change without notice. Not suitable for safety-critical monitors.
- **Deprecated:** The signal will be removed. A replacement should be identified.

**Step 5: Automate catalog maintenance.** The catalog should be:

- Stored in version control alongside the code
- Validated by CI (e.g., check that all signals declared in the catalog are actually emitted by the code, and all signals emitted by the code are declared in the catalog)
- Reviewed during requirement changes (if a requirement changes, do its linked signals need to change?)
- Auditable (the Git history of the catalog shows when signals were added, changed, or removed)

**Step 6: Link to monitors.** Each signal should reference the monitors that consume it, and each monitor should reference the signals it depends on and the requirements it verifies. This creates a traceability chain:

```
Requirement --> Signal(s) --> Monitor(s) --> Alert(s) / Evidence
```

This chain is the runtime-monitoring equivalent of the NASA bidirectional traceability requirement: from requirements to verification evidence, and from evidence back to requirements.

---

## 7. Practical Application to API Platforms

### 7.1 Monitoring Auth Decisions in Real-Time

**The requirement (FRETish-style):**

> Globally, when `request_received` and `api_key_valid = false`, Gateway shall immediately satisfy `response_status = 401`.

> After `key_revoked(key)`, AuthSubsystem shall within 5 seconds satisfy `all_new_auth_decisions(key) = denied`.

**Implementation approach:**

1. **Signal collection.** Instrument the auth middleware to emit structured events for every auth decision:
   - Request ID, timestamp, key ID, decision (allow/deny), reason, policy version
   - If denied: specific denial reason (expired, revoked, invalid, insufficient scope)
   - If allowed: token validation latency, cache hit/miss

2. **Real-time invariant monitor.** A stream processor (Kafka Streams, Flink, or even a Go goroutine consuming from a channel) that evaluates:
   - For every request with `api_key_valid = false`, verify `response_status = 401` within the same trace
   - After observing `key_revoked(key)`, start a 5-second timer and verify that all subsequent auth decisions for that key are `denied`

3. **Alert on violation.** Any violation of these properties triggers an immediate alert. This is a safety-critical notification (see Section 7.6).

4. **Audit evidence.** All auth decision events are stored immutably and linked to the request trace. This provides the audit trail for compliance (SOC 2, PCI-DSS, GDPR).

**Concrete metrics:**

```promql
# Auth bypass detection: requests that passed auth but should not have
# (requires correlation with known-revoked key list)
auth_decisions_total{decision="allow", key_status="revoked"} > 0

# Revocation propagation latency
histogram_quantile(0.99,
  revocation_propagation_seconds_bucket) < 5

# Auth decision completeness: every request got a decision
requests_total - auth_decisions_total == 0
```

### 7.2 Config Propagation Consistency Monitoring

**The requirement:**

> After `config_published(version=V)`, all Gateway instances shall within 30 seconds satisfy `config_version_applied >= V`.

> Globally, Gateway shall satisfy `config_version_applied` is monotonically non-decreasing.

**Implementation approach:**

1. **Signal collection.** Each gateway instance reports its current config version as a gauge metric with instance labels.

2. **Consistency monitor.** A centralized monitor that:
   - Tracks the latest published config version
   - Queries all gateway instances' reported versions
   - Computes `max_version - min_version` across the fleet
   - Checks that convergence occurs within the time bound

3. **Monotonicity check.** Each gateway instance locally verifies that it never applies a config version lower than its current version. Violation indicates a rollback bug or corruption.

4. **Split-brain detection.** If `max_version - min_version > 1` persists beyond the convergence window, alert for potential split-brain condition.

**Concrete metrics:**

```promql
# Config convergence: max drift across fleet
max(config_version_applied) - min(config_version_applied) > 1
  # sustained for > 30 seconds = alert

# Config staleness: time since last config update
time() - config_last_applied_timestamp_seconds > 300
  # 5 minutes without config update when updates are expected

# Monotonicity violation (should never fire)
increase(config_version_rollback_total[1m]) > 0
```

### 7.3 Rate Limit Accuracy Monitoring

**The requirement:**

> Globally, for each tenant and rate limit window, Gateway shall satisfy `actual_requests_allowed <= configured_limit * 1.01` (1% tolerance for distributed counting).

> When `rate_limit_remaining(key) = 0`, Gateway shall at the next request satisfy `response_status = 429`.

**Why this is hard in distributed systems.** Rate limiting in a distributed API gateway involves multiple instances making independent decisions with eventually-consistent counters. Common failure modes:

- Counter synchronization lag allows over-admission
- Race conditions during counter decrement
- Stale counter values after network partition
- Counter reset at window boundaries allowing burst
- Different gateway instances having different views of the counter

**Implementation approach:**

1. **Per-window accounting.** At the end of each rate-limit window, compare actual allowed requests (from access logs) against the configured limit.

2. **Real-time over-admission detection.** Each gateway instance tracks its local view of the counter and the global configured limit. A stream processor aggregates across instances.

3. **Accuracy metric.**

```promql
# Over-admission ratio
(sum(rate_limited_requests_allowed_total) /
 sum(rate_limit_configured_max)) > 1.01
  # over 1% over-admission = alert

# Under-admission (false 429s)
rate_limit_false_rejections_total > 0
  # any false rejection is a potential revenue/UX issue
```

4. **Distributed counter consistency.** Monitor the divergence between local counter values and the authoritative value:

```promql
# Counter drift across instances
max(rate_limit_counter_value) - min(rate_limit_counter_value) > threshold
```

### 7.4 Tenant Isolation Invariant Checking

**The requirement:**

> Globally, Gateway shall satisfy that no request for tenant A is evaluated under tenant B's policy context.

> Globally, Gateway shall satisfy that no response data from tenant A's upstream is returned to tenant B.

**This is a hyperproperty** (relates multiple traces/tenants), making it challenging for single-trace runtime monitoring. Approaches:

1. **Context propagation verification.** Instrument all internal boundaries to log the tenant context. A trace processor verifies that tenant context is consistent across all spans within a trace.

2. **Cross-tenant query detection.** At the data layer, monitor for queries that reference data belonging to a different tenant than the request context. This requires the data layer to be tenant-aware.

3. **Canary tenant testing.** Maintain synthetic tenants with known, distinct configurations. Periodically send requests through each and verify that responses match the expected tenant-specific behavior.

4. **Invariant on routing.** Monitor that the upstream target selected for a request matches the tenant's configured backend:

```promql
# Routing violations: requests routed to wrong backend
tenant_routing_violations_total > 0  # should always be zero
```

5. **Memory and process isolation.** If tenant isolation relies on process-level or container-level separation, monitor for shared-resource violations (shared memory regions, shared file descriptors, shared connection pools across tenants).

### 7.5 Audit Completeness Verification

**The requirement:**

> Globally, for every request that receives an auth decision, Gateway shall eventually (within 1 second) satisfy that an audit event with the same correlation ID exists in the audit pipeline.

**Implementation approach:**

1. **Completeness counter.** Maintain two counters:
   - `auth_decisions_emitted_total` (incremented at auth decision time)
   - `audit_events_received_total` (incremented at audit pipeline ingestion)

   The invariant: `audit_events_received_total >= auth_decisions_emitted_total` (over any sufficiently large window to account for pipeline latency).

2. **Correlation-based verification.** A reconciliation process that:
   - Reads auth decision logs
   - Reads audit event logs
   - Matches by correlation ID
   - Reports unmatched auth decisions (missing audit events) and unmatched audit events (orphan events)

3. **Real-time gap detection.** A stream processor that watches the gap between the two counters. If the gap exceeds a threshold (accounting for pipeline latency), alert.

4. **Periodic reconciliation.** Daily or hourly batch job that performs full reconciliation and reports:
   - Total auth decisions
   - Total audit events
   - Match rate
   - Unmatched decisions (by type, tenant, time)
   - Latency distribution from decision to audit event

**Concrete metrics:**

```promql
# Audit completeness gap (real-time)
auth_decisions_emitted_total - audit_events_received_total > pipeline_latency_budget

# Audit pipeline latency
histogram_quantile(0.99, audit_event_latency_seconds_bucket) < 1.0

# Audit pipeline throughput (should match decision throughput)
rate(audit_events_received_total[5m]) /
rate(auth_decisions_emitted_total[5m]) < 0.99
  # ingestion falling behind = alert
```

### 7.6 Alert Design as Safety-Critical Notification

In safety-critical systems, alerts are not just notifications — they are safety mechanisms. A missed or misunderstood alert can be as dangerous as a missed fault detection.

**ISO 26262-inspired alert design principles:**

1. **Classification by severity.** Map alert severity to consequence, not just symptom:
   - **Critical (ASIL-D equivalent):** Tenant isolation violation, auth bypass, data corruption. Requires immediate human response. Multiple notification channels. Escalation if not acknowledged within minutes.
   - **High (ASIL-C equivalent):** Config propagation failure, audit gap, rate limit accuracy degradation. Requires response within the hour.
   - **Medium (ASIL-B equivalent):** Elevated error rates, latency degradation, canary failures. Requires investigation within the shift.
   - **Low (ASIL-A equivalent):** Informational anomalies, capacity warnings, certificate expiry warnings. Scheduled review.

2. **Alert-to-requirement traceability.** Every alert should trace to one or more requirements or invariants. Alerts that cannot be traced to a requirement are either:
   - Symptom-based (which should ideally trace to a root-cause requirement)
   - Orphaned (which should be evaluated for removal or requirement creation)

3. **Diagnostic coverage of alerts.** Just as ISO 26262 requires analyzing the diagnostic coverage of safety mechanisms, the set of alerts should be analyzed for coverage:
   - Which requirements have no corresponding alerts? (coverage gap)
   - Which failure modes have no corresponding alerts? (detection gap)
   - Which alerts have never fired? (possibly misconfigured or testing gap)
   - Which alerts fire frequently without action? (alert fatigue, desensitization risk)

4. **Alert reliability.** The alerting pipeline itself must be monitored:
   - Dead man's switch: "If we haven't received any alerts in X hours, something is wrong with alerting"
   - Alert pipeline latency: time from condition detection to human notification
   - Alert delivery confirmation: was the alert actually received by the on-call?
   - Escalation automation: automatic escalation if not acknowledged

5. **Avoiding alert fatigue.** Alert fatigue is the runtime-monitoring equivalent of "alarm flooding" in industrial safety. ISO 62682 (Management of Alarms for the Process Industries) provides principles applicable to software:
   - Prioritize alerts by consequence, not frequency
   - Suppress derivative alerts (alerts caused by other alerts)
   - Design for the "maximum manageable alert rate" per operator
   - Regularly review and rationalize the alert set

**Alert design template:**

```yaml
alert:
  name: "auth_bypass_detected"
  severity: critical
  linked_requirements:
    - REQ-AUTH-001
    - REQ-AUTH-005
  linked_signals:
    - auth_decision
    - api_key_status
  condition: >
    Any auth_decision = "allow" where the key's current status
    in the authority database is "revoked"
  detection_latency_budget: "< 30 seconds"
  notification_channels:
    - pagerduty_critical
    - slack_security_channel
    - email_security_team
  escalation:
    if_not_acknowledged_within: "5 minutes"
    escalate_to: "engineering_director + security_lead"
  response_runbook: "runbooks/auth_bypass.md"
  false_positive_rate_target: "< 1%"
  last_reviewed: "2026-03-01"
  reviewer: "security-team"
```

---

## Summary: Connecting the Disciplines

The core argument of this reference is that runtime monitoring and observability, when practiced with engineering discipline, become a *safety assurance activity* rather than just an operational convenience.

**The layered verification model:**

```
Layer 1: Requirements Analysis (FRET, realizability checking)
  "Are our requirements consistent and implementable?"

Layer 2: Design-Time Verification (Kind 2, model checking)
  "Does our design satisfy the requirements for all inputs?"

Layer 3: Test-Time Verification (requirement-based testing)
  "Does our implementation satisfy the requirements for tested inputs?"

Layer 4: Runtime Monitoring (Copilot, R2U2, production monitors)
  "Does our deployed system satisfy the requirements right now?"

Layer 5: Operational Observability (structured logs, metrics, traces)
  "Can we continuously produce evidence of correct operation?"

Layer 6: Post-Hoc Analysis (audit reconciliation, trace analysis)
  "Can we retrospectively verify that requirements were satisfied?"
```

Each layer catches failures that escape the layers above it. The Signals Catalog provides the common vocabulary across all layers. Requirements traceability links every layer back to the original behavioral claims.

**For an API platform team**, the practical starting point is:

1. Identify the 10-15 most critical behavioral requirements (auth, isolation, rate limiting, config consistency, audit completeness)
2. Build a Signals Catalog for those requirements
3. Implement invariant monitors for the most critical properties
4. Design alerts with severity classification and requirement traceability
5. Establish audit completeness verification as a continuous process
6. Use canary analysis as a lightweight form of runtime verification for deployments
7. Expand coverage based on incident findings and requirement changes

The discipline is not about adopting NASA tooling literally. It is about adopting the *engineering posture* that runtime behavior must be continuously verified against explicit claims, with structured evidence that can survive scrutiny.

---

## Key References

### NASA Tools and Publications

- **Copilot:** https://github.com/Copilot-Language/copilot — Pike, L., Goodloe, A., Morisset, R., Niller, S. "Copilot: A Hard Real-Time Runtime Monitor." RV 2010.
- **R2U2:** https://github.com/R2U2/r2u2 — Reinbacher, T., Rozier, K.Y., Schumann, J. "Temporal-Logic Based Runtime Observer Pairs for System Health Management of Real-Time Systems." TACAS 2014.
- **Ogma:** https://github.com/nasa/ogma — Perez, I., Goodloe, A. "From Requirements to Autonomous Flight: An Overview of the Monitoring ICAROUS Project." NASA/TM-20220000049.
- **FRET:** https://github.com/NASA-SW-VnV/fret — Giannakopoulou, D., Pressburger, T., Mavridou, A., Schumann, J. "Generation of Formal Requirements from Structured Natural Language." NASA, 2020.
- **FRET-to-Copilot pipeline:** https://ntrs.nasa.gov/api/citations/20220000049/downloads/Technical_Report_Copilot_FRET%20%284%29.pdf
- **Lift-Plus-Cruise FRET case study:** https://ntrs.nasa.gov/api/citations/20220017032/downloads/TechnicalReport_Lift_Plus_Cruise_FRET_case_study%20%284%29.pdf
- **NASA Troupe system (FRET in practice):** https://ntrs.nasa.gov/api/citations/20240000218/downloads/SciTech_2024_TroupeSystem.pdf
- **AGREE/QFCS compositional verification:** Backes, J., et al. "Requirements Analysis of a Quad-Redundant Flight Control System." NFM 2015. https://loonwerks.com/publications/pdf/backes2015nfm.pdf
- **NPR 7150.2D (NASA Software Engineering Requirements):** https://nodis3.gsfc.nasa.gov/displayDir.cfm?Internal_ID=N_PR_7150_002D_
- **NASA-STD-8739.8B (Software Assurance and Software Safety Standard):** https://standards.nasa.gov/sites/default/files/standards/NASA/B/0/NASA-STD-87398-Revision-B.pdf

### Automotive Standards

- **ISO 26262:2018** — "Road vehicles — Functional safety." Parts 1-12.
- **ISO 21448:2022** — "Road vehicles — Safety of the intended functionality (SOTIF)."
- **ISO/PAS 8800** — "Road vehicles — Safety and artificial intelligence."
- **AUTOSAR E2E Protection:** AUTOSAR Specification of SW-C End-to-End Communication Protection Library.
- **Automotive SPICE (VDA QMC):** Process Reference Model / Process Assessment Model.
- **UN Regulation No. 155** — Cybersecurity and Cybersecurity Management Systems.
- **UN Regulation No. 156** — Software Updates and Software Update Management Systems.

### Runtime Verification and Monitoring

- Leucker, M., Schallhart, C. "A Brief Account of Runtime Verification." Journal of Logic and Algebraic Programming, 2009.
- Bartocci, E., Falcone, Y. (eds.) "Lectures on Runtime Verification." LNCS 10457, Springer, 2018.
- Havelund, K., Rosu, G. "Monitoring Programs using Rewriting." ASE 2001.
- Bauer, A., Leucker, M., Schallhart, C. "Runtime Verification for LTL and TLTL." ACM TOSEM, 2011.

### Observability and SRE

- Nygard, M. "Release It! Design and Deploy Production-Ready Software." Pragmatic Bookshelf.
- Beyer, B., Jones, C., Petoff, J., Murphy, N.R. "Site Reliability Engineering." O'Reilly, 2016.
- Sridharan, C. "Distributed Systems Observability." O'Reilly, 2018.
- Majors, C., Fong-Jones, L., Miranda, G. "Observability Engineering." O'Reilly, 2022.

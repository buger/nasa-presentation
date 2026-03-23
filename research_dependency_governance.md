# Dependency and Supply Chain Governance: NASA COTS Management and Automotive Supplier Qualification Applied to Software

## Overview

Safety-critical industries have decades of experience managing third-party components, supplier relationships, and tool qualification. NASA's approach to Commercial Off-The-Shelf (COTS) software, the automotive industry's supplier qualification frameworks under ISO 26262 and ASPICE, and emerging supply chain security standards (NIST SSDF, SLSA, EO 14028) all provide governance models that software engineering teams can adapt -- particularly for infrastructure software like API management platforms where reliability and security are paramount.

---

## 1. NASA's COTS (Commercial Off-The-Shelf) Software Management

### 1.1 NPR 7150.2D: NASA Software Engineering Requirements

NASA Procedural Requirements document **NPR 7150.2D** (NASA Software Engineering Requirements, current revision as of 2024) establishes the agency-wide framework for software engineering. It applies to all NASA software including flight software, ground systems, and mission-critical applications.

Key provisions relevant to COTS/acquired software:

- **Section 3.7 (Acquired Software)**: Requires that all acquired software (COTS, GOTS, open source, reused) undergo evaluation before use. The acquiring project must assess fitness for purpose, known defects, maintenance history, and vendor viability.

- **Classification-driven rigor**: NPR 7150.2D classifies software into Classes A through E based on criticality. Class A (human-rated flight software) demands the most rigorous COTS evaluation; Class E (non-critical support tools) the least. The COTS evaluation requirements scale accordingly.

- **Software Assurance Requirements**: The companion standard NASA-STD-8739.8 (Software Assurance and Software Safety Standard) requires that COTS components used in safety-critical applications undergo appropriate V&V.

**Source**: NASA, "NPR 7150.2D -- Software Engineering Requirements," NASA Procedural Requirements, Office of the Chief Engineer.

### 1.2 COTS Evaluation Process

NASA's COTS evaluation process, documented across NPR 7150.2D and supporting handbooks (NASA-HDBK-2203, NASA Software Engineering Handbook), involves:

1. **Identification and Selection**
   - Functional requirements mapping: Does the COTS product meet the functional needs?
   - Interface compatibility assessment
   - Vendor stability and long-term support evaluation
   - Licensing terms review (especially for flight software where source code access may be required for debugging)

2. **Technical Evaluation**
   - Review of vendor's development process documentation
   - Analysis of the product's defect/problem report history
   - Assessment of the product's operational history ("proven in use" evidence)
   - Evaluation of configuration management practices
   - Security vulnerability assessment

3. **Risk Assessment**
   - What happens if the vendor discontinues the product?
   - Can the product be replaced without redesigning the system?
   - What is the impact of a latent defect in the COTS component?
   - Are there known single points of failure introduced by the COTS product?

4. **Acceptance Testing**
   - COTS components are never accepted "as-is" for Class A/B software
   - Project-specific acceptance tests verify the component in the target environment
   - Regression testing is required when COTS components are updated

**Source**: NASA, "NASA-HDBK-2203: NASA Software Engineering Handbook," 2020.

### 1.3 The "Proven in Use" Argument

NASA employs the concept of **"proven in use"** (sometimes called "heritage software") as one factor in evaluating COTS and reused software. This concept has direct parallels to IEC 61508's "proven in use" argument and ISO 26262's "proven in use safety element."

Key principles:

- **Operational history is evidence, not proof**: A component that has run successfully for 10 years in a similar environment provides evidence of reliability, but does not eliminate the need for analysis. The operating environment, interfaces, and usage patterns must be sufficiently similar.

- **Configuration control is essential**: The "proven" argument applies only to the exact version and configuration that has the operational history. Any modification, recompilation, or change in the operating environment weakens the argument.

- **Documented evidence required**: NASA requires documented evidence of the operational history, including hours of operation, failure reports, and the similarity analysis between the heritage environment and the new application.

- **Not a substitute for V&V**: NPR 7150.2D makes clear that "proven in use" reduces but does not eliminate V&V requirements. The degree of reduction depends on the software classification and the strength of the heritage evidence.

In the NASA-STD-8739.8 (Software Assurance and Software Safety Standard), the concept is formalized: reused software components must have documented pedigree, and the project must perform a gap analysis between the original context and the new application.

**Source**: NASA, "NASA-STD-8739.8: Software Assurance and Software Safety Standard"; IEC 61508-7, Annex C ("Proven in Use Assessment").

### 1.4 Configuration Management of COTS Components

NASA's configuration management (CM) requirements for COTS software include:

- **Baseline identification**: Each COTS component version used in a project must be formally identified in the project's software configuration index. This includes version numbers, patch levels, build identifiers, and checksums.

- **Change control**: Updates to COTS components go through the project's change control process. The engineering review board evaluates whether the update is necessary, what risks it introduces, and what retesting is required.

- **Vendor notification tracking**: Projects must track vendor bulletins, security advisories, and end-of-life announcements. This maps directly to modern dependency vulnerability monitoring.

- **Escrow and archival**: For mission-critical COTS, NASA projects may require source code escrow agreements or maintain archived copies of the exact binary used, ensuring reproducibility even if the vendor ceases operations.

- **Interface control documents**: The interfaces between the COTS component and the rest of the system must be formally documented. Changes to these interfaces trigger re-evaluation.

**Source**: NASA, "NPR 7150.2D"; NASA, "NASA-HDBK-2203."

### 1.5 When COTS Software Needs Additional V&V

Additional verification and validation beyond standard acceptance testing is required when:

- The COTS component is used in a **safety-critical function** (Class A or B software)
- The COTS component is used **outside its vendor-validated operating envelope** (different OS, hardware, load conditions)
- The COTS component has **limited operational history** in similar applications
- The COTS component performs **calculations or transformations** whose correctness is critical to mission success
- The vendor **cannot provide adequate documentation** of their development and testing processes
- There are **known defects** in the component that overlap with the project's use cases

NASA's IV&V Center (located at Fairmont, WV) may be engaged for independent assessment of COTS components in the highest-criticality applications, particularly when COTS software is embedded in human-rated flight systems.

**Source**: NASA IV&V Center; NPR 7150.2D Section 3.7; NASA-STD-8739.8.

---

## 2. Automotive Supplier Qualification

### 2.1 ISO 26262 Part 8: Qualification of Software Components

**ISO 26262:2018 Part 8** ("Supporting processes") addresses the qualification of software components (Section 12) and the qualification of software tools (Section 11). These are distinct processes:

**Software Component Qualification (Part 8, Clause 12)**:

When a pre-existing software component (e.g., a third-party library, COTS RTOS, or open-source stack) is used in a safety-related system, ISO 26262 requires qualification if the component was not developed according to ISO 26262.

ISO 26262 Part 8 Clause 12 provides three equally valid qualification approaches:

1. **Qualification by increased confidence from use**: Analogous to NASA's "proven in use." Requires documented evidence of operational history in comparable applications, analysis of problem reports, and demonstration that the component's operational conditions in the new application are within the bounds of its demonstrated operational history.

2. **Qualification by assessment of the development process**: The component's development process is evaluated against ISO 26262 requirements. Gaps are identified and mitigating measures applied. This is often done through audits and documentation review.

3. **Qualification by validation of the software component**: The component is subjected to testing at the target ASIL (Automotive Safety Integrity Level) to demonstrate it meets its safety requirements, regardless of how it was developed.

For each approach, the rigor scales with the target ASIL (A through D, with D being the most stringent).

**Source**: ISO 26262:2018, Part 8, Clause 12 ("Qualification of software components").

### 2.2 ASPICE (Automotive SPICE) and Supplier Capability

**Automotive SPICE** (based on ISO/IEC 33004 (requirements for process reference and assessment models) and ISO/IEC 33020 (process measurement framework). ISO/IEC 33002 covers requirements for performing assessments) is the automotive industry's standard framework for assessing supplier software development capability. It is maintained by the VDA (Verband der Automobilindustrie) QMC working group.

Key aspects:

- **Process Reference Model (PRM)**: Defines processes across categories: acquisition (ACQ), supply (SPL), system engineering (SYS), software engineering (SWE), support (SUP), management (MAN), and process improvement (PIM).

- **Capability Levels 0-5**:
  - Level 0: Incomplete -- process not implemented or fails to achieve its purpose
  - Level 1: Performed -- process achieves its outcomes but may not be rigorously managed
  - Level 2: Managed -- process is planned, monitored, and adjusted; work products are appropriately managed
  - Level 3: Established -- a defined process based on a standard process is used
  - Level 4: Predictable -- process operates within defined limits to achieve its outcomes
  - Level 5: Innovating -- process is continuously improved

- **Typical OEM requirements**: Major OEMs (BMW, Volkswagen, Daimler, etc.) typically require ASPICE Capability Level 2 or 3 for Tier 1 suppliers providing safety-relevant software. Some OEMs mandate specific processes (SWE.1 through SWE.6, SUP.8, SUP.10) at Level 3.

- **Assessment method**: ASPICE assessments are performed by certified assessors (Provisional, Competent, or Principal) following the VDA Automotive SPICE guidelines. Assessments produce a process capability profile showing the level achieved for each assessed process.

> **Note**: ASPICE 4.0 (2023) restructured some process groups and added Machine Learning Engineering (MLE) process areas. The capability level descriptions here align with the 3.1 framework; verify against 4.0 for current projects.

**Source**: VDA QMC, "Automotive SPICE Process Assessment / Reference Model v3.1" (2017, updated 4.0 in 2023); ISO/IEC 33020.

### 2.3 The Development Interface Agreement (DIA)

The **Development Interface Agreement** is a critical artifact in automotive supplier management, required by both ISO 26262 and ASPICE:

**ISO 26262 Part 8, Clause 5** requires a DIA when safety-related development is distributed across organizations. The DIA must specify:

- **Responsibilities**: Clear assignment of who is responsible for each activity (requirements, design, implementation, testing, safety analysis, etc.)
- **Deliverables and artifacts**: What each party must produce and deliver, including documentation, source code, test results, and safety analyses
- **Processes and methods**: Agreement on development processes, tools, coding standards, and safety analysis methods
- **Communication protocols**: How issues, changes, and defects are communicated between parties
- **Configuration management**: How shared components are versioned and controlled
- **Verification and validation**: Who performs what testing at what level, and what evidence must be provided
- **Change management**: How changes are proposed, evaluated, approved, and implemented across the interface

The DIA is the contractual and technical backbone of the supplier relationship. Without it, ISO 26262 compliance auditors will flag a non-conformance.

**Mapping to software**: The DIA concept maps to dependency governance as the formalized agreement about what a dependency provides (its contract/API), how it is maintained, how breaking changes are communicated, and what quality assurance the maintainer commits to.

**Source**: ISO 26262:2018, Part 8, Clause 5 ("Interfaces within distributed developments").

### 2.4 Tier 1/2/3 Supplier Management

The automotive tiered supplier model:

- **OEM (Original Equipment Manufacturer)**: The vehicle manufacturer (e.g., Toyota, BMW). Responsible for system-level safety and integration.
- **Tier 1**: Direct suppliers to the OEM (e.g., Bosch, Continental, Denso). Typically supply complete subsystems (ECUs, braking systems, infotainment units). Must meet the most rigorous process requirements.
- **Tier 2**: Supply components to Tier 1 suppliers (e.g., semiconductor companies, software platform vendors). Requirements flow down from Tier 1.
- **Tier 3**: Supply raw materials or basic components to Tier 2.

**Governance mechanisms at each tier**:

| Mechanism | OEM to Tier 1 | Tier 1 to Tier 2 | Tier 2 to Tier 3 |
|-----------|---------------|-------------------|-------------------|
| ASPICE Assessment | Required (Level 2-3) | Often required (Level 2) | Rare |
| ISO 26262 Compliance | Full (target ASIL) | Proportional to contributed ASIL | By exception |
| DIA | Always required | Required for safety-relevant | Simplified |
| Audit Rights | Contractual | Contractual | Limited |
| PPAP/APQP | Full | Tailored | Basic |

**Key insight**: Requirements and quality expectations flow down the supply chain, but each tier is responsible for qualifying its own suppliers. The OEM does not typically audit Tier 3 directly -- it relies on Tier 1 to manage Tier 2, and Tier 2 to manage Tier 3. This is a transitive trust model.

**Source**: IATF 16949:2016 (Automotive QMS); VDA Volume 6.3 (Process Audit); ISO 26262:2018 Part 8.

### 2.5 Supplier Maturity Assessment: CMMI and ASPICE Capability Levels

OEMs assess supplier maturity through:

- **ASPICE assessments** (primary mechanism in European and Asian automotive): Process-specific capability levels, assessed by certified assessors. Results are shared via the VDA assessment exchange platform.

- **CMMI (Capability Maturity Model Integration)**: More common in North American automotive and aerospace. Uses Maturity Levels 1-5 at the organizational level, or Capability Levels 0-3 at the process area level. CMMI V2.0 (maintained by the CMMI Institute / ISACA) aligns practice areas with modern development approaches.

- **Supplier self-assessments**: Standardized questionnaires (e.g., VDA Volume 6.3 audit questionnaire) that suppliers complete and OEMs verify.

- **Product quality metrics**: Defect rates, warranty claims, field failure data, and response times to problem reports serve as lagging indicators of supplier maturity.

**Source**: CMMI Institute, "CMMI V2.0 Model"; VDA QMC, "VDA Volume 6.3: Process Audit."

---

## 3. Tool Qualification

### 3.1 ISO 26262 Tool Confidence Levels

**ISO 26262 Part 8, Clause 11** defines a method for qualifying software tools used in the development of safety-related systems.

**Tool Classification**:

Tools are classified based on two dimensions:

1. **Tool Impact (TI)**: Can a malfunction of the tool introduce or fail to detect errors in the safety-related item?
   - TI1: No such impact (e.g., a text editor)
   - TI2: Possible impact (e.g., a compiler, code generator, test tool)

2. **Tool Error Detection (TD)**: Is there confidence that a tool malfunction will be detected?
   - TD1: High confidence (e.g., tool output is independently verified)
   - TD2: Medium confidence
   - TD3: Low confidence (e.g., tool output is used directly without independent checks)

**Tool Confidence Level (TCL) Matrix**:

| | TD1 | TD2 | TD3 |
|-----|-----|-----|-----|
| TI1 | TCL1 | TCL1 | TCL1 |
| TI2 | TCL1 | TCL2 | TCL3 |

- **TCL1**: No qualification needed
- **TCL2**: Qualification required -- can use increased confidence from use, tool development process evaluation, or validation of the tool
- **TCL3**: Qualification required -- more rigorous evidence needed, typically validation of the tool in the specific use case

**Source**: ISO 26262:2018, Part 8, Clause 11 ("Qualification of software tools").

### 3.2 NASA's Approach to Tool Qualification

NASA's approach to tool qualification is embedded in NPR 7150.2D and NASA-STD-8739.8:

- **Development tools that generate deliverable code** (compilers, code generators, auto-coders) must be qualified. For Class A/B software, this means demonstrating that the tool correctly transforms its input to output, typically through a combination of tool validation tests and comparison with independently derived results.

- **Verification tools** (static analyzers, test coverage tools, model checkers) must be qualified to ensure they do not give false confidence. A static analyzer that misses defects or a coverage tool that reports incorrect coverage undermines the verification argument.

- **NASA IV&V considerations**: The NASA IV&V program has studied tool qualification extensively. Their guidance emphasizes that tool qualification is not a one-time activity -- it must be revisited when the tool is updated, when the operating environment changes, or when the tool is used for a different purpose.

- **JPL Institutional Coding Standard (JPL-STD-C)**: JPL's coding standard includes requirements about which compilers and compiler options are permitted, effectively qualifying the compiler by constraining its use to a validated configuration.

**Source**: NPR 7150.2D; NASA-STD-8739.8; JPL, "JPL Institutional Coding Standard for the C Programming Language" (JPL DOCID D-60411).

### 3.2.1 DO-178C / DO-330: Aerospace Tool Qualification

DO-330 (Software Tool Qualification Considerations), the companion to DO-178C, provides the most detailed tool qualification framework in any safety domain. It defines five Tool Qualification Levels (TQL-1 through TQL-5) based on tool output criticality and potential to introduce or fail-to-detect errors. For teams in NASA contexts, DO-330's framework is often more directly applicable than ISO 26262's TCL approach, since NASA frequently references DO-178C for crew vehicle software.

**Source**: RTCA, "DO-178C -- Software Considerations in Airborne Systems and Equipment Certification" (2011); RTCA, "DO-330 -- Software Tool Qualification Considerations" (2011).

### 3.3 Mapping Tool Qualification to Software Engineering Tools

The tool qualification framework maps to modern software engineering tools:

| Tool | TI Assessment | TD Assessment | Likely TCL | Qualification Approach |
|------|--------------|---------------|------------|----------------------|
| **Compiler (e.g., Go compiler)** | TI2 (generates executable code) | TD2 (tests may catch compiler bugs, but not all) | TCL2 | Validate with known-good test suites; pin compiler version |
| **CI/CD pipeline (e.g., GitHub Actions)** | TI2 (determines what gets deployed) | TD2 (deployment verification exists but may miss issues) | TCL2 | Validate pipeline behavior; use signed artifacts; audit pipeline definitions |
| **Linter (e.g., golangci-lint)** | TI2 (failure to detect could miss safety issues) | TD1 (linting is one of many verification layers) | TCL1 | Minimal qualification; keep updated |

> **Note**: The TI2 classification for linters is a conservative interpretation. A linter's failure mode is passive (fails to detect, rather than actively introducing errors), which some interpretations would classify as TI1.
| **Code generator (e.g., OpenAPI generator)** | TI2 (generates production code) | TD3 (generated code often used without line-by-line review) | TCL3 | Validate generated output; maintain test suites for generated code; pin version |
| **AI coding assistant** | TI2 (generates code suggestions) | TD2-TD3 (depends on review process) | TCL2-TCL3 | Mandatory human review; validate suggestions; track provenance of AI-generated code |
| **Test framework** | TI2 (false passes could mask defects) | TD2 (other testing layers may catch issues) | TCL2 | Validate test framework with known-pass and known-fail cases |
| **Database migration tool** | TI2 (incorrect migration corrupts data) | TD3 (migrations often applied without independent verification) | TCL3 | Validate migrations in staging; maintain rollback capability; review generated SQL |

**Source**: Analysis derived from ISO 26262:2018, Part 8, Clause 11 framework applied to software development tools.

---

## 4. Open-Source Software as COTS

### 4.1 Applying COTS Governance to Open-Source Dependencies

Open-source software is functionally equivalent to COTS from a governance perspective, but with distinct characteristics:

| Dimension | Traditional COTS | Open-Source |
|-----------|-----------------|-------------|
| Vendor relationship | Contractual, with SLAs | Community-based, no SLAs |
| Source code access | Typically unavailable | Available by definition |
| Support | Vendor-provided | Community or commercial third-party |
| Update cadence | Vendor-controlled releases | Varies widely (days to years) |
| Security patching | Vendor responsibility with contractual timelines | Community-driven, variable response times |
| License terms | Commercial license | OSS license (MIT, Apache 2.0, GPL, etc.) |
| Long-term viability | Tied to vendor business | Tied to community health |

NASA's COTS evaluation criteria translate to open-source as follows:

- **Vendor viability** becomes **community health**: Number of active contributors, commit frequency, issue response times, bus factor (what happens if the primary maintainer leaves?), foundation backing (Apache Foundation, CNCF, Linux Foundation).

- **Defect history** becomes **issue and CVE history**: Public issue trackers, CVE database entries, and the project's track record of responding to security reports.

- **Operational history** becomes **adoption metrics**: Download counts, known production deployments, inclusion in other qualified products.

- **Configuration management** translates directly: Version pinning, checksum verification, signed releases.

### 4.2 Dependency Review Processes

A structured dependency review process adapted from NASA/automotive qualification:

**Phase 1: Intake Assessment** (analogous to NASA COTS identification)
- What does this dependency do? Is it necessary, or can we implement the functionality ourselves?
- What is the dependency's license? Is it compatible with our distribution model?
- What is the dependency's transitive dependency tree? (Use `go mod graph`, `npm ls`, `pip show`)
- What is the maintenance status? (Last release date, open issue count, contributor count)

**Phase 2: Technical Evaluation** (analogous to NASA technical evaluation)
- Code quality review: Does the code follow good practices? Are there obvious red flags?
- Security review: Has the dependency been audited? Are there known CVEs? Does it handle sensitive data?
- Performance evaluation: Does it meet our performance requirements? Any known performance issues?
- API stability: Does the project follow semantic versioning? History of breaking changes?

**Phase 3: Risk Classification** (analogous to NASA software classification)
- **Critical**: Dependency is in the request processing path, handles authentication/authorization, or processes sensitive data. Requires full evaluation.
- **Standard**: Dependency supports core functionality but is not in the critical path. Requires standard evaluation.
- **Development-only**: Dependency is used only in development/testing. Requires basic evaluation.

**Phase 4: Ongoing Monitoring** (analogous to NASA CM and vendor tracking)
- Automated vulnerability scanning (Dependabot, Snyk, Trivy)
- License compliance monitoring
- Version update tracking with automated compatibility testing

### 4.3 SBOM (Software Bill of Materials)

The **Software Bill of Materials** concept has been formalized through multiple standards:

- **SPDX (Software Package Data Exchange)**: ISO/IEC 5962:2021. Originally developed by the Linux Foundation. Provides a standard format for communicating the components, licenses, and copyrights associated with software. SPDX 2.3 and 3.0 support detailed package information, relationships, and security references.

- **CycloneDX**: OWASP standard for SBOM. Designed with security use cases in mind. Supports component identity, dependency relationships, vulnerability references, and license information. Native support in many build tools.

- **SWID Tags (ISO/IEC 19770-2)**: Primarily for installed software identification, less commonly used for dependency tracking.

**SBOM generation for Go projects**:
```
# Using cyclonedx-gomod
cyclonedx-gomod mod -json -output bom.json

# Using syft (supports multiple formats)
syft packages dir:. -o spdx-json=sbom.spdx.json
syft packages dir:. -o cyclonedx-json=sbom.cdx.json
```

**SBOM in the NASA/automotive context**: An SBOM is the software equivalent of a parts list in a hardware bill of materials. Just as NASA tracks every bolt and washer in a spacecraft (with part numbers, lot numbers, and material certifications), an SBOM tracks every software component with its identity, version, provenance, and license.

**Source**: NTIA, "The Minimum Elements For a Software Bill of Materials (SBOM)," 2021; ISO/IEC 5962:2021 (SPDX); OWASP, "CycloneDX Specification."

### 4.4 Vulnerability Tracking

Structured vulnerability management for dependencies:

- **CVE (Common Vulnerabilities and Exposures)**: The MITRE-managed standard identification system for vulnerabilities. Each CVE entry includes a description, affected versions, and severity rating.

- **NVD (National Vulnerability Database)**: NIST-maintained database that enriches CVE data with CVSS scores, CPE identifiers, and remediation information.

- **OSV (Open Source Vulnerabilities)**: Google-initiated database specifically for open-source vulnerabilities. Uses the OSV schema, which includes precise affected version ranges and ecosystem-specific identifiers. The Go vulnerability database (vuln.go.dev) uses this format.

- **GitHub Advisory Database**: GitHub's curated database of vulnerabilities, feeding Dependabot alerts.

**Automated scanning tools**:
- `govulncheck` (official Go vulnerability checker, uses vuln.go.dev)
- Trivy (Aqua Security, container and filesystem scanning)
- Grype (Anchore, SBOM-based vulnerability scanning)
- Snyk (commercial, with open-source tier)
- Dependabot (GitHub-native)

**Source**: MITRE, "CVE Program"; NIST, "National Vulnerability Database"; Google, "OSV Schema."

### 4.5 License Compliance

Open-source license compliance is a governance concern that has no direct analog in traditional COTS (where licensing is handled contractually):

- **Permissive licenses** (MIT, BSD, Apache 2.0): Allow broad use with minimal obligations (typically attribution). Low compliance risk.

- **Copyleft licenses** (GPL, LGPL, AGPL, MPL): Impose obligations on derivative works. The GPL "viral" effect can require releasing proprietary source code. AGPL extends this to network use (server-side software).

- **License scanning tools**: FOSSA, Black Duck (Synopsys), ScanCode, licensee (GitHub). These tools detect licenses in source files, not just declared licenses in package metadata.

- **Go-specific considerations**: Go modules declare licenses at the module root. Tools like `go-licenses` (Google) can enumerate all licenses in a dependency tree. The Go module proxy (proxy.golang.org) caches module versions, providing some supply chain stability.

**Source**: Open Source Initiative (OSI), license definitions; SPDX License List (spdx.org/licenses).

### 4.6 SLSA (Supply-chain Levels for Software Artifacts)

**SLSA** (pronounced "salsa") is a framework originally developed at Google and now an OpenSSF project, providing a graduated set of supply chain security requirements:

- **SLSA Level 1 (Build L1)**: The build process is documented. Provenance is available (who built it, from what source, using what process). Equivalent to basic traceability.

- **SLSA Level 2 (Build L2)**: The build is executed by a hosted build service (not a developer laptop). Provenance is signed by the build service. This prevents many tampering attacks.

- **SLSA Level 3 (Build L3)**: The build service is hardened. The build is isolated (containers/VMs), and the provenance is non-falsifiable. The build service itself is audited. This is the level that resists insider threats.

**SLSA mapping to NASA/automotive concepts**:
- SLSA Level 1 corresponds to basic configuration identification (knowing what you have)
- SLSA Level 2 corresponds to controlled build processes (NASA's software build standards, automotive ASPICE SWE.5)
- SLSA Level 3 corresponds to the rigor of a Class A/B software build environment

**Source**: OpenSSF, "SLSA Specification" (slsa.dev); Google, "Achieving SLSA Compliance."

### 4.7 Sigstore and Provenance

**Sigstore** is an open-source project (Linux Foundation / OpenSSF) that provides free code signing and verification infrastructure:

- **Cosign**: Signs and verifies container images and other artifacts. Uses keyless signing with identity-based certificates from Fulcio.
- **Fulcio**: Free certificate authority that issues short-lived certificates based on OIDC identity (e.g., GitHub Actions identity).
- **Rekor**: Immutable transparency log that records signing events. Provides a public, auditable record of all signing operations.
- **Gitsign**: Extends Sigstore to Git commits.

**Provenance verification with Sigstore**:
- A CI/CD pipeline builds an artifact and generates a SLSA provenance attestation
- The attestation is signed using Sigstore (keyless, tied to the CI/CD pipeline's identity)
- The signature is recorded in Rekor
- Consumers can verify the attestation, confirming that the artifact was built by the claimed pipeline from the claimed source

This is functionally equivalent to NASA's requirement for traceable, configuration-controlled builds with verified provenance.

**Source**: Sigstore project (sigstore.dev); OpenSSF, "Securing Software Repositories."

---

## 5. Software Supply Chain Security

### 5.1 NIST SSDF (Secure Software Development Framework)

**NIST SP 800-218** defines the **Secure Software Development Framework (SSDF)**, a set of fundamental, sound, secure software development practices. It was developed in response to Executive Order 14028 and provides the basis for federal software security requirements.

The SSDF organizes practices into four groups:

1. **Prepare the Organization (PO)**:
   - PO.1: Define security requirements for software development
   - PO.2: Implement roles and responsibilities
   - PO.3: Implement supporting toolchains (secured build environments, signing infrastructure)
   - PO.4: Define criteria for software security checks
   - PO.5: Implement and maintain secure development environments

2. **Protect the Software (PS)**:
   - PS.1: Protect all forms of code from unauthorized access and tampering
   - PS.2: Provide a mechanism for verifying software release integrity (signing, checksums)
   - PS.3: Archive and protect each software release (reproducibility)

3. **Produce Well-Secured Software (PW)**:
   - PW.1: Design software to meet security requirements and mitigate risks
   - PW.4: Reuse existing well-secured software (vetted dependencies)
   - PW.5: Create source code by adhering to secure coding practices
   - PW.6: Configure the compilation, interpreter, and build processes to improve security
   - PW.7: Review and/or analyze human-readable code for vulnerabilities
   - PW.8: Test executable code for vulnerabilities
   - PW.9: Configure software to have secure settings by default

4. **Respond to Vulnerabilities (RV)**:
   - RV.1: Identify and confirm vulnerabilities
   - RV.2: Assess, prioritize, and remediate vulnerabilities
   - RV.3: Analyze vulnerabilities to identify root causes

**SSDF's relationship to NASA practices**: The SSDF practices are broadly compatible with NASA's software assurance requirements. NASA's more rigorous requirements (Class A/B) exceed SSDF in many areas, but SSDF provides a solid baseline that aligns with NASA Class C/D requirements.

**Source**: NIST, "SP 800-218: Secure Software Development Framework (SSDF) Version 1.1," February 2022.

### 5.2 Executive Order 14028

**Executive Order 14028, "Improving the Nation's Cybersecurity"** (May 12, 2021) established requirements that reshaped software supply chain governance for all software sold to the U.S. federal government:

Key provisions relevant to supply chain governance:

- **Section 4(e)**: Requires agencies to obtain a self-attestation from software producers that the software was developed in conformity with NIST SSDF practices. For critical software, third-party assessment may be required.

- **Section 4(f)**: Requires SBOM provision. Software producers must provide an SBOM for each product, updated with each new release.

- **Section 4(g)**: Establishes vulnerability disclosure programs as a requirement.

- **OMB M-22-18** ("Enhancing the Security of the Software Supply Chain through Secure Software Development Practices"): Implements EO 14028 Section 4, requiring software producers to self-attest to SSDF compliance and provide SBOMs.

- **OMB M-23-16**: Updates and extends M-22-18, establishing timelines and the CISA secure software self-attestation form.

**Impact on software suppliers**: Any organization selling software to the U.S. government must now:
1. Attest to following SSDF practices
2. Provide SBOMs
3. Participate in vulnerability disclosure
4. Maintain evidence of secure development practices

**Source**: The White House, "Executive Order 14028: Improving the Nation's Cybersecurity," May 2021; OMB, "M-22-18"; OMB, "M-23-16."

### 5.3 NASA's Configuration Management Discipline Applied to Supply Chain Security

NASA's CM discipline provides a rigorous model for modern supply chain security:

**NASA CM Principles** (from NPR 7150.2D and NASA-HDBK-2203):

1. **Identification**: Every item under configuration control has a unique identifier. For software, this means every source file, every build artifact, every dependency.

2. **Control**: Changes to controlled items go through a formal change control process. No "YOLO merges."

3. **Status Accounting**: The current state of all controlled items is known and recorded at all times. You can answer "what exactly is deployed right now?" at any moment.

4. **Audit**: Periodic verification that the actual configuration matches the recorded configuration. Functional Configuration Audits (FCA) verify that the software meets its requirements; Physical Configuration Audits (PCA) verify that the build is reproducible and matches the documented configuration.

**Mapping to modern supply chain security**:

| NASA CM Concept | Modern Supply Chain Equivalent |
|----------------|-------------------------------|
| Configuration Identification | Dependency lock files (go.sum, package-lock.json), SBOM |
| Change Control | PR review process, dependency update review, automated compatibility checks |
| Status Accounting | Deployment manifests, container image digests, infrastructure-as-code state |
| Functional Configuration Audit | Integration tests, contract tests, end-to-end tests |
| Physical Configuration Audit | Reproducible builds, provenance verification, SLSA compliance |

### 5.4 Dependency Pinning

**Dependency pinning** is the practice of locking dependencies to exact versions (or content hashes), directly implementing NASA's configuration identification principle:

- **Go modules**: `go.sum` provides cryptographic hash verification of module contents. `go.mod` specifies minimum version requirements. The Go module proxy and checksum database (sum.golang.org) provide a transparency log for module checksums.

- **Container images**: Pin by digest (`image@sha256:abc123...`) rather than tag (`:latest` or `:v1.2`). Tags are mutable; digests are not.

- **System packages**: Use exact version specifiers in Dockerfiles (`apt-get install package=1.2.3-4`).

- **CI/CD actions**: Pin GitHub Actions to commit SHA rather than tag (`uses: actions/checkout@a1b2c3d4` rather than `uses: actions/checkout@v4`).

### 5.5 Reproducible Builds

**Reproducible builds** ensure that given the same source code, build environment, and build instructions, the exact same binary is produced. This is the software equivalent of NASA's Physical Configuration Audit.

- **Go's reproducible build support**: Go produces reproducible binaries by default when the build environment is consistent. The `-trimpath` flag removes local filesystem paths from the binary, improving reproducibility.

- **Verification approach**: Build the artifact independently in two different environments. If the outputs match (byte-for-byte or content-equivalent), the build is reproducible. The Reproducible Builds project (reproducible-builds.org) provides tooling and guidance.

- **Build environment as configuration item**: The build environment itself (OS version, compiler version, library versions, environment variables) must be controlled. Container-based builds (using pinned base images) are the practical approach.

**Source**: Reproducible Builds project (reproducible-builds.org); Go documentation on build reproducibility.

---

## 6. Practical Application to API Platforms

### 6.1 Evaluating and Qualifying API Gateway Dependencies

An API gateway (e.g., Kong, Tyk, custom Go-based gateway) sits in the critical request path. Applying NASA/automotive qualification thinking:

**Criticality Classification**:
- **Safety-critical equivalent (Class A/B)**: Components in the request processing path (HTTP router, TLS library, authentication middleware, rate limiter). A defect here causes outages or security breaches.
- **Mission-critical equivalent (Class C)**: Components supporting core functionality (configuration management, logging, metrics). Degradation affects observability but not request processing.
- **Support equivalent (Class D/E)**: Development and testing tools, documentation generators.

**Qualification matrix for a Go-based API gateway**:

| Dependency | Classification | Qualification Approach |
|-----------|---------------|----------------------|
| `net/http` (stdlib) | Critical | Qualified by heritage (extensive proven-in-use history across Go ecosystem); pin Go version |
| `crypto/tls` (stdlib) | Critical | Qualified by heritage + security audit evidence; pin Go version; monitor Go security announcements |
| Third-party HTTP router (e.g., `chi`, `gorilla/mux`, `gin`) | Critical | Full evaluation: community health, CVE history, performance benchmarking, API stability review |
| JWT library (e.g., `golang-jwt/jwt`) | Critical | Full evaluation with security focus; verify OIDC/JWT compliance; review past CVEs (e.g., CVE-2020-26160 for dgrijalva/jwt-go) |
| Protocol Buffers / gRPC | Critical | Qualified by heritage (Google-maintained, massive proven-in-use); pin version |
| YAML/JSON parser | Standard | Standard evaluation; review for known parsing vulnerabilities (billion laughs, zip bombs) |
| Logging library (e.g., `zap`, `zerolog`) | Standard | Standard evaluation; verify no performance degradation under load |
| Prometheus client | Standard | Standard evaluation; verify metric cardinality limits |
| Test framework (e.g., `testify`) | Development-only | Basic evaluation; development-only classification |

### 6.2 Managing Go Module Dependencies with Safety Thinking

Applying NASA CM and automotive supplier governance to Go module management:

**1. Configuration Identification**:
- The `go.mod` file is the dependency specification; `go.sum` is the integrity verification record
- Treat `go.sum` as a controlled document -- never blindly accept changes from `go mod tidy` without review
- Generate and maintain an SBOM from `go.mod` as part of the release process

**2. Change Control**:
- Dependency updates are changes that require review, not routine maintenance
- Major version updates require full re-evaluation (new major version = new component from a governance perspective)
- Minor/patch updates require review of changelog, CVE fixes, and compatibility
- Automated tools (Dependabot, Renovate) create PRs, but humans review and approve

**3. Vendor Directory as Controlled Baseline**:
- `go mod vendor` creates a local copy of all dependencies, enabling:
  - Offline builds (no dependency on external infrastructure at build time)
  - Diff-based review of dependency updates (`git diff vendor/`)
  - Protection against dependency deletion ("left-pad" scenarios)
  - Compliance with NASA's archival and reproducibility requirements

**4. Vulnerability Monitoring**:
```
# Check for known vulnerabilities in dependencies
govulncheck ./...

# Generate SBOM
cyclonedx-gomod mod -json -output sbom.json

# Scan SBOM for vulnerabilities
grype sbom:sbom.json
```

### 6.3 Qualifying OpenAPI Generators, Policy Engines, and Database Drivers

**OpenAPI Code Generators** (e.g., openapi-generator, oapi-codegen):

Using ISO 26262 tool qualification:
- TI2 (generates production code), TD3 (generated code often not reviewed line-by-line) = **TCL3**
- Qualification approach:
  - Maintain a comprehensive test suite that validates generated code behavior, not just compilation
  - Pin the generator version and treat updates as changes requiring re-qualification
  - Review generated code diffs when the generator is updated
  - Consider generating into a separate, review-tracked directory

**Policy Engines** (e.g., OPA/Rego, Casbin, Cedar):

- Criticality: The policy engine is in the authorization path -- a defect means unauthorized access or denied legitimate requests
- Qualification approach:
  - Proven-in-use evidence (OPA is a CNCF graduated project with broad industry adoption)
  - Comprehensive policy testing with known-good and known-bad inputs
  - The policy language itself needs qualification: are Rego policies deterministic? Are there edge cases in policy evaluation?
  - Formal verification where possible (Cedar from AWS has formal verification backing)

**Database Drivers** (e.g., `lib/pq`, `pgx`, `go-sql-driver/mysql`):

- Criticality: In the data path; defects cause data corruption, leaks, or outages
- Qualification approach:
  - Proven-in-use assessment (widely deployed Go database drivers have extensive operational history)
  - Connection pool behavior under failure conditions (network partitions, database restarts)
  - Security review: SQL injection prevention, TLS support, credential handling
  - Performance qualification under expected load profiles

### 6.4 Building a Dependency Review Board

Modeled on NASA's Software Review Board and automotive change control boards:

**Composition**:
- Engineering lead (chair)
- Security representative
- Platform/infrastructure representative
- Quality/reliability representative

**Scope**:
- Reviews and approves all new dependency additions
- Reviews major version updates of critical dependencies
- Sets and maintains the dependency governance policy
- Conducts periodic reviews of the full dependency inventory

**Process**:
1. Engineer submits dependency request with justification, alternative analysis, and initial risk assessment
2. Automated analysis runs (license check, vulnerability scan, community health metrics, transitive dependency analysis)
3. Board reviews based on criticality classification:
   - Critical: Full board review with documented decision
   - Standard: Delegated review by security + engineering representatives
   - Development-only: Engineering lead approval sufficient
4. Decision is recorded in a dependency decision log (analogous to a design decision record)
5. Approved dependencies are added to an "approved dependencies" list
6. Periodic reviews (quarterly) assess the full dependency inventory for newly disclosed vulnerabilities, end-of-life components, and changed risk profiles

**Dependency Decision Record template**:
```
Dependency: [name and version]
Classification: [Critical / Standard / Development-only]
Purpose: [What problem does this solve?]
Alternatives considered: [What else was evaluated?]
License: [SPDX identifier]
Community health: [Contributors, last release, maintenance status]
Security history: [Past CVEs, audit status]
Transitive dependencies: [Count, notable inclusions]
Decision: [Approved / Approved with conditions / Rejected]
Conditions: [Any restrictions on use]
Review date: [Date]
Next review: [Date]
Reviewers: [Names]
```

### 6.5 Monitoring for Dependency Vulnerabilities in Production

**Pre-deployment scanning** (shift left):
- `govulncheck` in CI pipeline (Go-specific, checks only functions actually called)
- Container image scanning with Trivy or Grype before deployment
- SBOM generation and vulnerability matching as a deployment gate

**Runtime monitoring** (shift right):
- Continuous scanning of deployed container images against updated vulnerability databases
- Integration with vulnerability databases that push notifications (GitHub Dependabot, Snyk monitoring)
- Runtime Application Self-Protection (RASP) for detecting exploitation attempts

**Incident response for dependency vulnerabilities**:
1. **Detection**: Automated alert from scanning tool or public advisory
2. **Triage**: Assess exploitability in your specific usage context (NASA's environment-specific risk assessment)
3. **Classification**: CVSS score + contextual factors = priority level
4. **Remediation**: Update dependency, apply workaround, or accept risk with compensating controls
5. **Verification**: Regression testing after the update
6. **Communication**: Stakeholder notification and post-incident review

**SLA targets** (modeled on automotive response time expectations):
- Critical (CVSS 9.0+, exploitable in your context): Remediate within 24-48 hours
- High (CVSS 7.0-8.9): Remediate within 7 days
- Medium (CVSS 4.0-6.9): Remediate within 30 days
- Low (CVSS < 4.0): Remediate in next scheduled update cycle

---

## Key Sources and References

### NASA
- NASA, "NPR 7150.2D: Software Engineering Requirements" (current revision)
- NASA, "NASA-STD-8739.8: Software Assurance and Software Safety Standard"
- NASA, "NASA-HDBK-2203: NASA Software Engineering Handbook," 2020
- NASA IV&V Center guidance documents
- JPL, "JPL Institutional Coding Standard for the C Programming Language" (JPL DOCID D-60411)

### Automotive
- ISO 26262:2018, "Road vehicles -- Functional safety," Parts 1-12
- VDA QMC, "Automotive SPICE Process Assessment / Reference Model" v3.1 / v4.0
- IATF 16949:2016, "Quality management system requirements for automotive production and relevant service parts organizations"
- VDA Volume 6.3, "Process Audit"
- CMMI Institute / ISACA, "CMMI V2.0"

### Supply Chain Security
- NIST, "SP 800-218: Secure Software Development Framework (SSDF) Version 1.1," February 2022
- The White House, "Executive Order 14028: Improving the Nation's Cybersecurity," May 2021
- OMB, "M-22-18: Enhancing the Security of the Software Supply Chain"
- OMB, "M-23-16" (M-22-18 update)
- NTIA, "The Minimum Elements For a Software Bill of Materials (SBOM)," 2021

### Standards and Frameworks
- ISO/IEC 5962:2021 (SPDX specification)
- OWASP, "CycloneDX Specification"
- OpenSSF, "SLSA Specification" (slsa.dev)
- Sigstore project (sigstore.dev)
- IEC 61508, "Functional safety of electrical/electronic/programmable electronic safety-related systems"
- ISO/IEC 33020 (Process measurement framework for assessment of process capability)

### Vulnerability Databases
- MITRE, "CVE Program" (cve.org)
- NIST, "National Vulnerability Database" (nvd.nist.gov)
- Google, "OSV: Open Source Vulnerabilities" (osv.dev)
- Go Vulnerability Database (vuln.go.dev)
- Reproducible Builds project (reproducible-builds.org)

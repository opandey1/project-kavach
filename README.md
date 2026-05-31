# Project KAVACH

> *A two-surface security assessment for a fictional non-banking financial enterprise. Network forensics meets web application security, with synthesis as the deliverable.*

**Engagement** · Sprint 2–3 Combined · Futurense AI Clinic
**Programme** · PG Certification in AI-Enabled Cybersecurity · IIT Roorkee × Futurense Technologies
**Mode** · **Solo execution** — single contributor across all three workstreams
**Status** · `Iteration 1 — Frame` *(in progress)*
**Visibility** · Private repository · Cohort-licensed material · See §13 below

> This engagement is being executed solo. The brief explicitly anticipates this case — *"the engagement is designed to be completable by a determined subset of the team"* — and this repository follows that guidance, with adapted review and scope-management practices documented in §11–§12.

---

## Table of Contents

1. [Engagement Overview](#1-engagement-overview)
2. [Client Scenario](#2-client-scenario)
3. [Objectives & Success Criteria](#3-objectives--success-criteria)
4. [Scope](#4-scope)
5. [Workstreams](#5-workstreams)
6. [Iteration Roadmap](#6-iteration-roadmap)
7. [Repository Structure](#7-repository-structure)
8. [Quick Start & Reproducibility](#8-quick-start--reproducibility)
9. [Methodology & Standards](#9-methodology--standards)
10. [Tooling Stack](#10-tooling-stack)
11. [Solo Operating Model](#11-solo-operating-model)
12. [Working Conventions](#12-working-conventions)
13. [LLM Usage Policy](#13-llm-usage-policy)
14. [Deliverables Checklist](#14-deliverables-checklist)
15. [Confidentiality & Intellectual Property](#15-confidentiality--intellectual-property)

---

## 1. Engagement Overview

Project KAVACH is a four-week, GitHub-driven security engagement that fuses **network forensics** with **web application security assessment** and culminates in a single **synthesised defence-in-depth recommendation** for the engineering leadership and board of a fictional non-banking financial company.

The engagement begins by treating the network anomaly and the portal disclosure as **related until proven otherwise** and ends by either substantiating or dismissing that link with evidence. Either outcome is valid; an undecided one is not.

| Attribute | Value |
|---|---|
| Engagement type | Combined network forensics + web application security assessment |
| Duration | Four one-week iterations (three active, one synthesis) |
| Mode | **Solo execution** · async · GitHub-driven |
| Tooling | Free-tier and open-source only · personal laptop |
| Outcome | Reproducible deliverable pack + individual reflection |
| Position | Compounds into the next sprint and the capstone |

> **Foundational principle.** *"Two surfaces" is a hypothesis, not a finding.*

---

## 2. Client Scenario

**Meridian FinServe Pvt. Ltd.** *(fictional)* is a mid-sized Indian non-banking financial company headquartered in Mumbai with operations across nine cities. The firm offers SMB lending, merchant payments, and an embedded credit product. Approximately **720 employees** support **~180,000 borrowers** and **~22,000 merchants**.

The firm operates:

- A **customer-facing portal** — lending applications, EMI servicing, and statements.
- A **partner portal** — merchant onboarding and reconciliation.
- Internal traffic across **branch offices**, **two co-located data centres**, and a **small public-cloud footprint**.

### Triggers for the Engagement

Two events in the same fortnight prompted the board to commission this independent review:

| Trigger | Surface | Description |
|---|---|---|
| **A — Network** | Internal SOC | A 72-hour window of anomalous east-west and outbound traffic from a server segment with historically predictable, low-variance flows. Triaged but not root-caused. Full packet capture preserved. |
| **B — Web** | Customer Portal | Coordinated disclosure from a bug-bounty researcher indicating at least one SQL-injectable endpoint and an IDOR on an account-statements path. PoC details provided; the surface was not exhausted. |

The board's directive is to treat both signals as **related until proven otherwise** under a single, time-boxed assessment.

---

## 3. Objectives & Success Criteria

### Objectives

1. **Reconstruct** what happened on the network during the captured window, with confidence levels assigned to each finding.
2. **Independently verify, expand, and document** the web application weaknesses, then propose code- or configuration-level fixes.
3. **Synthesise** both findings into a defence-in-depth recommendation that an engineering leadership audience can fund and a board can sign off on.
4. **Deliver** everything as artefacts a future internal team could pick up and continue from.

### Success Criteria

> The engagement is successful when an independent reader, given only this repository, can reconstruct *what was found*, *why it is believed*, *how it would be fixed*, and *what trade-offs were considered* — without contacting the author.

- All tooling is free-tier or open-source; everything runs on a personal laptop.
- All findings are reproducible from the artefacts in this repository.
- No real PII appears in any artefact; incidental sensitive strings from public corpora are replaced with synthetic data.

---

## 4. Scope

| In Scope | Out of Scope |
|---|---|
| One captured PCAP representing the 72-hour incident window | Live testing against any production system, real or simulated |
| Vulnerability assessment of the portal — represented by self-hosted DVWA + OWASP Juice Shop | Social engineering, physical, or insider-threat assessment |
| Joint threat model spanning both surfaces | Compliance attestation under RBI, ISO 27001, or PCI DSS |
| Network architecture and application-layer remediation proposals | Source-code access to internal banking-core or payment-rails services |
| One-page executive readout | Anything requiring paid tools, paid APIs, or a cloud bill |

---

## 5. Workstreams

Three workstreams, one synthesis. Workstreams A and B run sequentially in this solo execution to keep cognitive context coherent — A in Iteration 2, B in Iteration 3 — with C synthesising both in Iteration 4.

### A · Network Forensics & Architecture

Pipeline: **Source PCAP → Triage → Hypotheses → IOCs → Architecture diff**

- A.1 Source PCAP selection with documented justification.
- A.2 Triage pass — protocol hierarchy, conversations, top talkers, time bounds.
- A.3 Hypothesis-driven deep dive — at least three competing hypotheses, each with confirm / refute / verdict.
- A.4 Indicator extraction — machine-readable IOC list with confidence ratings.
- A.5 Architecture proposal — before/after diff for the relevant Meridian segment.

> *Clue A.* Baseline first, anomaly second. Triage is not "find the suspicious"; it is "characterise the normal." DNS is loud — C2 channels often hide there.

### B · Web Application Security Assessment

Every finding traverses **Detect → Exploit → Remediate**.

- B.1 Test environment — DVWA and OWASP Juice Shop locally via Docker.
- B.2 Required coverage — at least five OWASP Top 10 (2021) categories. Mandatory: **A01 Broken Access Control**, **A03 Injection** (SQLi + XSS), **A07 Identification & Authentication Failures**.
- B.3 Attack path documentation — request/response evidence, exact payload, root cause, business impact.
- B.4 Remediation & SAST baseline — at least three findings with code-level patches; before/after Semgrep diff.

> *Clue B.* Filters fall to encoding before they fall to cleverness. Authorisation is a layer; authentication is a door — authZ failures sit in per-request access checks, not in the login flow.

### C · Synthesis · Joint Threat Model & Defence in Depth

- C.1 Joint threat model — STRIDE or PASTA, treating Meridian as a single system. At least two cross-surface attack chains.
- C.2 Defence-in-depth proposal — seven layers (Identity, Perimeter, Segmentation, Application, Data, Observability, Response), each citing a specific finding, annotated with effort (S/M/L) and trade-off.
- C.3 Executive readout — one page · three findings, three recommendations, one ask · no jargon a non-technical board member would not already know.

> *Clue C.* Defence in depth is not depth in defence. Seven layers each at 80% strength is more secure than one layer at 99%. The board does not buy controls; it buys outcomes.

---

## 6. Iteration Roadmap

Iterations are scoped by **exit condition**, not by absolute date. Solo execution means a single sustained cadence — no waiting on others, but also no peer pressure to ship. The iteration boundary becomes the primary forcing function.

| # | Theme | Goal | Exit Condition | Status |
|---|---|---|---|---|
| 1 | Frame | Charter, environments, PCAP selected, threat model v0 | Both environments reproducible in <15 min from a clean clone | `CLOSED` |
| 2 | Network | Workstream A through A.4 (IOC list); architecture in draft | Analysis re-runnable from the notebooks alone, arriving at the same indicators | `IN PROGRESS` |
| 3 | Web | Workstream B through B.4; SAST baselines captured | All required vulnerability categories demonstrated with reproducible payloads | `PENDING` |
| 4 | Synthesise | Workstream C complete; pack frozen; executive readout dry-run | Deliverable pack independently reviewable; retrospective held | `PENDING` |

### Current Iteration: Frame

- [x] GitHub repository created with directory scaffolding
- [x] Branch protection on `main`; Project board live with seeded Issues
- [x] DVWA + OWASP Juice Shop reproducible in <15 minutes from a clean clone
- [x] Source PCAP selected and justified (`network/pcap-selection.md`)
- [x] Threat model v0 sketched (`synthesis/threat-model.md`)
- [x] README charter finalised for Iteration 1 exit
- [x] Iteration 1 retrospective written

---

## 7. Repository Structure

```
project-kavach/
├── README.md                          # This file — engagement charter, evolves with the work
├── LICENSE                            # Cohort-licensed; see §15
├── .github/
│   ├── ISSUE_TEMPLATE/                # Finding, task, and blocker templates
│   └── pull_request_template.md       # Self-review checklist (see §12)
├── network/                           # Workstream A
│   ├── pcap-selection.md              # Source justification + SHA-256
│   ├── triage-notes.md                # Wireshark + tshark reproducible commands
│   ├── hypotheses.md                  # ≥3 competing hypotheses with verdicts
│   ├── iocs.csv                       # Machine-readable, confidence-scored
│   ├── zeek/                          # Generated conn.log, dns.log, http.log, ssl.log
│   ├── suricata/                      # ET Open rule hits with corroboration
│   ├── architecture/                  # before.svg + after.svg (diff is the deliverable)
│   └── report.md                      # Workstream A summary
├── webapp/                            # Workstream B
│   ├── env/
│   │   ├── docker-compose.yml         # DVWA + Juice Shop with pinned digests
│   │   └── README.md                  # Bring-up procedure, <15 min target
│   ├── recon/                         # ZAP + Burp baseline scans
│   ├── findings/                      # One folder per finding
│   │   ├── F-01-sqli/
│   │   ├── F-02-xss-stored/
│   │   ├── F-03-idor/
│   │   ├── F-04-auth/
│   │   └── F-05-*/
│   ├── sast/                          # before.json + after.json + diff.md
│   └── report.md                      # Workstream B summary
├── synthesis/                         # Workstream C
│   ├── threat-model.md                # STRIDE/PASTA · crosses both surfaces
│   ├── defense-in-depth.md            # Seven layers, costed
│   └── exec-readout.pdf               # One page · board audience
├── prompts/                           # LLM interaction log (functions as a review partner)
│   └── log.md
├── reflections/                       # Reflection questionnaire response
│   └── reflection.md
└── retro.md                           # Keep · Stop · Start across iterations
```

---

## 8. Quick Start & Reproducibility

The exit condition for Iteration 1 is that *both environments can be brought up from a clean clone in under fifteen minutes*. Because there is no second contributor, the reproducibility check is run by cloning into a fresh directory (or a clean VM) and timing the bring-up against the README — the author plays the role of the future reviewer.

### Prerequisites

- macOS, Linux, or Windows with WSL2
- **Docker Desktop** with ≥4 GB RAM allocated
- **Wireshark** ≥ 4.0 (with `tshark` on `$PATH`)
- **Python 3.11+** (for utilities and notebooks)
- **Git** ≥ 2.40
- ~16 GB system RAM recommended

### Bring up the web test environment

```bash
git clone https://github.com/<user>/project-kavach.git
cd project-kavach/webapp/env
docker compose up -d
```

Verify:

- DVWA → `http://localhost:8080` (then visit `/setup.php` and click *Create / Reset Database*)
- OWASP Juice Shop → `http://localhost:3000`

Tear down:

```bash
docker compose down -v
```

### Fetch the source PCAP

The PCAP itself is not committed to this repository (size and licence). To reproduce network findings:

```bash
cd network
./scripts/fetch-pcap.sh        # downloads and verifies SHA-256
```

The expected SHA-256 and licence terms are documented in `network/pcap-selection.md`.

### Reproduce the analysis

```bash
# Triage pass
tshark -r network/capture.pcap -q -z io,phs > network/triage/protocol-hierarchy.txt
tshark -r network/capture.pcap -q -z conv,ip > network/triage/conversations.txt

# Zeek logs
cd network/zeek && zeek -r ../capture.pcap

# Suricata against ET Open
suricata -r network/capture.pcap -S /etc/suricata/rules/emerging-all.rules -l network/suricata/
```

Detailed walkthroughs live in `network/triage-notes.md` and `network/report.md`.

---

## 9. Methodology & Standards

The engagement is anchored to open, externally referenceable standards:

| Standard | Application |
|---|---|
| **NIST SP 800-61 Rev. 2** | Incident handling lifecycle — frames Workstream A reconstruction |
| **NIST SP 800-115** | Information security testing & assessment — frames Workstream B procedure |
| **NIST CSF 2.0** | Identify · Protect · Detect · Respond · Recover — anchors defence-in-depth proposal |
| **OWASP Top 10 (2021)** | Required coverage list for Workstream B exploitation |
| **OWASP WSTG v4.2** | Procedural backbone for each finding |
| **OWASP ASVS v4.0.3** | Verification checklist driving remediation depth |
| **MITRE ATT&CK** | TTP labelling for network observations and cross-surface chains |
| **STRIDE** (or PASTA) | Threat-modelling formalism for Workstream C |
| **CVSS v3.1** | Severity scoring per finding |

The methodology is **hypothesis-driven throughout**. Every finding carries evidence, reasoning, confidence rating, business impact, and remediation.

---

## 10. Tooling Stack

All tooling is free-tier or open-source.

| Category | Tools |
|---|---|
| Packet analysis | Wireshark · tshark · Zeek · Suricata |
| Web testing | OWASP ZAP · Burp Community · curl |
| Target apps | DVWA · OWASP Juice Shop (Docker) |
| Static analysis | Semgrep CE · Bandit · ESLint security plugins |
| Containers / VMs | Docker Desktop · VirtualBox · Kali Linux ISO |
| Diagramming | Mermaid · draw.io · Excalidraw |
| Version control & PM | GitHub (Repository · Issues · Project board · Actions) |
| LLM augmentation | Free tiers of Claude, ChatGPT, Gemini, Ollama (see §13) |
| Data sources | Malware-Traffic-Analysis.net · Wireshark Sample Captures · NETRESEC · CIC datasets |

---

## 11. Solo Operating Model

The brief is built around team engagement but explicitly anticipates uneven contribution and solo completion: *"the engagement is designed to be completable by a determined subset of the team."* This section documents how the team-based practices in §11–§12 of the brief are adapted for single-contributor execution.

### Contributor

| Role | Name | GitHub Handle |
|---|---|---|
| Sole contributor — all three workstreams | *[name]* | `@handle` |

### Adaptations from the team model

| Team-mode practice | Solo-mode equivalent |
|---|---|
| Peer PR review on every meaningful change | **Self-review after a cooling-off period** (see §12) or LLM-assisted review logged in `prompts/log.md` |
| Multiple reviewers as a "second pair of eyes" | LLM as designated code-review and report-review partner |
| Distributed Issue ownership | All Issues assigned to the sole contributor; acceptance criteria carry the weight of peer accountability |
| Async standups across the team | Daily commit cadence + weekly retro entry in `retro.md` |
| Iteration boundary as group sync | Iteration boundary as a hard forcing function for scope-trim decisions |

### Scope management

With no peers to absorb load, the brief's *"two levers"* for handling disproportionate weight apply continuously rather than only in crunch periods:

- **Re-pull from the Backlog** rather than waiting for clarity — the Project board is the only authority on what comes next.
- **Trim scope at iteration boundaries** by closing low-value Issues with a short note explaining the deferral. Both moves are first-class and pre-authorised by the brief.

The two mandatory anchors that are **never** trimmed:

1. All three mandatory OWASP Top 10 categories in Workstream B (A01, A03, A07).
2. At least two cross-surface chains in the Workstream C joint threat model — without these, the engagement reduces to two unrelated deliverables.

Anything beyond these two anchors is optional and can be trimmed without compromising the engagement's defining premise.

### Cadence

- **Commits on most working days.** Multi-day silence followed by a single mega-commit is a smell — even (especially) for solo work, where commit history is the only externally visible proof of thought.
- **One retrospective entry per iteration** in `retro.md`, written before starting the next iteration. Solo retrospectives are honest with themselves — the audience is the author at the start of the next iteration.

### Public surface

Because the work is solo, the public surface of contribution is unambiguous: every commit, every Issue, every artefact in this repository is attributable to the sole contributor. There is no separate contribution-tracking artefact.

---

## 12. Working Conventions

### Branches & Pull Requests

The PR workflow is preserved in solo mode as a **discipline device**, not as a peer-review gate. PRs force structured self-review, create an audit trail, and mirror industry practice.

- All non-trivial work lands via pull request from a feature branch — direct commits to `main` are reserved for typo fixes and dependency bumps.
- Branch protection on `main` requires linear history but **does not require external approvals** (configured via repository settings to allow the sole contributor to self-approve).
- **Self-merge discipline** — every PR must satisfy at least one of the following before merge:
  1. A **24-hour cooling-off period** between opening the PR and merging it (for substantive code or analysis changes).
  2. An **LLM-assisted review** logged in `prompts/log.md` capturing what was checked and what the model flagged.
  3. A documented exemption for trivial changes (formatting, typos, README polish) with the marker `[trivial]` in the PR title.

### PR Description Template

Every PR description includes:

- **What** — the change in one sentence.
- **Why** — the motivation, citing the Issue number.
- **Self-review notes** — what the author looked for and what they checked.
- **Reviewer prompt** (if LLM-reviewed) — copied verbatim from `prompts/log.md`.

### Commit Messages — Conventional Commits

Pattern: `type(scope): subject`

```
feat(network): add tshark triage notebook
fix(F-03-idor): enforce per-request authZ on /api/statements
docs(synthesis): draft executive readout v2
chore(repo): pin docker image digests
test(network): add IOC CSV schema validation
```

- Subject lines imperative, ≤72 characters.
- Body explains the *why*; the diff explains the *what*.

### Issues

- One acceptance criterion per Issue, written as a falsifiable statement. Solo work places the full weight of accountability on the acceptance line — there is no peer reading it later, so the criterion has to be precise enough that the author cannot self-deceive about whether it's met.
- Labels: `workstream:A|B|C` · `iteration:1..4` · `priority:high|med|low` · `type:finding|task|blocker`.
- Closing without linking to the artefact that closed it is **not done**.

### Confidential Material

- **No real PII**, no real customer data, no captured secrets, no API keys.
- Synthetic substitutes only. The `.gitignore` excludes `*.pcap`, `*.env`, and `credentials.*` by default.
- GitHub secret scanning is enabled.

---

## 13. LLM Usage Policy

In solo execution, LLMs serve a slightly elevated role compared to the team-mode brief — they partially fill the absent-collaborator function for review, sanity-checking, and rubber-duck debugging. They remain a **creative force-multiplier**, not a substitute for reasoning.

> The bar: *would the author have arrived at the same conclusion if the LLM session had never happened?* If the answer is no — because the LLM did the reasoning — the conclusion is suspect.

### Encouraged

- Summarising protocol documentation when triaging unfamiliar protocols.
- Generating candidate SQL or XSS payloads to test (author verifies which work and why).
- Drafting first passes of report sections for the author to rewrite.
- Explaining a packet's bytes when intuition fails.
- Suggesting alternative architectures the author had not considered.
- **Code review on remediation patches before PR self-merge** *(elevated importance in solo mode)*.
- **Sanity-checking the joint threat model for cross-surface chains the author may have missed** *(elevated importance in solo mode)*.
- Translating findings between technical depth and executive concision.

### Discouraged

- Pasting LLM output into a deliverable verbatim, in any section.
- Accepting LLM-claimed CVEs, threat-actor attributions, or statistics without primary-source verification.
- Letting the model invent IOCs, IP addresses, or domain names not in the actual capture.
- Using LLMs to author the threat model or executive readout end-to-end.
- Substituting an LLM summary for reading the OWASP or RFC primary source when stakes are high.
- Using LLMs to generate the reflection questionnaire response (auto-disqualifying).
- Treating model agreement as validation rather than as a prompt to triangulate.

### Prompt Logging

`prompts/log.md` captures at least **eight prompts** across the engagement: the prompt, the tool used, the response, what the author did with it, and where it went wrong if it did. In solo mode, the log additionally tracks all **LLM-assisted PR reviews** referenced in §12, so each "review" can be audited against the changes it covered.

**Failure modes remain the most valuable entries** — the moments where the model was confidently wrong and the author caught it. Those are the entries reviewers read first.

---

## 14. Deliverables Checklist

Closing the engagement requires every item below committed and reviewable in this repository.

### Workstream A — Network

- [ ] `network/pcap-selection.md` — source, SHA-256, licence, justification
- [ ] `network/triage-notes.md` — reproducible Wireshark + tshark commands
- [ ] `network/hypotheses.md` — ≥3 hypotheses, each with confirm / refute / verdict
- [ ] `network/iocs.csv` — machine-readable, confidence-scored, packet ranges
- [ ] `network/architecture/before.svg` + `after.svg`
- [ ] `network/report.md` — workstream summary

### Workstream B — Web

- [ ] `webapp/env/docker-compose.yml` + bring-up README
- [ ] `webapp/findings/F-NN-*/` — ≥5 OWASP categories covered, mandatory three included
- [ ] Each finding includes: evidence, exact payload, root cause, business impact, CVSS v3.1
- [ ] ≥3 findings with code-level remediation patches on `fix/*` branches
- [ ] `webapp/sast/before.json` + `after.json` + `diff.md`
- [ ] `webapp/report.md` — workstream summary

### Workstream C — Synthesis

- [ ] `synthesis/threat-model.md` — STRIDE/PASTA, ≥2 cross-surface chains
- [ ] `synthesis/defense-in-depth.md` — seven layers, each citing a finding, costed
- [ ] `synthesis/exec-readout.pdf` — one page, board audience

### Reflection & Process

- [ ] `prompts/log.md` with ≥8 logged interactions, including all LLM-assisted PR reviews
- [ ] `reflections/reflection.md` responding to all eight questionnaire questions
- [ ] `retro.md` — Iteration 1–4 retrospective entries
- [ ] Repository tagged `v1.0-kavach-frozen` at pack freeze

---

## 15. Confidentiality & Intellectual Property

This repository, its contents, and the engagement brief on which it is based are **proprietary intellectual property of Futurense AI Clinic**, licensed to the cohort for the duration of the engagement and as a personal portfolio reference afterward.

**Meridian FinServe Pvt. Ltd.** is a fictional construct. Any resemblance to a real entity is unintentional.

**Public corpora** referenced in this engagement — Malware-Traffic-Analysis.net, OWASP test applications, Wireshark sample captures, NETRESEC repositories, and CIC datasets — retain their original licences. The author is responsible for honouring those licences in any public artefact produced.

**Redistribution** of the engagement brief, the questionnaire, or the recognition framework outside the cohort, in whole or in part, is not permitted without written authorisation from Futurense AI Clinic.

**Public discussion** of the engagement (LinkedIn posts, blog write-ups) is welcomed *after* engagement close, subject to the constraints in §9 of the brief: no proprietary scenario detail, lessons only.

---

*This README is a living document. Its diff is the change log of the engagement. Last updated: Iteration 1 · Frame.*

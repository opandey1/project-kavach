# Project KAVACH — Retrospective

## Iteration 1 — Frame · friction log

### 1. Docker DNS in VirtualBox NAT

First `docker compose up -d` failed with "failed to resolve reference" —
wording suggested a registry/image problem, but bottom of the stack trace
revealed a DNS timeout on systemd-resolved. VirtualBox NAT's DNS proxy was
unresponsive. Fixed by setting upstream DNS to 8.8.8.8/1.1.1.1 in
/etc/systemd/resolved.conf and restarting systemd-resolved. Lesson: read
Docker errors bottom-up.

### 2. DVWA healthcheck chicken-and-egg

Configured wget --spider against /login.php for the DVWA healthcheck;
container stayed (unhealthy) indefinitely while the app served fine in
browser. Root cause: DVWA requires manual DB init via setup.php on first
run, so any HTTP-based healthcheck fails until a human has clicked "Create
Database". Resolution: dropped the healthcheck with a documenting comment
in docker-compose.yml. Kept the Juice Shop healthcheck, which is
self-contained and worked first time. Lesson: don't add controls whose
preconditions you haven't validated against the real artefact.

### 3. PCAP selection — Latrodectus to Nemotodes pivot

First candidate was the 2024-06-25 Latrodectus + BackConnect + Keyhole VNC
capture, selected initially for its banking-trojan industry fit (IcedID /
Bumblebee lineage). Parallel analysis of the 2024-11-26 Nemotodes capture
surfaced two problems with the Latrodectus choice. First, the east-west
traffic Meridian's SOC trigger specifies is encrypted inside a BackConnect
SOCKS tunnel in the Latrodectus capture — TTP-level lateral movement
exists, but at the network-observation level the SOC would see only
outbound HTTPS, not host-to-host internal flows. Nemotodes, by contrast,
shows direct SMB / SMBv1 traffic from victim to DC with NTLMSSP overflow
attempts, IPC$ enumeration, and MS-EFSR activity — visible east-west the
SOC could point at. Second, the Unit 42 IOC release for 2024-06-25 is
campaign-level (multiple samples, multiple C2 domains) rather than
capture-specific; using it as a proxy for the PCAP's actual contents would
have set up confusion when those domains failed to appear in A.3. Switched
to Nemotodes; documented Latrodectus as a counterfactual in §4 of
pcap-selection.md. Lesson: industry fit is narrative; network observability
is the deciding factor for a SOC-trigger analogue. Sub-lesson: primary
sources have scope (campaign vs sample), and conflating them is a subtle
error that compounds.

### 4. Threat model v0 → v0.1 — self-identified refinements

Wrote initial v0 of the threat model and committed it. On critical re-read
the next day, identified three weaknesses: (a) Chain 3 had the workstation
foothold reaching the DB tier directly, which violates standard enterprise
segmentation and would be flagged by any reviewer familiar with NBFC
network design; (b) the Mermaid architecture diagram had no explicit
egress point, so Trigger A's outbound annotation was attached to the
application server rather than to the perimeter — inaccurate to where the
SOC actually observes egress; (c) the public-cloud footprint was on the
diagram but its trust boundaries were unmapped despite being a real pivot
surface for any web-first compromise. Bumped to v0.1 with three targeted
fixes: added FW_NAT as the perimeter egress anchor, expanded the §2
assumptions table to cover cloud trust boundaries with T1530 / T1552.005
references, and inserted a Domain Credential Abuse bridge in Chain 3
(Kerberoasting / service-account theft / AD CS misconfig). Net change:
177 → 188 lines; v0 scope preserved. Lesson: the brief's "Clue LLM" is
real — a model that agrees with you is mirroring you. A first draft that
follows expected structure is not the same as a first draft that is
accurate. A scheduled second-pass review of own work catches the gaps a
reviewer would otherwise catch in C.1.

## Iteration 1 — Closing decisions · Keep / Stop / Start

### Keep

- **Parallel candidate analysis before committing.** Doing the Nemotodes
  write-up alongside the Latrodectus one is what surfaced the east-west
  visibility gap. Cost was modest; value was the prevented cost of
  walking back the decision in Iteration 2.
- **Primary sources over LLM summaries.** Reading the Unit 42 IOC release
  directly is what made the campaign-vs-sample distinction visible. The
  brief's LLM policy is right that primary-source reading wins when stakes
  are high.
- **Post-hoc acceptance criteria when closing issues.** Backfilling the
  criterion into Issue #1's body and closing comment took five minutes and
  produced an audit trail that reads cleanly. Apply to the remaining 11
  issues as they close.
- **Friction captured in retro.md while it's fresh.** Trying to
  reconstruct the Docker DNS chain a week from now would have lost
  specifics. Daily-ish updates, not end-of-iteration heroics.
- **Self-imposed integrity disciplines, documented.** The "MTA answers
  set aside until after A.3" commitment in pcap-selection.md is the
  artefact that signals analytical honesty. Reviewers reward it.

### Stop

- **Adding controls without testing them against the real artefact.** The
  DVWA healthcheck was speculative — wget-spider against login.php is a
  reasonable guess that turned out to be wrong because of preconditions
  no one would catch from the Dockerfile alone. For Iteration 2: if a
  control depends on something inside the container or capture, validate
  it interactively before committing the config.
- **First-draft acceptance.** The threat model v0 felt finished because
  it had the expected structure. It wasn't. Schedule a second-pass review
  on every artefact before declaring done, with at least a few hours
  between writing and reviewing.
- **Working from broader-scope sources when finer-scope is available.**
  The campaign IOC release for Latrodectus was easy to find; the
  capture-specific scenario blurb was right there on Brad Duncan's index
  page. Default to the narrower source for the specific question being
  asked.

### Start — for Iteration 2 (Network)

- **Time-box the analytical phases.** Indicative budget: A.2 triage pass
  1–2 days, A.3 hypothesis development and testing 2 days, A.4 IOC list
  1 day, A.5 architecture diff 1 day, A-report writing 0.5 day. If a phase
  slips by more than half a day, scope-trim at the boundary rather than
  pushing into the next phase.
- **Strict "no peek" discipline on the MTA answers PDF during A.3.** The
  pcap-selection.md commitment is the contract. The answers come back out
  only after the three hypotheses have a confirm / refute / verdict
  applied independently.
- **Treat the v0.1 chains as hypotheses to falsify, not findings to
  substantiate.** Chain 2 (Network-first) is structurally closest to what
  the Nemotodes capture will show — but the discipline is to confirm or
  refute, not to confirm by default. If A.3 evidence contradicts a chain,
  the chain gets refuted in the threat model, not retrofitted to the
  evidence.
- **Re-read the brief at the iteration boundary.** Clue 01 of the brief:
  *"The second reading is the one that finds the constraint that will
  most shape the engagement."* Do it on Day 0 of Iteration 2, before
  opening Wireshark.
- **For every artefact, ask "did I actually test/verify this?" before
  marking the issue done.** The DVWA healthcheck failure and the threat
  model v0.0 → v0.1 gap both came from declaring done before verifying.
  Add this question to the issue closure checklist explicitly.

## Iteration 1 — Exit status

Closing conditions for Frame iteration per README §6:

- [x] Repository scaffolded and governance configured
- [x] DVWA + OWASP Juice Shop reproducible in <15 minutes from a clean clone
- [x] Source PCAP selected, justified, and fetch script committed (Issue #1 closed)
- [x] Threat model v0 (now v0.1) sketched
- [x] README charter finalised for Iteration 1 exit
- [x] Iteration 1 retrospective written

Iteration 1 closed. Iteration 2 — Network begins.

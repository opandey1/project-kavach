# Workstream A.1 — Source PCAP Selection

## 1. Selected capture

| Field                 | Value                                                                                                            |
| --------------------- | ---------------------------------------------------------------------------------------------------------------- |
| Source                | Malware-Traffic-Analysis.net (Brad Duncan)                                                                       |
| Exercise URL          | https://www.malware-traffic-analysis.net/2024/11/26/index.html                                                   |
| Exercise title        | *Traffic analysis exercise: Nemotodes*                                                                           |
| Capture file          | `2024-11-26-traffic-analysis-exercise.pcap` (extracted from `2024-11-26-traffic-analysis-exercise.pcap.zip`)     |
| Capture date          | 2024-11-26 (Tuesday)                                                                                             |
| File size             | `20.2 MB`                                                                                                        |
| SHA-256               | `a38267943a7bf3b0e445d7e51cb0a68b3dee797d67081bc9a033f73d079c0f50`                                               |
| Zip password          | See the "about" page of malware-traffic-analysis.net (not reproduced here)                                       |
| Alerts bundle         | `2024-11-26-traffic-analysis-exercise-alerts.zip` (297.5 kB) — Suricata-style alerts shipped with the capture    |
| Licence / attribution | Educational use, attribution to Brad Duncan / Malware-Traffic-Analysis.net preserved in all derivative artefacts |

### Environment captured in the PCAP

| Detail | Value |
|---|---|
| LAN segment | `10.11.26.0/24` |
| AD domain | `nemotodes.health` |
| AD environment name | `NEMOTODES` |
| Domain controller | `10.11.26.3` (NEMOTODES-DC) |
| LAN segment gateway | `10.11.26.1` |
| Victim host (per alerts) | `10.11.26.183` (DESKTOP-B8TQK49, user `oboomwald`) |

The medical-research narrative framing on Brad Duncan's exercise page (the "nemotodes research facility") is incidental scenery. For the Meridian engagement it is reframed as *"a branch-office subnet of an Indian mid-sized NBFC, with the victim host being a finance-team workstation."* No technical detail of the capture changes; only the prose narration around it.

## 2. Why this capture is a defensible analogue for Meridian FinServe

Meridian's SOC trigger from §1.2 of the Engagement Brief:

> *"a 72-hour window of anomalous east-west **and** outbound traffic from a server segment that historically generates predictable, low-variance flows."*

The Nemotodes capture satisfies both surfaces of that trigger with directly observable network evidence — not inferred TTP behaviour, but packets the SOC could point at.

**East-west match (the harder requirement to satisfy).**
The victim host `10.11.26.183` initiates significant SMB/SMBv1 traffic against the domain controller `10.11.26.3` on ports `139` and `445`, including:

- Network-share enumeration (IPC$ access alerts)
- A flagged NTLMSSP `unicode asn1 overflow` exploitation attempt
- A flagged `SMB_COM_TRANSACTION Max Data Count of 0` DoS attempt
- Microsoft Encrypting File System Remote Protocol (MS-EFSR) activity

This is exactly the "host-to-host internal flows that should not exist" signature Meridian's SOC reported.

**Outbound match.**
The same victim establishes Command-and-Control communication via HTTP POST requests to `194.180.191.64:443` targeting `/fakeurl.htm`. Notably, the traffic is plain HTTP riding on port 443 — itself an evasion indicator that a low-variance server segment baseline would never exhibit. Suricata flagged this with `ETPRO TROJAN NetSupport RAT CnC Activity` and a cluster of related signatures.

**AD environment realism.**
The capture's active-directory environment (proper domain controller, LDAP queries from member hosts, Kerberos/SMB authentication flows) is structurally close to what an NBFC of Meridian's scale would actually run internally — closer than a flat single-host capture would be.

**SOC artefact set.**
The exercise ships with Suricata-style alerts as well as the PCAP. This mirrors what a real SOC analyst would have at the start of the 72-hour triage window in Meridian's scenario — alert summary first, raw packets second — and makes the hypothesis-driven approach in A.3 more realistic.

**Hypothesis-driven viability.**
The malicious activity is present but not screamingly obvious. Most of the capture is plausibly-normal Windows-AD chatter (DNS, Kerberos, LDAP, Microsoft service telemetry). The anomaly emerges only when characterizing the normal — exactly the discipline Clue A of the brief calls for: *"Baseline first, anomaly second. Triage is not 'find the suspicious'; it is 'characterize the normal'."*

## 3. Activity-category mapping (against §A.1 of the brief)

The brief requires at least one of: command-and-control beaconing, lateral movement, data exfiltration, scanning, or credential abuse. This capture contains three categories with packet-level evidence, plus supporting TTPs across the broader kill chain.

### Required categories present

| Category | Evidence in capture | MITRE technique(s) |
|---|---|---|
| **C2 beaconing (outbound)** | Sustained HTTP POSTs from `10.11.26.183` to `194.180.191.64:443/fakeurl.htm`, flagged as `ETPRO TROJAN NetSupport RAT CnC Activity` and `ET INFO NetSupport Remote Admin Checkin`. Plain HTTP on port 443 is itself anomalous. | T1071.001 Application Layer Protocol — Web Protocols; T1219 Remote Access Software |
| **Lateral movement (attempted)** | SMB traffic from victim to DC on ports 139/445, including `NTMLSSP unicode asn1 overflow attempt` and `SMB_COM_TRANSACTION Max Data Count of 0 DOS Attempt`. The alerts confirm exploitation *attempts*; whether they succeeded is for A.3 to determine. | T1210 Exploitation of Remote Services; T1135 Network Share Discovery (IPC$ enumeration) |
| **Credential abuse (precursor)** | LDAP queries from victim using filters such as `ldap.AttributeDescription == "givenName"` to extract domain user identity information. | T1087.002 Account Discovery — Domain Account |

### Supporting TTPs (broader chain, useful for the Iteration 4 threat model)

| Stage | Evidence | MITRE technique |
|---|---|---|
| Initial Access | Victim browses `classicgrand.com`; injected SmartApeSG script redirects to `modandcrackedapk.com` | T1189 Drive-by Compromise |
| Execution | Fake browser update file `Update.js` downloaded and executed by user | T1204.002 User Execution — Malicious File |
| Discovery | DNS query responses from DC to victim with `Name Error` flags, indicating failed internal-name reconnaissance attempts | T1018 Remote System Discovery / T1016 System Network Configuration Discovery |

### Architecture findings already visible (feeds Workstream A.5)

- **SMBv1 in active use** between victim and DC (alert: `ET INFO Potentially unsafe SMBv1 protocol in use`). A direct "before/after" candidate for the architecture diff — SMBv1 deprecation is a defensible, costable hardening recommendation that maps to a real CVE landscape.
- **TLSv1.0 session observed** (alert: `ET POLICY TLSv1.0 Used in Session`) — another protocol-deprecation finding.
- **Plain HTTP riding on TCP/443** — a posture/egress-filtering finding.

These three observations alone would seed a non-trivial A.5 architecture proposal.

## 4. Candidates considered and rejected

Two other captures were evaluated in parallel. The selection process is documented here to show the comparison made, not to discredit the alternatives.

### `2024-06-25` Latrodectus infection with BackConnect and Keyhole VNC

First candidate considered, on the strength of its banking-trojan industry fit. Latrodectus stems from the IcedID/Bumblebee lineage, which has confirmed financial-sector targeting and would be a strong narrative match for an NBFC engagement.

On closer evaluation: the east-west traffic that Meridian's trigger specifies is encrypted inside a BackConnect SOCKS tunnel terminating at `64.7.198.158:443`. From the SOC's wire-level vantage point the activity appears as a single outbound HTTPS session; host-to-host internal flows are not directly observable in the PCAP. The capture's lateral movement is real at the TTP level but invisible at the network-observation level — which weakens the defensible-analogue claim against Meridian's specific east-west requirement.

Industry fit alone was insufficient to overcome the visibility gap. The selected capture trades a narrower industry framing (commodity NetSupport RAT vs banking-targeted Latrodectus) for clearly-observable east-west evidence — a defensible exchange given the brief's emphasis on what the SOC could actually see during triage.

A secondary concern with the Latrodectus analysis: the Unit 42 IOC release for 2024-06-25 documents *campaign-level* observations across multiple samples, not the specific contents of Brad Duncan's PCAP. Using the campaign IOC list as a proxy for the capture's contents would have set up confusion in A.3.

### `2024-08-15` WarmCookie

Considered as a middle-ground option featuring a modern backdoor with C2 beaconing. WarmCookie is observationally rich on the outbound surface but the publicly-documented activity is comparatively single-surface — strong outbound C2, weaker visible internal pivot. The same "outbound-visible but east-west-inferred" concern that ruled out Latrodectus applied here in attenuated form. Less analytical density across the kill chain than Nemotodes for the same engagement cost.

## 5. Answer-key disclosure

The MTA answers document for 2024-11-26 *was* consulted during candidate evaluation, specifically to verify the activity categories enumerated in §3 and to confirm the east-west visibility claim. This was an intentional, scoped review for **selection** purposes only.

For the duration of Workstream A.3 (Hypothesis-Driven Deep Dive), the answers document will be set aside. The team's hypotheses, IOC list, and report will be developed independently from the raw PCAP and the shipped Suricata alerts. The answers document will be re-opened only at the close of A.3 as a final self-validation check against independently-developed conclusions.

This discipline is self-imposed; no reviewer would catch its absence, which is precisely why it matters. The hypothesis-driven approach the brief calls for has meaning only if the hypotheses are formed without knowing the answer.

## 6. Reproduction

The PCAP itself is **not committed to this repository** — the zipped file is licensed for educational use with attribution preserved, and re-hosting a copy would be a licence violation. A future reviewer reproduces the analysis by fetching the capture from source.

```bash
cd network
./scripts/fetch-pcap.sh
sha256sum capture.pcap   # expect: a38267943a7bf3b0e445d7e51cb0a68b3dee797d67081bc9a033f73d079c0f50
```

The fetch script downloads the password-protected zip from `https://www.malware-traffic-analysis.net/2024/11/26/`, prompts for the password (documented on the MTA "about" page), extracts both the PCAP and the alerts bundle, and verifies the SHA-256 hash against the value recorded in this document.

### Verification checklist for a reproducing reviewer

A reviewer with a clean clone and Wireshark installed should be able to:

1. Run `./scripts/fetch-pcap.sh` and obtain the same PCAP (SHA-256 match confirms this).
2. Open `capture.pcap` in Wireshark and see traffic involving the IP range `10.11.26.0/24`.
3. Filter for `ip.addr == 10.11.26.183 and ip.addr == 10.11.26.3` and see SMB traffic between the victim and the DC.
4. Filter for `ip.addr == 194.180.191.64` and see HTTP POST requests with URI `/fakeurl.htm`.

If any of these checks fail, either the source has changed or the local clone is corrupted — in either case the analysis is not reproducible and the issue must be resolved before proceeding.

---

*Document closes Issue #1 (Source PCAP). Workstream A.2 (Triage Pass) begins against this capture.*

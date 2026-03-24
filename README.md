# Enterprise Cybersecurity Home Lab

**Active Directory · SIEM Monitoring · Network Segmentation · Vulnerability Management · Attack Simulation**

A self-built enterprise-style security lab running 7 virtual machines across 3 segmented network zones. Designed to simulate realistic corporate infrastructure and practice threat detection, incident investigation, attack simulation, and vulnerability management — the full SOC analyst workflow.

---

## Architecture

![Network Architecture](architecture/home-lab-network-architecture.png)

| Component | Detail |
|---|---|
| Host | Dell OptiPlex 7050 (i7, 32GB RAM) — headless, remote-managed |
| Hypervisor | VMware Workstation Pro 17 |
| Firewall | pfSense 2.7.2 — 3-zone segmentation |
| SIEM | Wazuh 4.7.5 — 5 agents, 8 custom rules |
| External Attack Machine | MacBook M1 Pro — Kali Linux UTM VM (ARM64) |
| Total VMs | 7 |

### Network Zones

| Zone | Subnet | VMnet | Purpose |
|---|---|---|---|
| Servers (LAN) | 10.10.10.0/24 | VMnet10 | DC, SIEM, DB |
| Clients (OPT1) | 10.10.20.0/24 | VMnet11 | Windows 11 workstation |
| Attack / DMZ (OPT2) | 10.10.30.0/24 | VMnet19 | Kali Linux + Metasploitable 2 |

### VM Inventory

| Hostname | OS | IP | Role |
|---|---|---|---|
| SRV-FW01 | pfSense 2.7.2 | 10.10.10.1 | Firewall / gateway |
| SRV-DC01 | Windows Server 2022 | 10.10.10.133 | Active Directory / DNS |
| SRV-SIEM01 | Ubuntu 24.04 | 10.10.10.135 | Wazuh SIEM manager |
| SRV-DB01 | Ubuntu / MySQL | 10.10.10.128 | MySQL + Apache + phpMyAdmin |
| CLI-WIN11-01 | Windows 11 | 10.10.20.134 | Domain-joined workstation |
| ATT-KALI01 | Kali Linux 2024.4 | 10.10.30.130 | Attack VM + Nessus scanner |
| DMZ-VULN01 | Metasploitable 2 | 10.10.30.101 | Intentionally vulnerable target |

---

## Technologies Used

**Virtualization**
- VMware Workstation Pro 17 — 7-VM enterprise lab, headless operation via SSH + RDP

**Security Monitoring**
- Wazuh 4.7.5 — SIEM, 5 agents, 8 custom detection rules, 12+ MITRE ATT&CK techniques mapped

**Infrastructure**
- Windows Server 2022 — Active Directory Domain Services, DNS, Group Policy
- Ubuntu Server 24.04 — Wazuh manager, MySQL, Apache
- Windows 11 Pro — domain-joined workstation

**Networking**
- pfSense CE 2.7.2 — stateful firewall, 3-zone segmentation, inter-VLAN access control
- VMware virtual networking — VMnet10/11/19 host-only adapters, netsh portproxy port forwarding

**Attack & Vulnerability Tools**
- Kali Linux — Metasploit 6.4, Nmap, Hydra, NetExec, Netcat
- Nessus Essentials 10.11.2 — vulnerability scanning and remediation verification
- MacBook M1 Pro (UTM/ARM64 Kali) — external attack machine via Dell port forward

---

## Security Monitoring

Wazuh collects and correlates logs across all 5 agents. The MacBook agent reports via Windows port proxy on the Dell host (ports 1514/1515 → 10.10.10.135).

**Monitored log sources:**
- Windows Security Event Log (4624, 4625, 4720, 4728, 4688, 4698)
- Active Directory authentication and account changes
- PowerShell script execution and encoded command logging
- Linux auth logs and system activity
- Backup file access and modification events

**Custom Wazuh Rules (local_rules.xml):**

| Rule ID | MITRE | Detection |
|---|---|---|
| 100001 | T1110 | Brute force — 5+ failed logons in 2 minutes |
| 100002 | T1110 | Brute force success (failures followed by success) |
| 100003 | T1136 | New Windows user account created |
| 100004 | T1136 | Account added to Administrators group |
| 100005 | T1027 | PowerShell encoded command executed |
| 100006 | T1059.001 | PowerShell script file executed |
| 100007 | T1490 | Backup file accessed or modified |
| 100008 | T1053.005 | Scheduled task created |

---

## Active Directory & RBAC

A tiered admin model is enforced via Group Policy — no account can log into a tier it doesn't own.

| Tier | Account | Access Scope |
|---|---|---|
| Tier 0 | tier0admin | Domain Controllers only |
| Tier 1 | tier1admin | Servers only (denied DC + workstation logon) |
| Tier 2 | tier2support | Workstations only (denied DC logon) |
| Role | hr.user01 | HR_Department OU |
| Role | finance.user01 | Standard_Users OU |

**Hardened GPOs:** password complexity, account lockout (5 attempts / 15 min), advanced audit logging, PowerShell script block logging, AppLocker-style restrictions per tier.

---

## Firewall Rules

pfSense enforces strict inter-zone policy. All rules verified live with cross-zone attack traffic.

| Interface | Source | Destination | Action | Purpose |
|---|---|---|---|---|
| OPT2 | Attack zone | 10.10.30.101 only | PASS | Attack traffic to DMZ target only |
| OPT2 | Attack zone | 10.10.10.0/24 | BLOCK | Prevent lateral movement to servers |
| OPT2 | Attack zone | 10.10.20.0/24 | BLOCK | Prevent lateral movement to clients |
| OPT1 | Client zone | 10.10.10.0/24 (AD ports) | PASS | Domain authentication |
| OPT1 | Client zone | 10.10.30.0/24 | BLOCK | Isolate clients from attack zone |
| LAN | Servers | 10.10.30.0/24 | BLOCK | Isolate servers from attack zone |
| WAN | Any | Any | BLOCK | Default deny inbound |

---

## Attack Simulations

All attacks executed from ATT-KALI01 (internal) and MacBook Kali (external via port forward). All detections verified in Wazuh dashboard.

**Techniques simulated:**

| Technique | Tool | Detection |
|---|---|---|
| T1110 — Brute force (SSH/RDP) | Hydra | Rule 100001/100002 |
| T1021 — Lateral movement (SMB) | NetExec | Rule 92657 |
| T1550.002 — Pass-the-Hash | NetExec | Rule 92657 — best alert |
| T1059.001 — PowerShell execution | Manual | Rule 100005/100006 |
| T1136 — Account creation | PowerShell | Rule 100003/100004 |
| T1053.005 — Scheduled task | schtasks | Rule 100008 |
| T1190 — Exploit public-facing app | Metasploit | Console output |

**Metasploitable 2 exploits confirmed:**
- Port 1524 bind shell → root (no authentication)
- vsftpd 2.3.4 backdoor (CVE-2011-2523) → root
- UnrealIRCd backdoor (CVE-2010-2075) → shell

---

## Vulnerability Management

Full lifecycle executed using Nessus Essentials on an isolated attack VM.

| Phase | Detail |
|---|---|
| Scanner | Nessus Essentials 10.11.2 on ATT-KALI01 |
| Target | DMZ-VULN01 (Metasploitable 2) |
| Initial scan | 178 findings — 8 Critical, 6 High, 23 Medium |
| Remediated | VNC default password (CVSS 10.0), bind shell backdoor (CVSS 9.8), unencrypted Telnet (CVSS 6.5) |
| Rescan | 174 findings — all 3 remediated findings confirmed closed |
| Report | VMR-2026-001 — full vulnerability management report documented |

---

## Headless & Remote Operation

The Dell host runs fully headless — no monitor required after initial setup.

- **SSH access:** `ssh sshuser@192.168.0.150` from Lenovo laptop or any LAN device
- **RDP access:** Lenovo → Dell → RDP into individual VMs
- **Auto-start:** registry auto-login + shell:startup batch file starts FW01 → DC01 → SIEM01 in sequence on every boot
- **Port forwards (netsh portproxy):**
  - `0.0.0.0:1514 → 10.10.10.135:1514` — Wazuh agent traffic from MacBook
  - `0.0.0.0:1515 → 10.10.10.135:1515` — Wazuh enrollment from MacBook
  - `0.0.0.0:8080 → 10.10.30.101:80` — Metasploitable HTTP from MacBook Kali

---

## PowerShell Automation

Four automation scripts running on SRV-DC01, outputting timestamped CSV reports to `C:\Lab-Scripts\`.

| Script | Purpose |
|---|---|
| AD-HealthCheck.ps1 | AD services, replication status, SYSVOL/NETLOGON share availability |
| Security-Audit.ps1 | Locked accounts, Domain Admin membership, disabled users |
| WazuhAgent-Check.ps1 | Wazuh agent service status across all domain machines |
| Backup-Status.ps1 | Backup file existence, age, and wbadmin last run time |

---

## MITRE ATT&CK Coverage

12+ techniques mapped across detection and simulation phases.

`T1110` `T1021` `T1550.002` `T1059.001` `T1027` `T1136` `T1053.005` `T1490` `T1190` `T1078` `T1098` `T1562`

---

## Project Status

| Phase | Description | Status |
|---|---|---|
| Phase 9 | Network segmentation — 7 VMs, 3 zones | ✅ Complete |
| Phase 10 | Firewall hardening — all 3 zones, live verified | ✅ Complete |
| Phase 11 | RBAC tiered admin model + GPO enforcement | ✅ Complete |
| Phase 12 | Professional documentation examples | ✅ Complete |
| Phase 13 | Vulnerability management — Nessus lifecycle | ✅ Complete |
| Phase 14 | Headless operation, PowerShell automation, custom Wazuh rules, backup simulation | ✅ Complete |
| Phase 16 | DMZ network rebuild, MacBook Kali external attack path | ✅ Complete |
| Phase 17 | Attack exercises from MacBook Kali against DMZ-VULN01 | 🔄 In Progress |
| Phase 15 | Physical VLANs — TP-Link TL-SG108E | ⏳ Planned |

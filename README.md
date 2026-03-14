# Enterprise SOC Analyst Home Lab

This project simulates an enterprise-style security environment designed to practice **threat detection, incident investigation, and attack simulation** using a SIEM and segmented network architecture.

The lab replicates common infrastructure found in corporate networks and is used to generate realistic security events for analysis.

---

# Lab Architecture

![SOC Lab Architecture](architecture/soc-home-lab-architecture.png)

---

# Technologies Used

**Virtualization**

* Proxmox VE

**Security Monitoring**

* Wazuh SIEM
* Wazuh Agents

**Infrastructure**

* Active Directory
* Windows Server 2022 (Domain Controller)
* Windows 10 Workstation

**Networking**

* pfSense Firewall
* Network segmentation
* VLANs

**Attacker Environment**

* Kali Linux

---

# Lab Environment

### Domain Controller

Hostname: SRV-DC01
Role: Active Directory / DNS
OS: Windows Server 2022
Monitoring: Wazuh Agent

### Workstation

Hostname: WS01
Role: User workstation
OS: Windows 10
Monitoring: Wazuh Agent

### Firewall

Device: pfSense
Role: Network segmentation and traffic control

---

# Security Monitoring

Wazuh SIEM is used to collect and analyze logs from the lab environment.

Monitored logs include:

* Windows Security Events
* Authentication logs
* Firewall logs
* System activity
* Network events

Alerts are generated when suspicious activity occurs.

---

# Attack Simulations

This lab is used to simulate common cyber attacks in order to practice detection and analysis.

Examples include:

* RDP brute force attacks
* Privilege escalation
* Lateral movement
* Malware execution
* Suspicious PowerShell activity

Each scenario is mapped to the **MITRE ATT&CK framework**.

---

# Detection Engineering

Custom detection rules are created in Wazuh to identify suspicious activity such as:

* Excessive failed logins
* Unauthorized privilege escalation
* Suspicious PowerShell commands
* Credential dumping behavior

---

# MITRE ATT&CK Techniques Simulated

Examples of mapped techniques:

T1110 – Brute Force
T1059 – Command and Scripting Interpreter
T1021 – Remote Services
T1068 – Privilege Escalation

---

# Screenshots

Example alerts generated during attack simulations:

* Wazuh SIEM alerts
* Windows Event Logs
* Firewall logs
* Attack command output

---

# Purpose of This Lab

This lab was built to develop hands-on experience with:

* Security monitoring
* SIEM configuration
* Attack detection
* Incident investigation
* Detection engineering

---

# Future Improvements

Planned improvements include:

* Additional attack simulations
* Custom Wazuh detection rules
* Expanded MITRE ATT&CK mapping
* Threat hunting scenarios



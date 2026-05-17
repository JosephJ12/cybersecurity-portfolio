# CTF Walkthroughs — Windows & Active Directory Penetration Testing

This folder contains hands-on Hack The Box walkthroughs focused on Windows, Active Directory, credential attacks, privilege escalation, and enterprise-style attack path development.

The goal is not to show that I can complete boxes. The goal is to show that I can approach an unfamiliar environment like a junior penetration tester: enumerate carefully, validate access, chain weaknesses into meaningful impact, document the path clearly, and explain how the issue should be fixed.

> **Ethical use note:** All work in this section was performed in authorized lab environments. These notes are intended for professional development, defensive learning, and portfolio review.

---

## Best Walkthroughs to Review First

| Walkthrough | Environment | Primary Attack Path | Why It Matters for a Junior Pentester Role |
|---|---|---|---|
| [HTB - Blackfield](./HTB%20-%20Blackfield.md) | Windows / Active Directory | Anonymous SMB user discovery → AS-REP roasting → BloodHound pathing → LSASS dump analysis → SeBackupPrivilege → offline NTDS extraction | Shows full internal pentest thinking: user discovery, credential attacks, privilege path analysis, credential extraction, and domain impact. |
| [HTB - Authority](./HTB%20-%20Authority.md) | Windows / Active Directory / AD CS | SMB config exposure → Ansible Vault cracking → application credential recovery → LDAP credential capture → AD CS ESC1 abuse | Shows enterprise attack chaining across file shares, automation secrets, web admin panels, LDAP, and certificate services. |
| [HTB - Certified](./HTB%20-%20Certified.md) | Windows / Active Directory / AD CS | BloodHound ACL analysis → ownership takeover → Shadow Credentials → PKINIT → AD CS ESC9 abuse | Shows modern AD exploitation through permissions, certificate-based authentication, and controlled privilege escalation. |

---

## What This Section Demonstrates

These walkthroughs are written to highlight job-relevant penetration testing skills, not just tool usage.

### Enumeration and Attack Surface Mapping

- Windows service enumeration with Nmap, NetExec, SMB tooling, LDAP queries, and web enumeration
- Domain identification through Kerberos, LDAP, SMB, DNS, and certificate services
- Initial access triage across exposed shares, credentials, admin panels, SQL services, and roastable accounts

### Active Directory Attack Path Analysis

- BloodHound-based relationship analysis
- Validation of dangerous rights such as `GenericAll`, `GenericWrite`, `WriteOwner`, `WriteDACL`, and `ForceChangePassword`
- Manual confirmation of attack paths before attempting escalation
- Clear distinction between theoretical permissions and practical exploitability

### Credential Attack Workflows

- AS-REP roasting and Kerberoasting
- Offline hash cracking with Hashcat and John-compatible formats
- NetNTLM capture and validation
- Password reuse testing without unnecessary noise
- Pass-the-hash only after confirming valid NTLM material

### Privilege Escalation and Post-Exploitation

- Shadow Credential attacks
- AD CS abuse including ESC1 and ESC9-style misconfigurations
- LSASS dump analysis in lab environments
- `SeBackupPrivilege` abuse for offline domain database extraction
- DCSync and NTDS impact analysis

### Reporting Mindset

Each walkthrough ends with remediation guidance because exploitation alone is not enough. A real penetration tester needs to explain why the issue matters, how it was proven, what the impact is, and what the client should fix first.

---

## Methodology Used Across Walkthroughs

### 1. Identify the Environment

I start by mapping exposed services and determining the likely role of the host.

Common questions I answer early:

- Is this a standalone Windows host or part of a domain?
- Are SMB, LDAP, Kerberos, WinRM, MSSQL, or AD CS exposed?
- Is anonymous access possible?
- Are usernames, shares, or configuration files exposed?
- Are there certificate services, web admin panels, or other enterprise services worth prioritizing?

### 2. Develop Initial Access Carefully

I avoid jumping straight to exploits. I look for the most realistic path first:

- Anonymous SMB access
- Exposed usernames
- Misconfigured shares
- Stored credentials in configuration files
- Roastable accounts
- Captured authentication material
- Weak or reused service account credentials
- Misconfigured administrative web interfaces

### 3. Enumerate With Credentials

After obtaining credentials, I validate them and expand visibility:

- Confirm which protocols accept the credentials
- Enumerate domain users, groups, computers, shares, and local admin rights
- Collect BloodHound data when appropriate
- Identify privilege relationships that can create a path to higher access
- Validate each step before moving to the next one

### 4. Chain Weaknesses Into Impact

Most of these labs are not solved by one vulnerability. They require chaining:

```text
Small Exposure → Valid Credential → Better Visibility → Misconfigured Permission → Privilege Escalation → Domain Impact
```

That pattern is directly relevant to real internal penetration tests. The highest-risk findings often come from several medium-risk weaknesses interacting badly.

### 5. Document Remediation

The remediation sections focus on controls a defender or administrator could actually apply:

- Remove anonymous access to sensitive shares
- Harden service account permissions
- Audit delegated AD rights
- Protect LSASS and restrict credential material
- Review certificate templates and enrollment rights
- Disable unnecessary remote management exposure
- Monitor for suspicious certificate requests, password resets, DCSync behavior, and NTDS access

---

## Tools Used

| Category | Tools |
|---|---|
| Network and service enumeration | Nmap, NetExec / CrackMapExec, smbclient, ldapsearch |
| Active Directory analysis | BloodHound, bloodhound-python, Impacket, bloodyAD |
| Credential attacks | Hashcat, John utilities, GetNPUsers.py, GetUserSPNs.py |
| Remote access and validation | Evil-WinRM, Impacket psexec/wmiexec/secretsdump where appropriate |
| AD CS testing | Certipy, PKINITtools |
| Windows credential analysis | pypykatz, registry hive and NTDS extraction techniques in lab environments |
| Web and application enumeration | ffuf, Burp Suite, EyeWitness where applicable |

---

## Recruiter Takeaway

This section is strongest for junior penetration tester roles focused on internal networks, Windows environments, and Active Directory. The clearest signal is the ability to explain attack paths, not just run commands. These walkthroughs show practical enumeration, credential validation, privilege escalation, and remediation thinking in a format that a technical interviewer can evaluate quickly.

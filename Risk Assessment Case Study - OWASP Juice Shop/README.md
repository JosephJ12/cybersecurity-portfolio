# 🔐 OWASP Juice Shop – Application Security Project

## 📌 Overview

This project simulates the role of an **Application Security Engineer** securing a vulnerable production web application using OWASP Juice Shop.

Going beyond traditional security labs focused only on vulnerability discovery, this project demonstrates:

- Code-level vulnerability remediation
- Real-world security control implementation
- DevSecOps pipeline integration
- Risk-based prioritization
- System-level security thinking

---

## 🎯 Objectives

- Identify and exploit real-world web vulnerabilities
- Implement secure code fixes directly in the application
- Introduce preventative security controls
- Shift security left into CI/CD pipelines
- Demonstrate threat modeling and risk assessment

---

## 🧠 Security Methodology

```text
1. Threat Modeling
  - System Architecture
  - Data Flow Diagram
  - Trust Boundaries
  - STRIDE Application and Gap Analysis
2. Vulnerability Discovery (DAST)
  - Risk Verification and Exploitation
  - Code-Level Remediation
  - Preventative Control Verification
3. Secure Coding Practices via Semgrep
  - SAST Integration and Automation
  - SCA (Software Component Analysis) Implementation
  - DevSecOps CI/CD Pipeline
```

## 🌟 Project Highlights

### 1️⃣ Threat Modeling — STRIDE Application and Gap Analysis

| Risk ID | Risk | STRIDE | Expected Control | Status | Gap | Impact | Recommended Remediation |
|---|---|---|---|---|---|---|---|
| AUTH-01 | Brute force login | Spoofing | Brute force login protection | Not evident | Rate limiting on login attempts does not seem to be present within the scope. | Increases the likelihood of user impersonation, which may lead to complete account compromise and sensitive information disclosure. | Lockout policy on failed login attempts and enforcing strong password policy upon account creation. | 
| AUTH-02 | JWT Token forgery | Tampering | Token signing | Present within scope | Auth tokens should be signed to prevent tampering or impersonation. | Absence of token signing may allow attackers to craft or modify their own token to elevate privileges or impersonate another user. | Implement token signing and validation. |
| AUTH-03 | No login audit logs | Repudiation | Logging login activity | Not evident | Auditing login attempts does not seem evident within the scope. | Increases likelihood of repudiation without audit logs. | Securely store logs on web server log files. | 
| AUTH-04 | Verbose login error responses | Information Disclosure | Generic error messages upon failed login | Requires validation | Generic error messages should be given for all failed login cases to prevent attackers from enumerating valid users from them. | Increases the likelihood of user enumeration, which may be later used for further attacks. | Implement generic error messages for all login errors. | 
| AUTH-05 | SQL Injection | Escalation of Privileges | Backend uses parameterized queries to query database | Not evident | the `login()` function does not utilize parameterized queries | SQL Injection may lead to the disclosure of sensitive information or in severe cases, bypassing authentication or remote code execution. | Parameterized queries should be implemented when querying the database. Also doing input santization on user input is highly recommended. |

### 2️⃣ Vulnerability Discovery (DAST) — Code-Level Remediation

SQL Injection Vulnerable Code:
<img width="1806" height="274" alt="image" src="https://github.com/user-attachments/assets/f5a02e08-96ce-430d-b08a-a95b4b0a1f8b" />

SQLI-Free Parameterized Query Code:
<img width="1323" height="537" alt="image" src="https://github.com/user-attachments/assets/b305c08e-6462-496b-b144-28217df8e7b6" />

------

Login Endpoint Without Rate Limiting:


Login Endpoint With IP and IP+Account Rate Limiting:



### 3️⃣ Secure Coding Practices — SAST Integration and Automation

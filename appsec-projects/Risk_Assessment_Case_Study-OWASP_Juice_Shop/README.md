# 🔐 OWASP Juice Shop — Application Security Case Study

## 📌 Overview

This project is a **risk-based Application Security (AppSec) assessment and remediation** of the vulnerable web application **OWASP Juice Shop**.

The goal was to simulate how a junior Application Security Engineer would evaluate a real-world application:
- Understand system architecture
- Identify and exploit vulnerabilities
- Determine root causes
- Implement secure, production-aligned fixes
- Integrate security into the development lifecycle (DevSecOps)

---

## 🎯 Objectives

- Perform **end-to-end AppSec assessment**
- Apply **threat modeling (STRIDE, DFDs, trust boundaries)**
- Identify vulnerabilities aligned with **OWASP Top 10**
- Implement **secure coding fixes**
- Integrate **security into CI/CD pipelines**

---

## 🏗️ Application Architecture & Scope

The application follows a typical modern web architecture:

- **Frontend:** Angular (client-side)
- **Backend:** Node.js / Express API
- **Database:** SQLite
- **Authentication:** Session-based login

### Scope of Assessment

Focus areas:
- Authentication and login flows
- Input handling and database interactions
- API endpoints and business logic

---

## 🧠 Methodology

### 1. Architecture Review
- Created **Data Flow Diagrams (DFD)**
- Identified **trust boundaries**
- Mapped data movement between components

### 2. Threat Modeling
Applied **STRIDE** to key components:
- Authentication
- Search functionality
- User input handling

### 3. Security Testing
- Dynamic testing using **Burp Suite**
- Manual exploitation of vulnerabilities
- Request/response manipulation

### 4. Remediation
- Implemented secure coding fixes
- Addressed root causes (not just symptoms)

### 5. DevSecOps Integration
- Integrated **Semgrep (SAST)** into CI/CD using GitHub Actions
- Automated detection of insecure patterns
- Code-level remediation and rescan

---

## 🚨 Key Findings

### 1. SQL Injection (High)

**Vulnerability:**  
User-controlled input was directly concatenated into SQL queries.

**Impact:**  
- Authentication bypass  
- Unauthorized data access  

**Root Cause:**  
Lack of parameterized queries / input sanitization

**Remediation:**  
- Replaced SQL queries with **parameterized queries**

---

### 2. Brute Force Authentication (High)

**Vulnerability:**  
Login endpoint allowed unlimited attempts.

**Impact:**  
- Account takeover risk  
- Credential stuffing attacks  

**Root Cause:**  
No rate limiting or account lockout mechanism

**Remediation:**  
- Implemented **combined rate limiting**:
  - Per-IP throttling
  - Per-account throttling
- Configured time-based reset logic

---

## 🔧 Remediation Highlights

### ✅ Secure Coding Improvements
- Parameterized database queries

### ✅ Authentication Hardening
- Account + IP-based rate limiting
- Protection against brute force and credential stuffing

### ✅ Security Controls
- Reduced attack surface
- Improved resilience against common web attacks

---

## ⚙️ DevSecOps Integration

Security was integrated into the development lifecycle:

- **SAST Tool:** Semgrep
- **CI/CD:** GitHub Actions

### Pipeline Capabilities:
- Automated static code analysis on pull requests
- Detection of insecure patterns
- Early vulnerability identification

---

## 📊 Risk-Based Approach

Findings were prioritized based on:
- Exploitability
- Business impact
- Likelihood of abuse

Focus was placed on **high-impact vulnerabilities affecting authentication and data integrity**.

---


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

Login Endpoint Susceptible to Brute Force Attacks:


Login Endpoint With IP and IP+Account Rate Limiting:



### 3️⃣ Secure Coding Practices — SAST Integration and Automation

**Semgrep.yml File**
```
name: Semgrep CI

on:
  pull_request:
    paths:
      - 'Risk_Assessment_Case_Study-OWASP_Juice_Shop/juice-shop/**'
      - '.github/workflows/semgrep.yml'
  push:
    branches:
      - main
      - master
    paths:
      - 'Risk_Assessment_Case_Study-OWASP_Juice_Shop/juice-shop/**'
      - '.github/workflows/semgrep.yml'
  workflow_dispatch: {}

permissions:
  contents: read

jobs:
  semgrep:
    name: semgrep
    runs-on: ubuntu-latest

    container:
      image: semgrep/semgrep:latest

    defaults:
      run:
        working-directory: 'Risk_Assessment_Case_Study-OWASP_Juice_Shop/juice-shop'

    steps:
      - name: Check out repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Run Semgrep CI
        run: semgrep ci
        env:
          SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_APP_TOKEN }}
```

**.Semgrepignore File**

```
# We will configure Semgrep to only scan 2 files:
# juice-shop/routes/search.ts and juice-shop/package.json
# Therefore, we will ignore every file and reintroduce just those 2 to scan

# Ignore everything
*

# Re-allow required directory and file
!routes
!routes/search.ts

# Allow dependency file
!package.json
```

---

## 🧠 Key Learnings

- Security must be embedded **early in the SDLC**
- Many vulnerabilities stem from **design and logic flaws**, not just code issues
- Effective remediation requires understanding **root cause and system behavior**
- Automation (DevSecOps) is essential for **scaling security practices**

---
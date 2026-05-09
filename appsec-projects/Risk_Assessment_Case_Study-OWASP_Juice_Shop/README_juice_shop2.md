# OWASP Juice Shop AppSec Assessment & Remediation

**Risk-based application security assessment of OWASP Juice Shop covering threat modeling, manual exploitation, secure code remediation, and CI/CD SAST automation.**

## Executive Summary

This project simulates the workflow of an Application Security Engineer assessing a production-like web application. I analyzed the system architecture, modeled threats, manually validated vulnerabilities, implemented code-level remediations, and added automated security scanning to CI/CD.

The strongest security outcomes in this project were:

- Identified and remediated SQL injection in backend query handling.
- Identified brute-force risk in the login flow and implemented account/IP-aware rate limiting.
- Built a Semgrep-based SAST workflow to detect insecure code patterns earlier in the SDLC.
- Documented findings using a risk-based format: root cause, impact, exploitability, and remediation.

## Security Skills Demonstrated

| Area | Evidence |
|---|---|
| Threat Modeling | DFDs, trust boundaries, STRIDE analysis |
| Manual AppSec Testing | Burp Suite, request/response manipulation, authentication testing |
| Secure Code Review | Reviewed vulnerable backend logic and mapped weaknesses to root causes |
| Remediation | Parameterized queries, rate limiting, validation improvements |
| DevSecOps | GitHub Actions + Semgrep CI pipeline |
| Risk Communication | Findings written with impact, likelihood, remediation, and business risk |

## Application Scope

OWASP Juice Shop is a deliberately vulnerable web application with a modern web architecture:

```text
User Browser
    ↓
Angular Frontend
    ↓
Node.js / Express API
    ↓
SQLite Database
```

Assessment focus:

- Login and authentication flows
- Search/input handling
- Backend API routes
- Database query construction
- Security automation in CI/CD

## Methodology

### 1. Architecture Review

I started by understanding the request flow, trust boundaries, and major data stores before testing individual bugs. This matters because real AppSec work is not just running tools; it is understanding where user input crosses trust boundaries and where sensitive operations occur.

### 2. Threat Modeling

I applied STRIDE against authentication, API endpoints, and database interactions.

| Risk ID | Area | STRIDE | Risk | Expected Control |
|---|---|---|---|---|
| AUTH-01 | Login | Spoofing | Brute-force login attempts | Account/IP-based throttling |
| AUTH-02 | Session/Auth | Tampering | Token/session manipulation | Signed and validated tokens/session controls |
| AUTH-03 | Login | Repudiation | Weak auditability of login attempts | Security logging |
| AUTH-04 | Login | Information Disclosure | Verbose login responses | Generic authentication errors |
| AUTH-05 | Search/Login Query | Elevation of Privilege | SQL injection | Parameterized queries |

### 3. Manual Vulnerability Validation

I used Burp Suite and manual testing to validate exploitability instead of relying only on scanner output.

Testing included:

- Intercepting requests
- Modifying parameters
- Testing authentication bypass behavior
- Validating whether input reached unsafe backend query logic
- Confirming whether remediation changed application behavior

## Key Findings & Remediations

### Finding 1: SQL Injection in Backend Query Handling

**Severity:** High  
**Category:** OWASP Top 10 — Injection  
**Root cause:** User-controlled input was concatenated into backend SQL queries instead of being passed through parameterized statements.

#### Security Impact

An attacker could potentially manipulate SQL query logic to bypass authentication or access unauthorized data.

#### Remediation

Replaced unsafe query construction with parameterized database access.

```ts
// Vulnerable pattern
const query = `SELECT * FROM users WHERE email = '${email}'`;
```

```ts
// Safer pattern
const query = 'SELECT * FROM users WHERE email = ?';
db.get(query, [email]);
```

#### Why This Works

Parameterized queries separate executable SQL structure from user-controlled data. The database treats the input as a value, not as query syntax.

---

### Finding 2: Brute Force Risk on Login Endpoint

**Severity:** High  
**Category:** Broken Authentication  
**Root cause:** The login endpoint did not enforce meaningful throttling across repeated failed attempts.

#### Security Impact

An attacker could automate credential guessing, credential stuffing, or password spraying against valid accounts.

#### Remediation

Implemented layered rate limiting:

- Per-IP throttling
- Per-account throttling
- Time-window reset behavior
- Generic error messaging to reduce enumeration risk

```ts
const key = `${req.ip}:${email}`;
const attempts = loginAttempts.get(key) || 0;

if (attempts >= MAX_ATTEMPTS) {
  return res.status(429).json({ error: 'Too many login attempts' });
}
```

#### Why This Works

Per-IP throttling slows broad abuse. Per-account throttling protects targeted users even if the attacker rotates IP addresses.

---

### Finding 3: Missing Early Detection in CI/CD

**Severity:** Medium  
**Category:** SDLC / DevSecOps Gap  
**Root cause:** Vulnerable patterns could be reintroduced without automated checks.

#### Remediation

Added Semgrep scanning to GitHub Actions.

```yaml
name: Semgrep CI
on:
  pull_request:
  push:
    branches: [main]

jobs:
  semgrep:
    runs-on: ubuntu-latest
    container:
      image: semgrep/semgrep:latest
    steps:
      - uses: actions/checkout@v4
      - run: semgrep ci
```

#### Why This Works

SAST does not replace manual testing, but it catches known insecure patterns earlier and prevents regression after remediation.

## How to Review This Project

1. Start with the threat model to understand system risk.
2. Review the findings to see exploitability and business impact.
3. Review the remediation notes to see how code-level fixes map to root causes.
4. Review the CI/CD workflow to see how security checks are automated.

## What This Project Proves

This project shows that I can move beyond vulnerability identification into AppSec engineering work: understanding architecture, validating exploitability, fixing root causes, and adding automation to prevent regressions.

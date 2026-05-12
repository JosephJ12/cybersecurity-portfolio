<img width="1672" height="941" alt="ChatGPT Image May 11, 2026, 04_06_55 PM" src="https://github.com/user-attachments/assets/2bbd54bf-c5a8-4e0a-8be4-5f5db01601c9" />

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
// SQLI VULNERABLE CODE PATTERN
models.sequelize.query(
  `
  SELECT * 
  FROM Users 
  WHERE email = '${req.body.email || ''}' 
  AND password = '${security.hash(req.body.password || '')}' 
  AND deletedAt IS NULL`, 
  { 
    model: UserModel, 
    plain: true 
  }
)
```

```ts
// SAFER PATTERN USING PARAMETERIZED QUERY
const email = req.body.email || '';
const passwordHash = security.hash(req.body.password || '');

models.sequelize.query(
  `
  SELECT * 
  FROM Users 
  WHERE email = $email 
  AND password = $password 
  AND deletedAt IS NULL
  `,
  {
    bind: {
        email: email,
        password: passwordHash,
    },
    model: UserModel,
    plain: true,
  }
)
```

#### Why This Works

Parameterized queries separate executable SQL structure from user-controlled data. The database treats the input as a value, not as query syntax.

---

### Finding 2: Brute Force Risk on Login Endpoint

**Severity:** High  
**Category:** Broken Authentication  
**Root cause:** The login endpoint did not enforce meaningful rate limiting and lockout across repeated failed attempts.

#### Security Impact

An attacker could automate credential guessing, credential stuffing, or password spraying against valid accounts. A successful attempt would mean the compromise of the account.

#### Remediation

Implemented layered rate limiting:

- Per-IP throttling --> mitigates password spraying attacks
- Per-account and per-IP throttling --> help defend against brute force attacks
- Time-window reset behavior --> account lockout policy
- Generic error messaging to reduce enumeration risk --> mitigate username enumeration from error messages

```ts
// lockout for 15 minutes after 10 failed login attempts from 1 IP
const loginIpRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10, // total login attempts per IP in window
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: true,
  message: {
    status: 'error',
    message: 'Too many login attempts from this IP address. Please try again later.\n'
  }
})

// lockout for 15 minutes after 5 failed login attempts from 1 IP for the same account
const loginAccountIpRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // attempts per email+IP pair in window
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: true,
  keyGenerator: (req) => {
    const email = normalizeLoginIdentifier(req.body?.email)
    const ip = req.ip || 'unknown'
    return `${email}:${ip}`
  },
  message: {
    status: 'error',
    message: 'Too many login attempts for this account. Please try again later.\n'
  }
})
```

#### Why This Works

Per-IP throttling mitigates against password spraying attacks. Per-account rate limiting protects against brute force attacks.

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

#### Why This Works

SAST does not replace manual testing, but it catches known insecure patterns earlier and prevents regression after remediation.

## How to Review This Project

1. Start with the threat model to understand system risk.
2. Review the findings to see exploitability and business impact.
3. Review the remediation notes to see how code-level fixes map to root causes.
4. Review the CI/CD workflow to see how security checks are automated.

## What This Project Proves

This project shows that I can move beyond vulnerability identification into AppSec engineering work: understanding architecture, validating exploitability, fixing root causes, and adding automation to prevent regressions.

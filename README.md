# Joseph Jung — Application Security Engineering Portfolio

Application Security Engineer candidate with a software engineering background, focused on secure code review, API security, vulnerability remediation, threat modeling, and DevSecOps automation.

This portfolio shows how I approach AppSec work: understand the system, identify trust boundaries, validate exploitability, fix the root cause in code, and add automation to prevent regressions.

---

## Featured Work

### 1. OWASP crAPI API Security Assessment & Code Remediation

**Focus:** API security, IDOR/BOLA, JWT validation, excessive data exposure, and server-side authorization.

[View project](./appsec-projects/Securing-crAPI-AppSec-Risk-Assessment-and-Remediation)  
[Findings](./appsec-projects/Securing-crAPI-AppSec-Risk-Assessment-and-Remediation/docs/findings) ·
[Evidence](./appsec-projects/Securing-crAPI-AppSec-Risk-Assessment-and-Remediation/evidence) ·
[Remediation Notes](./appsec-projects/Securing-crAPI-AppSec-Risk-Assessment-and-Remediation/docs/remediation.md) ·
[Threat Model](./appsec-projects/Securing-crAPI-AppSec-Risk-Assessment-and-Remediation/docs/threat-model.md)

Performed an end-to-end API security assessment of OWASP crAPI and implemented code-level fixes for common production API risks.

**Key work:**

- Remediated IDOR/BOLA by replacing object-ID-based access with user-scoped authorization checks
- Hardened JWT handling by enforcing signature validation and rejecting unsigned or unexpected tokens
- Reduced excessive data exposure by separating public response DTOs from internal user/domain models
- Added server-side role enforcement for privileged operations
- Documented root cause, exploit scenario, impact, remediation, and validation evidence

**Skills shown:** API Security, Secure Code Review, Java/Spring, Authorization Design, JWT Security, OWASP API Top 10

---

### 2. OWASP crAPI DevSecOps Security Pipeline

**Focus:** CI/CD security automation, dependency remediation, container scanning, and release-blocking gates.

[View project](./appsec-projects/devsecops-security-pipeline-owasp-crapi)  
[GitHub Actions Workflow](./appsec-projects/devsecops-security-pipeline-owasp-crapi/.github/workflows) ·
[Renovate Config](./appsec-projects/devsecops-security-pipeline-owasp-crapi/renovate.json) ·
[Trivy Evidence](./appsec-projects/devsecops-security-pipeline-owasp-crapi/evidence) ·
[Pipeline Notes](./appsec-projects/devsecops-security-pipeline-owasp-crapi/docs)

Built a targeted DevSecOps pipeline for the crAPI identity service to make security scanning scoped, reviewable, and enforceable.

**Key work:**

- Scoped Renovate dependency remediation to the identity service Gradle files
- Rebuilt the service Docker image from local source in GitHub Actions
- Added Trivy scanning for critical container vulnerabilities
- Preserved both text output and SARIF artifacts for review
- Designed the workflow so evidence is saved before the release gate fails

**Skills shown:** GitHub Actions, Renovate, Trivy, Docker, Gradle, SCA, Container Security, CI/CD Security Gates

---

### 3. OWASP Juice Shop AppSec Assessment & Remediation

**Focus:** Threat modeling, SQL injection remediation, brute-force protection, and SAST automation.

[View project](./appsec-projects/Risk_Assessment_Case_Study-OWASP_Juice_Shop)  
[Threat Model](./appsec-projects/Risk_Assessment_Case_Study-OWASP_Juice_Shop/docs/threat-model.md) ·
[Findings](./appsec-projects/Risk_Assessment_Case_Study-OWASP_Juice_Shop/docs/findings) ·
[Evidence](./appsec-projects/Risk_Assessment_Case_Study-OWASP_Juice_Shop/evidence) ·
[Semgrep Workflow](./appsec-projects/Risk_Assessment_Case_Study-OWASP_Juice_Shop/.github/workflows)

Assessed OWASP Juice Shop using architecture review, STRIDE threat modeling, manual validation, code remediation, and CI/CD scanning.

**Key work:**

- Built a threat model using data-flow diagrams, trust boundaries, and STRIDE
- Validated SQL injection through manual testing and backend code review
- Replaced unsafe SQL construction with parameterized queries
- Identified brute-force risk and implemented account/IP-aware rate limiting
- Added Semgrep scanning to GitHub Actions to detect insecure patterns before merge

**Skills shown:** Threat Modeling, STRIDE, Burp Suite, SQL Injection, Rate Limiting, Semgrep, Secure Code Review

---

## Technical Skills

| Area | Skills |
|---|---|
| AppSec | Secure Code Review, API Security, OWASP Top 10, OWASP API Top 10, Threat Modeling |
| Vulnerabilities | IDOR/BOLA, Broken Authentication, Excessive Data Exposure, SQL Injection, Brute Force, BFLA |
| Remediation | Ownership Checks, Parameterized Queries, JWT Validation, DTO Separation, Rate Limiting |
| DevSecOps | GitHub Actions, Semgrep, Trivy, Renovate, SARIF, CI/CD Security Gates |
| Engineering | Java, Spring, TypeScript, JavaScript, Node.js/Express, SQL, Docker, Gradle |

---

## Review Guide

For the strongest signal, review the projects in this order:

1. **crAPI API Security Assessment & Code Remediation** — secure code review, authorization fixes, JWT hardening, and API remediation
2. **crAPI DevSecOps Security Pipeline** — CI/CD security automation, dependency remediation, container scanning, and evidence handling
3. **Juice Shop AppSec Assessment & Remediation** — threat modeling, manual testing, SQL injection remediation, brute-force mitigation, and SAST

Across the projects, the pattern is the same: understand the architecture, prove the risk, fix the root cause, and add automation where it helps.

---

## Contact

- GitHub: [JosephJ12](https://github.com/JosephJ12)
- LinkedIn: [josephjung12](https://www.linkedin.com/in/josephjung12)

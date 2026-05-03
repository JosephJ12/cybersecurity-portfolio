# Securing crAPI: AppSec Risk Assessment & Remediation

**Threat modeling, API exploitation, and secure fixes aligned to the OWASP API Top 10.**

---

## 📌 Overview

End-to-end application security assessment of crAPI, simulating how a real AppSec engineer identifies, exploits, and remediates API vulnerabilities across a secure SDLC.

---

## 🏗️ Architecture Overview

```mermaid
flowchart LR
    User -->|HTTP Requests| crapi-web[CRAPI-WEB: Web Client Service]
    crapi-web --> crapi-identity[CRAPI-IDENTITY: Auth Service]
    crapi-web --> crapi-community[CRAPI-COMMUNITY: Community Forum Service]
    crapi-web --> crapi-workshop[CRAPI-WORKSHOP: Shop Service]
    crapi-web --> crapi-chatbot[CRPAPI-CHATBOT: AI Chatbot Service]
    crapi-identity --> db[Mongo DB]
    crapi-community --> db[Mongo DB]
    crapi-workshop --> db[Mongo DB]
    crapi-chatbot --> cdb[Chroma DB]

    subgraph Trust Boundary 1: Authenticated User Layer
        crapi-identity
        crapi-community
        crapi-workshop
        crapi-chatbot
    end
    subgraph Trust Boundary 2: Data Layer
        db
        cdb
    end
```

## 🔄 Data Flow (DFD)
```mermaid
flowchart TD
    U[User] -->|HTTP Requests| crapi-web[CRAPI-WEB]
    crapi-web -->|Login Request| crapi-identity[CRAPI-IDENTITY]
    crapi-identity -->|JWT Token| crapi-web
    crapi-web -->|JWT Token| crapi-community[CRAPI-COMMUNITY]
    crapi-web -->|JWT Token| crapi-workshop[CRAPI-WORKSHOP]
    crapi-community -->|Validates token| DB
    crapi-workshop -->|Validates token| DB
    DB --> crapi-community
    DB --> crapi-workshop
    crapi-community -->|Json Response| crapi-web
    crapi-workshop -->|Json Response| crapi-web
```

## ⚠️ Threat Modeling (STRIDE)
| Category        | Example in crAPI                      |
| --------------- | ------------------------------------- |
| Spoofing        | JWT Token Forgery [CR02]              |
| Tampering       | Improper JWT Token Validation [CR02]  |
| Repudiation     | Lack of logging                       |
| Info Disclosure | Excessive data exposure [CR03]        |
| DoS             | No rate limiting                      |
| Elevation       | Broken object-level auth (BOLA) [CR04]|

## 🔍 Key Vulnerabilities
- Broken Object Level Authorization (BOLA)
- Broken Authentication
- Excessive Data Exposure
- Improper Access Control on Function

## 🔐 Remediation Highlights
- Check data ownership → IDOR prevention
- JWT token validation → Fix broken authentication
- Create separate public user model → Hide sensitive data
- Improved authentication controls → Implement authorized access to admin functions


## 🔁 DevSecOps Integration

```mermaid
flowchart LR
    Dev --> GitHub
    GitHub --> CI[GitHub Actions]
    CI --> SAST[Semgrep SAST]
    CI --> SCA[Dependency Scan]
    SAST --> Build
    SCA --> Build
    Build --> Deploy
```

## 📊 Impact
- Mitigated the Top 4 of OWASP API Top 10 risks
- Shifted security left (CI/CD)
- Improved resilience against real-world API attacks

# Threat Modeling OWASP crAPI

## OWASP API Top 10 + STRIDE Application

The crAPI application is a vast application composed of many microservices. Instead of trying to touch on every single threat lightly, we will dive more deeply into a few of the common, big vulnerabilities from the OWASP API Top 10. Namely, we will model the following threats:

1. API1 2023: Broken Object Level Authorization
2. API2 2023: Broken Authentication
3. API3 2023: Broken Object Property Level Authorization

Let's apply STRIDE to these:


| Risk ID | CVSS Rating | Risk | STRIDE | OWASP API Top 10 | Likelihood | Impact | Mitigation |
|---|---|---|---|---|---|---|---|

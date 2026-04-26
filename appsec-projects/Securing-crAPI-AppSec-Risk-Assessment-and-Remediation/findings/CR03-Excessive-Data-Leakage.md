# CR03: Excessive Data Leakage on Community Post

The Get Post Details API endpoint on `/community/api/v2/community/posts/[POST_ID]` leaks the post author's sensitive data, such as the author's email and vehicle ID. The unauthorized retrieval or modification of an object's field is number 3 on the OWASP API Top 10. 

## Why OWASP API3 2023: Broken Object Property Level Authorization?

API3 2023: Broken Object Property Level Authorization (BOPLA) is often confused with API1 2023: Broken Object Level Authorization (BOLA). The main difference between API3 and API1 is, in terms of data retrieval from databases, API3 is getting the wrong data columns while API1 is getting the wrong row. BOPLA involves getting or modifying unauthorized data fields for the right object. BOLA involves getting the wrong object altogether.

Therefore, since we are getting the right author's data, but also the wrong fields (email and vehicleID), CR03 falls under API3 rather than API1. 

## Reproduction Steps

**REQUIREMENTS**
- Valid account
- Web Proxy (BurpSuite, Caido)

1. After logging in, go to Community page, which should direct us to the `forum` URL.

<img width="2688" height="1148" alt="image" src="https://github.com/user-attachments/assets/33f3cb6d-6eeb-44a0-b336-51b5691cf04c" />

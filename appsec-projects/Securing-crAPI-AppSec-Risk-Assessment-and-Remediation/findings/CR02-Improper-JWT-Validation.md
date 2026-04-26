# CR02: Improper JWT Token Validation

## CVSS Severity
Medium (5.0)

AV:N/AC:L/PR:L/UI:N/S:C/C:L/I:N/A:N

## Affected Endpoint
1. `GET /community/api/v2/community/posts/[POST_ID]`
2. `GET /community/api/v2/community/posts/recent`

## Impact
An attacker could view user emails and vehicle IDs, which can be leveraged when chaining with other vulnerabilities for higher impact. This vulnerability violates the Confidentiality part of the CIA triad and is an example of Information Disclosure from the STRIDE threat modeling framework. 

## Root Cause
The Post model nests an Author object inside, which includes sensitive information such as their email and vehicleID.

## Evidence
See:
- evidence/screenshots/sql-injection-before.png
- evidence/manual-tests/sql-injection-curl-before.md

## Remediation
Create a separate model for post authors, one that only gives the necessary information on Post retrievals. Then, change the Author object to the Post Author object in the Post model.

## Retest Result
Retrieving community posts no longer leaks the author's email and vehicleID. 


## OWASP API2 2023: Broken Authentication


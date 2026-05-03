# CR01: Vehicle Location IDOR  

## CVSS Severity
Medium (5.0)

AV:N/AC:L/PR:L/UI:N/S:C/C:L/I:N/A:N

## Affected Endpoint
1. `GET /vehicle/[VEHICLE_ID]/location`

## Impact
The application returns a vehicle's location without checking object authorization or data ownership. This means an attacker can retrieve the location of any vehicle given their UUID, which violates the confidentiality of sensitive user information.

## Root Cause
The `getVehicleLocation` function only takes the vehicle ID as input and does not check whether the requesting user has sufficient rights to the data. Since no authorization validation is in place, any user can request a vehicle's location given the vehicle ID.

## Evidence
See:
- evidence/screenshots/sql-injection-before.png
- evidence/manual-tests/sql-injection-curl-before.md

## Remediation
Verify the requesting user's access before retrieving the vehicle location. 

## Retest Result
Retrieving community posts no longer leaks the author's email and vehicleID. 

## OWASP API1 2023: Broken Object Level Authorization

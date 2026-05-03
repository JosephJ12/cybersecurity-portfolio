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
- ![Token for test@test.com user](../evidence/CR01/vehicle-location-idor-1.png)
- ![Able to retrieve another user's vehicle location](../evidence/CR01/vehicle-location-idor-2.png)

## Remediation
Verify the requesting user's access before retrieving the vehicle location. 

## Retest Result
Vehicle ownership is checked before vehicle location retrieval. Therefore, one can only get the location of their own vehicles. 

## OWASP API1 2023: Broken Object Level Authorization

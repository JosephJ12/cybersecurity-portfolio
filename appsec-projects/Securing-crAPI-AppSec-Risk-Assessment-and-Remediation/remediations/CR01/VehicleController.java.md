# VehicleController.java

```java
import com.crapi.entity.User;

.....

import com.crapi.service.UserService;

.....

@Autowired UserService userService;

.....

  /**
   * @param request
   * @return this api returns List of vehicle of user Dashboard Vehicle details fetch by this
   *     api @GetMapping("/vehicle/vehicles") public ResponseEntity<?>
   *     getVehicleOwnership(HttpServletRequest request) {
   *     <p>List<VehicleOwnership> vehicleOwnership =
   *     vehicleOwnershipService.getPreviousOwners(request); if (vehicleOwnership != null) { return
   *     ResponseEntity.status(HttpStatus.OK).body(vehicleOwnership); } return
   *     ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR) .body(new
   *     CRAPIResponse(UserMessage.DID_NOT_GET_VEHICLE_FOR_USER, 500)); }
   */

  /**
   * @param carId
   * @return VehicleDetails on given car_id.
   */
  @GetMapping("/vehicle/{carId}/location")
  public ResponseEntity<?> getLocationBOLA(
      @PathVariable("carId") UUID carId, HttpServletRequest request) {
    User user = userService.getUserFromToken(request);
    VehicleLocationResponse vehicleDetails = vehicleService.getVehicleLocation(carId, user.getId());
    if (vehicleDetails != null) return ResponseEntity.ok().body(vehicleDetails);
    else
      return ResponseEntity.status(HttpStatus.NOT_FOUND)
          .body(new CRAPIResponse(UserMessage.DID_NOT_GET_VEHICLE_FOR_USER));
  }
```

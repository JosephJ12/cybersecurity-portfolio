# Code-Level Remediation of CR01

In order to properly and elegantly address the vehicle location IDOR vulnerability, changes needed to be made to many different files. This involved restructuring some functions to take extra inputs, such as the requesting user's ID, to verify that the requesting user is the owner of the vehicle before returning its location. 

This involved refactoring the following files:
- VehicleController.java: receive the HTTP request as an extra input, validate the JWT token, extract the user ID from it, and pass it along to the `getVehicleLocation` function.
- VehicleDetailsRepository.java: adding a function to search for vehicles given the vehicle ID and owner ID.
- VehicleService.java: update the interface for the `getVehicleLocation` function to take the requesting user's ID as an argument.
- VehicleServiceImpl.java: update the vehicle search function to search by the car ID and requesting user ID.
- VehicleServiceImplTest.java: update the unit tests with the new functions.

```
Change Date: 5/5/2026
Change By: Joseph Jung
```

## VehicleController.java

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


## VehicleDetailsRepository.java

```java
VehicleDetails findByUuidAndOwner_id(UUID uuid, Long id);
```

## VehicleService.java

```java
VehicleLocationResponse getVehicleLocation(UUID carId, Long currentUserId);
```

## VehicleServiceImpl.java

```java
  /**
   * @param carId
   * @return VehicleDetails which is linked with this carId.
   */
  @Transactional
  @Override
  public VehicleLocationResponse getVehicleLocation(UUID carId, Long currentUserId) {
    VehicleDetails vehicleDetails = null;
    VehicleLocationResponse vehicleLocationForm = null;
    UserDetails userDetails = null;
    try {
      vehicleDetails = vehicleDetailsRepository.findByUuidAndOwner_id(carId, currentUserId);
      if (vehicleDetails != null && vehicleDetails.getOwner() != null) {
        // vehicleDetails = vehicleDetailsRepository.findByVehicleLocation_id(carId);
        // vehicleDetails.setVehicleLocation(getVehicleLocationList().get(random.nextInt(getVehicleLocationList().size())));
        userDetails = userDetailsRepository.findByUser_id(vehicleDetails.getOwner().getId());
        vehicleLocationForm =
            new VehicleLocationResponse(
                carId,
                (userDetails != null ? userDetails.getName() : null),
                (userDetails != null ? userDetails.getUser().getEmail() : null),
                vehicleDetails.getVehicleLocation());
        return vehicleLocationForm;
      }
    } catch (Exception exception) {
      log.error("Fail to get vehicle location-> Message: {}", exception);
    }
    return null;
  }
```

## VehicleServiceImplTest.java

```java
@Test
  public void getVehicleLocationSuccessWithUserDetailsNotNull() {
    VehicleDetails vehicleDetails = getDummyVehicleDetails();
    UserDetails userDetails = getDummyUserDetails();
    User user = getDummyUser();
    Long userId = user.getId();
    Mockito.when(vehicleDetailsRepository.findByUuidAndOwner_id(vehicleDetails.getUuid(), userId))
        .thenReturn(vehicleDetails);
    Mockito.when(userDetailsRepository.findByUser_id(1L)).thenReturn(userDetails);
    VehicleLocationResponse vehicleLocationResponse =
        vehicleService.getVehicleLocation(vehicleDetails.getUuid(), userId);
    Assertions.assertNotNull(vehicleLocationResponse);
    Assertions.assertEquals(userDetails.getName(), vehicleLocationResponse.getFullName());
    Assertions.assertEquals(userDetails.getUser().getEmail(), vehicleLocationResponse.getEmail());
  }

  @Test
  public void getVehicleLocationSuccessWithUserDetailsNull() {
    VehicleDetails vehicleDetails = getDummyVehicleDetails();
    UserDetails userDetails = getDummyUserDetails();
    userDetails.setName(null);
    User user = getDummyUser();
    Long userId = user.getId();
    Mockito.when(vehicleDetailsRepository.findByUuidAndOwner_id(vehicleDetails.getUuid(), userId))
        .thenReturn(vehicleDetails);
    Mockito.when(userDetailsRepository.findByUser_id(1L)).thenReturn(userDetails);
    VehicleLocationResponse vehicleLocationResponse =
        vehicleService.getVehicleLocation(vehicleDetails.getUuid(), userId);
    Assertions.assertNotNull(vehicleLocationResponse);
    Assertions.assertNull(vehicleLocationResponse.getFullName());
  }

  @Test
  public void getVehicleLocationNotFoundWhenVehicleDetailsAreNull() {
    VehicleDetails vehicleDetails = getDummyVehicleDetails();
    User user = getDummyUser();
    Long userId = user.getId();
    Mockito.when(vehicleDetailsRepository.findByUuidAndOwner_id(vehicleDetails.getUuid(), userId))
        .thenReturn(null);
    VehicleLocationResponse vehicleLocationResponse =
        vehicleService.getVehicleLocation(vehicleDetails.getUuid(), userId);
    Assertions.assertNull(vehicleLocationResponse);
  }

  @Test
  public void getVehicleLocationNotFoundWhenVehicleDetailsOwnerIsNull() {
    VehicleDetails vehicleDetails = getDummyVehicleDetails();
    vehicleDetails.setOwner(null);
    User user = getDummyUser();
    Long userId = user.getId();
    Mockito.when(vehicleDetailsRepository.findByUuidAndOwner_id(vehicleDetails.getUuid(), userId))
        .thenReturn(vehicleDetails);
    VehicleLocationResponse vehicleLocationResponse =
        vehicleService.getVehicleLocation(vehicleDetails.getUuid(), userId);
    Assertions.assertNull(vehicleLocationResponse);
  }
```

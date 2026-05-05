# VehicleServiceImplTest.java

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

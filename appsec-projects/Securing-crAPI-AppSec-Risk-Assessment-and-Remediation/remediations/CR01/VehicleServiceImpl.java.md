# VehicleServiceImpl.java

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

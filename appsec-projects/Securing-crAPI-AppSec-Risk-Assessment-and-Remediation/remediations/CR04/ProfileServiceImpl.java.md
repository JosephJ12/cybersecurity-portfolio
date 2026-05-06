# ProfileServiceImpl.java

```java
import com.crapi.enums.ERole;

==========

  /**
   * @param videoId
   * @param request
   * @return boolean for delete object if perform by admin
   */
  @Transactional
  @Override
  public CRAPIResponse deleteAdminProfileVideo(Long videoId, HttpServletRequest request) {
    Optional<ProfileVideo> optionalProfileVideo;
    ProfileVideo profileVideo;
    optionalProfileVideo = profileVideoRepository.findById(videoId);
    User user = userService.getUserFromToken(request); // validates token while getting username
    ERole role = user.getRole();
    if (optionalProfileVideo.isPresent() && role == ERole.ROLE_ADMIN) {
      profileVideo = optionalProfileVideo.get();
      profileVideo.setUser(null);
      profileVideoRepository.delete(profileVideo);
      return new CRAPIResponse(UserMessage.VIDEO_DELETED_SUCCESS_MESSAGE, 200);
    }
    throw new CRAPIExceptionHandler(UserMessage.SORRY_DIDNT_GET_PROFILE, 404);
  }
```
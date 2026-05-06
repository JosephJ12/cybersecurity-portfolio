# JwtProvider.java

```java
/**
   * @param token
   * @return username from JWT Token
   */
  public String getUserNameFromJwtToken(String token) throws ParseException {
    // New code validates valid JWT token before retrieving username
    SignedJWT signedJWT = SignedJWT.parse(token);

    if (!validateJwtToken(token)) {
      throw new ParseException("Invalid JWT token", 0);
    }
    return signedJWT.getJWTClaimsSet().getSubject();
  }

  /**
   * @param authToken
   * @return validate token expire and true boolean
   */
  public boolean validateJwtToken(String authToken) {
    try {
      SignedJWT signedJWT = SignedJWT.parse(authToken);
      JWSHeader header = signedJWT.getHeader();
      Algorithm alg = header.getAlgorithm();
      boolean valid = false;
      // JWT Algorithm confusion vulnerability
      log.debug("Algorithm: " + alg.getName());
      if (alg == null || !Objects.equals(alg.getName(), "RS256")) {
        throw new JOSEException("Invalid JWT algorithm. Expected RS256.");
      } else {
        RSASSAVerifier verifier = new RSASSAVerifier(this.publicRSAKey);
        valid = signedJWT.verify(verifier);
        log.debug("JWT valid?: " + valid);
        return valid;
      }
    } catch (ParseException | JOSEException e) {
      log.error("JWT verification failed. Token rejected. Message: %d", e);
    }

    return false;
  }
```
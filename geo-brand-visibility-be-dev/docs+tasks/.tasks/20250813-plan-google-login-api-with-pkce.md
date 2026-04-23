# Google Login API with Authorization Code Flow + PKCE Implementation Plan

## Overview

This development plan outlines the backend tasks required to implement Google OAuth Login API with Authorization Code flow + PKCE (Proof Key for Code Exchange) for the Generative Engine Optimization (GEO) Platform. The implementation will follow OAuth 2.0 security best practices, with PKCE providing protection against authorization code interception attacks and CSRF vulnerabilities.

## 1. Project Setup

- [x] Research and gather Google OAuth + PKCE requirements
  - [x] Review Google OAuth 2.0 documentation for Authorization Code flow
  - [x] Study PKCE implementation requirements (code_verifier, code_challenge generation)
  - [x] Determine required API scopes for basic profile access (openid, email, profile)
  - [x] Identify token exchange endpoints and methods
- [x] Install required packages
  - [x] Install google-auth-library for token verification
  - [x] Add crypto libraries for PKCE verification if needed
  - [x] Install JWT libraries for token handling
- [x] Configure Google OAuth credentials
  - [x] Create Google OAuth client in Google Cloud Console
  - [x] Set up authorized redirect URIs
  - [x] Add environment variables for Google client credentials
  - [x] Update env-sample with new variables
  - [x] Configure allowed JavaScript origins for client applications

## 2. Backend Foundation

- [x] Create Google Module as a service provider
  - [x] Create google/google.module.ts for centralizing Google-related functionality
  - [x] Set up folder structure (interfaces, services, dtos)
  - [x] Configure module to export GoogleService for use by other modules
- [x] Create Google Auth DTOs (Data Transfer Objects)
  - [x] Define google-authorization-code-exchange.dto.ts with code, codeVerifier, and redirectUri fields
  - [x] Add class-validator decorators for input validation
  - [x] Create google-profile.interface.ts for Google user profile data
- [x] Implement Google Service
  - [x] Create google.service.ts for handling Google-specific operations
  - [x] Implement authorization code exchange with PKCE verification
  - [x] Create methods to extract profile information from tokens
  - [x] Implement error handling for Google API interactions
  - [x] Add JWKS (JSON Web Key Set) handling for ID token verification
- [x] Update database schema
  - [x] Add googleId field to User model in Prisma schema
  - [x] Add avatar field to User model in Prisma schema
  - [x] Create migration for schema updates

## 3. Feature-specific Backend

- [x] Implement Google authorization code exchange with PKCE
  - [x] Create exchangeAuthorizationCode method in GoogleService
    - [x] Accept authorization code, code_verifier, and redirect_uri
    - [x] Make HTTP request to Google token endpoint with required parameters
    - [x] Verify code_verifier against code_challenge stored by Google
    - [x] Extract and validate ID token from response
    - [x] Extract user profile information
- [x] Create custom exceptions for Google authentication
  - [x] Create invalid-google-token.exception.ts
  - [x] Create google-verification-failed.exception.ts
  - [x] Create pkce-verification-failed.exception.ts
  - [x] Set up proper HTTP status codes and messages
- [x] Extend Auth service with Google login capability
  - [x] Update AuthService to use GoogleService
  - [x] Create loginWithGoogle method in AuthService
  - [x] Implement logic to create or find users by Google ID
  - [x] Handle account linking for existing email users
- [x] Add login controller endpoint in Auth module
  - [x] Create POST /auth/login-google route handler in auth.controller.ts
  - [x] Apply input validation using DTOs
  - [x] Implement proper error handling
  - [x] Return appropriate response structure with isNewUser flag

## 4. Service Integration

- [x] Integrate Google module with Auth module
  - [x] Import GoogleModule in AuthModule
  - [x] Inject GoogleService into AuthService
  - [x] Ensure clean separation of concerns between modules
- [x] Integrate with UserService
  - [x] Update user creation method to handle Google profile data
  - [x] Create or update methods to find users by Google ID
  - [x] Implement logic to handle existing email conflicts
  - [x] Set emailVerified flag to true for Google-authenticated users
- [x] Integrate with TokenService
  - [x] Ensure token generation works with Google-authenticated users
  - [x] Include appropriate user information in JWT payload
  - [x] Set proper expiration time for tokens
- [x] Set up logging service for security events
  - [x] Log Google authentication attempts
  - [x] Track success/failure metrics
  - [x] Implement audit trail for new account creation

## 5. Testing

- [x] Write unit tests for Google Service
  - [x] Test authorization code exchange with PKCE
  - [x] Test user profile extraction from tokens
  - [x] Test error handling for various failure scenarios
- [x] Write unit tests for extended Auth Service
  - [x] Test Google login flow with authorization code
  - [x] Test user creation from Google profile
  - [x] Test account linking scenarios
  - [x] Test error handling and edge cases
- [x] Create integration tests for Google login endpoint
  - [x] Test with valid authorization code mocks
  - [x] Test with invalid PKCE verifier
  - [x] Test with invalid tokens
  - [x] Test new user creation flow
  - [x] Test returning user recognition
- [ ] Implement security testing
  - [ ] Test PKCE verification
  - [ ] Test token tampering detection
  - [ ] Verify proper handling of expired tokens
  - [ ] Ensure proper error handling without information leakage

## 6. Documentation

- [x] Update API documentation
  - [x] Document request and response formats for the endpoint
  - [x] Document all possible error responses
  - [x] Include example usage with PKCE flow
  - [x] Document security considerations
- [ ] Create frontend integration guide
  - [ ] Document required Google OAuth client setup
  - [ ] Provide sample code for PKCE implementation
    - [ ] Code verifier generation (43-128 characters)
    - [ ] Code challenge generation (S256 hash of verifier)
  - [ ] Document authorization URL construction
  - [ ] Show examples of exchanging authorization code with code verifier
- [x] Add code documentation
  - [x] Add JSDoc comments for service methods
  - [x] Document security considerations
  - [x] Add inline comments for complex verification logic

## 7. Deployment

- [ ] Prepare for deployment
  - [ ] Configure environment variables in production
  - [ ] Set up Google OAuth client for production environment
  - [ ] Ensure proper CORS configuration for allowed origins
- [ ] Create deployment checklist
  - [ ] Verify Google API credentials are properly configured
  - [ ] Check environment variables are set correctly
  - [ ] Test Google login flow in staging environment
- [ ] Monitoring setup
  - [ ] Configure alerts for high failure rates
  - [ ] Set up logging for authentication attempts
  - [ ] Create dashboard for OAuth performance metrics

## 8. Maintenance

- [ ] Set up monitoring for Google API changes
  - [ ] Subscribe to Google OAuth API announcements
  - [ ] Plan for potential deprecations or changes
- [ ] Create maintenance documentation
  - [ ] Document Google OAuth configuration steps
  - [ ] Create troubleshooting guide for common issues
  - [ ] Document procedures for handling Google account issues
- [ ] Plan for future enhancements
  - [ ] Consider implementing rate limiting
  - [ ] Evaluate refresh token handling
  - [ ] Explore additional Google API integrations

## PKCE Implementation Details

### What is PKCE?

PKCE (Proof Key for Code Exchange) is a security extension for OAuth 2.0's Authorization Code flow that prevents authorization code interception attacks. It works by having the client generate a secret "code verifier" and a derived "code challenge" that binds the authorization request to the token exchange request.

### PKCE Flow

1. **Client-side:**
   - Generate a cryptographically random `code_verifier` (43-128 characters)
   - Create a `code_challenge` by hashing the verifier with SHA-256 and base64url encoding it
   - Include the `code_challenge` and `code_challenge_method=S256` when requesting the authorization code

2. **Authorization Server (Google):**
   - Stores the `code_challenge` with the issued authorization code

3. **Client-side after redirect:**
   - Receives the authorization code
   - Sends code, original `code_verifier`, and other parameters to our backend

4. **Backend:**
   - Forwards the authorization code, `code_verifier`, and other parameters to Google
   - Google verifies that the hashed `code_verifier` matches the original `code_challenge`
   - If verified, Google issues tokens
   - Our backend validates the ID token and creates/authenticates the user

### Benefits of PKCE

- Prevents authorization code interception attacks
- Mitigates CSRF vulnerabilities
- Recommended in OAuth 2.0 best practices
- Required in OAuth 2.1
- Works for both public clients (SPAs, mobile apps) and confidential clients (server-side)

## API Endpoint

### Authorization Code Exchange with PKCE

**Endpoint:** `POST /api/auth/login-google`

**Request:**

```json
{
  "code": "4/P7q7W91a-oMsCeLvIaQm6bTrgtp7",
  "codeVerifier": "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk",
  "redirectUri": "https://example.com/callback"
}
```

**Response:**

```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "userId": "123e4567-e89b-12d3-a456-426614174000",
  "expiresIn": 3600,
  "isNewUser": false
}
```

## Error Handling

- **400 Bad Request:** Missing or invalid parameters
- **401 Unauthorized:** Invalid tokens or PKCE verification failure
- **403 Forbidden:** Google account not verified or lacks permissions
- **500 Internal Server Error:** Server-side errors

All error responses will follow a consistent format:

```json
{
  "statusCode": 401,
  "message": "Invalid Google token",
  "error": "Unauthorized"
}
```

## Security Considerations

- Use SHA-256 for code challenge method (reject plain)
- Implement proper CORS policies
- Store client secret securely (server-side only)
- Validate all tokens (signature, issuer, audience, expiration)
- Never expose sensitive verification details in error messages
- Set appropriate token expiration times

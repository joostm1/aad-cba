# Generating certificates with openssl.

CBA in Azure AD has this basic certificate requirements:

**Users authenticate with a certificate that:**

- provides the user's identity
- is signed by _a certain certificate authority (CA)_.

**Azure AD verifies the user's identity by:**

- verifying that the requesting (user) certificate is signed by _a certain CA_.
- mapping the requesting (user) certificate to a user.



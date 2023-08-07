# Generating certificates with openssl.

CBA in Azure AD has this basic flow:

**- Users authenticate with a certificate that:**

    - provides the user's identity
    - is signed by *a certain certificate authority (CA)*.

**- Azure AD verifies the user's identity by:**

    - verifying that the requesting (user) certificate is signed by *a certain CA*.
    - mapping the requesting (user) certificate to a user.

    

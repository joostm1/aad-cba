# Tools and tutorial for Certifcate Based Authentication (CBA) in Azure AD.
## using [openssl](https://www.openssl.org/) and a [Yubikey 5](https://www.yubico.com/products/yubikey-5-overview/).

One of the authentication methods in Azure AD is [Certificate-based authentication](https://learn.microsoft.com/en-us/azure/active-directory/authentication/concept-certificate-based-authentication).
This is an attractive authentication method as it combines a good (passwordless) user experience with good security.

This repo contains some tools and tutorial for enabling CBA in Azure AD. It is dived in three parts:

1. [Generating certificates using openssl](README-aad-cba-openssl.md).
2. [Enabling CBA in AAD](README-aad-cba.md).
3. Authenticate in AAD with a [certifcate on a Yubikey 5 series](README-aad-cba-yubikey5.md).





# Generating certificates with openssl.


### CBA in Azure AD has this basic certificate requirements:


#### - Users authenticate with a certificate that:

- provides the user's identity, i.e., the user principal name.

- is signed by _a certain_ certificate authority (CA).

 #### - Azure AD verifies the user's identity by:

- verifying that the requesting (user) certificate is signed by _a certain_ CA.

- mapping the requesting (user) certificate to a user.


#### Let's create this _certain_ CA as well as the user certificate.

**Clone this aad-cba thing to your local workspace:**

    git clone git@github.com:joostm1/aad-cba.git

**Create both the CA and the user certificate:**

    make ORG=*YOURORG* UPN=*yourname@yourdomain.com*

Provide your organisation name and your UPN on this commandline. 

### Here's a run in my world with explanation:

My organisation name is XYZ9 and my UPN is joost@xyz9.net, so I do:

    cd aad-cba
    make ORG=XYZ9 UPN=joost@xyz9.net

First thing created is a key for the CA certificate:

    openssl genpkey -config 'XYZ9/XYZ9-CA.cnf' -out XYZ9/private/cakey.PEM -outform PEM \
      -algorithm RSA
      Using configuration from XYZ9/XYZ9-CA.cnf
      +........+....+.................

With this key, a new selfsigned certificate is created with a lifetime of 10 years:

    openssl req -config 'XYZ9/XYZ9-CA.cnf' -x509 -days 3650 -reqexts ca_ext \
        -outform PEM -key XYZ9/private/cakey.PEM -out XYZ9/certs/cacer.PEM

The ca_ext section in [config](ORG-CA.cnf) file states that it is a CA and it's intended use to sign other stuff:

    [ ca_ext ]
    basicConstraints        = critical,CA:true
    keyUsage                = critical,keyCertSign,cRLSign
    subjectKeyIdentifier    = hash

Azure requires the CA certificate to be in PEM format with a `.cer` file extension, so we convert it:

    openssl x509 -in XYZ9/certs/cacer.PEM -inform PEM -out XYZ9/certs/cacer.cer -outform DER

This CA in DER format,  `XYZ9/certs/cacer.cer` is the one that must be configured in AAD | Security | Certificate authorities. 
See the [next](README-aad-cba.md) chapter for that.

If we get details from this CA we see:

>   openssl x509 -in XYZ9/certs/cacer.cer -noout -text
>   Certificate:
>     Data:
>        Version: 3 (0x2)
>         Serial Number:
>            2b:96:a0:f0:78:bd:06:1c:4b:df:4f:58:92:9a:e3:80:6a:35:9b:71
>        Signature Algorithm: sha256WithRSAEncryption
>        Issuer: C = NL, O = XYZ9, CN = XYZ9 root CA
>        Validity
>            Not Before: Aug  7 14:58:08 2023 GMT
>            Not After : Aug  4 14:58:08 2033 GMT
>        Subject: C = NL, O = XYZ9, CN = XYZ9 root CA
>        Subject Public Key Info:
>            Public Key Algorithm: rsaEncryption
>                Public-Key: (2048 bit)
>                Modulus:
>                    a3:31:fc:04:8e:52:cb:c2:86:06:6c:02:e4:12:50:
>                    ..
>                Exponent: 65537 (0x10001)
>        X509v3 extensions:
>            X509v3 Basic Constraints: critical
>                CA:TRUE
>            X509v3 Key Usage: critical
>                Certificate Sign, CRL Sign
>            X509v3 Subject Key Identifier:
>                DB:BE:F9:2C:12:05:57:FF:48:AA:50:24:64:5C:B6:99:52:20:38:42
>    Signature Algorithm: sha256WithRSAEncryption
>    Signature Value:
>        07:61:1b:3c:cd:e8:e4:57:9f:88:93:3f:e2:4a:90:30:96:5d:



    openssl genpkey -config 'XYZ9/XYZ9-CR.cnf' -out XYZ9/private/joost@xyz9.net-key.PEM -outform PEM \
        -algorithm RSA
      Using configuration from XYZ9/XYZ9-CR.cnf
      .........+.+..+.........+...+......+....+...+.....+...+....+...+.....+....+...........+...+.

    openssl req -config 'XYZ9/XYZ9-CR.cnf' -new -reqexts cr_ext -outform PEM \
        -key XYZ9/private/joost@xyz9.net-key.PEM -out XYZ9/certs/joost@xyz9.net-csr.PEM

    openssl x509 -req -extfile 'XYZ9/XYZ9-CR.cnf' -extensions cr_ext -days 365 \
        -in XYZ9/certs/joost@xyz9.net-csr.PEM -CA XYZ9/certs/cacer.PEM -CAkey XYZ9/private/cakey.PEM \
        -out XYZ9/certs/joost@xyz9.net-cer.PEM
    Certificate request self-signature ok
    subject=C = NL, O = XYZ9, CN = joost@xyz9.net
        
    openssl pkcs12 -export -inkey XYZ9/private/joost@xyz9.net-key.PEM \
        -in XYZ9/certs/joost@xyz9.net-cer.PEM \
        -name "joost@xyz9.net" -out XYZ9/certs/joost@xyz9.net.PFX
    Enter Export Password:
    Verifying - Enter Export Password:







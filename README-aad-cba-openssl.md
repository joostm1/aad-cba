# Generating certificates with openssl.

CBA in Azure AD has this basic certificate requirements:


### - Users authenticate with a certificate that:

- provides the user's identity, i.e., the user principal name.

- is signed by _a certain certificate authority (CA)_.

 ### - Azure AD verifies the user's identity by:

- verifying that the requesting (user) certificate is signed by _a certain CA_.

- mapping the requesting (user) certificate to a user.

Here, we'll create both the CA certificate as well as the user certificate.




    git clone git@github.com:joostm1/aad-cba.git
    cd aa-cba
    make ORG=XYZ9 UPN=joost@xyz9.net
        mkdir -p XYZ9 XYZ9/certs XYZ9/private
        chmod 700 XYZ9/private
        cp ORG-CA.cnf 'XYZ9/XYZ9-CA.cnf'
        cp ORG-CR.cnf 'XYZ9/XYZ9-CR.cnf'
        openssl genpkey -config 'XYZ9/XYZ9-CA.cnf' -out XYZ9/private/cakey.PEM -outform PEM \
        -algorithm RSA
        Using configuration from XYZ9/XYZ9-CA.cnf
            .+..+...+.......+..+......................+......+...+.....+....+.....+...+.........+.+........+....+.................
        openssl req -config 'XYZ9/XYZ9-CA.cnf' -x509 -days 3650 -reqexts ca_ext \
            -outform PEM -key XYZ9/private/cakey.PEM -out XYZ9/certs/cacer.PEM

        openssl x509 -in XYZ9/certs/cacer.PEM -inform PEM -out XYZ9/certs/cacer.DER -outform DER

        openssl genpkey -config 'XYZ9/XYZ9-CR.cnf' -out XYZ9/private/joost@xyz9.net-key.PEM -outform PEM \
            -algorithm RSA
        Using configuration from XYZ9/XYZ9-CR.cnf
        .........+.+..+.........+...+......+....+...+.....+...+....+...+.....+....+...........+...+.+.........+......+.....+...+.

        openssl req -config 'XYZ9/XYZ9-CR.cnf' -new -reqexts cr_ext -outform PEM \
            -key XYZ9/private/joost@xyz9.net-key.PEM -out XYZ9/certs/joost@xyz9.net-csr.PEM

        openssl x509 -req -extfile 'XYZ9/XYZ9-CR.cnf' -extensions cr_ext -days 365 \
            -in XYZ9/certs/joost@xyz9.net-csr.PEM -CA XYZ9/certs/cacer.PEM -CAkey XYZ9/private/cakey.PEM \
            -out XYZ9/certs/joost@xyz9.net-cer.PEM
Certificate request self-signature ok
subject=C = NL, O = XYZ9, CN = joost@xyz9.net
openssl pkcs12 -export -inkey XYZ9/private/joost@xyz9.net-key.PEM -in XYZ9/certs/joost@xyz9.net-cer.PEM \
        -name "joost@xyz9.net" -out XYZ9/certs/joost@xyz9.net.PFX
Enter Export Password:
Verifying - Enter Export Password:







# Makefile

# run this as 
#		make ORG="XYZ9" UPN=joost@xyz9.net

# and read this for background:
#	https://goodworkaround.com/2022/02/15/digging-into-azure-ad-certificate-based-authentication/
#	https://gist.github.com/Soarez/9688998
#	https://www.feistyduck.com/library/openssl-cookbook/online/
#
# =v=
#	I thank you!

# openssl output formats
FORMPEM		:= PEM
FORMDER		:= DER
FORMPFX		:= PFX

# default form
FORM		:= $(FORMPEM)

# openssl config files for CA & user certificates
CONFCA		:= '$(ORG)/$(ORG)-CA.cnf'
CONFCR		:= '$(ORG)/$(ORG)-CR.cnf'

# files for the CA
CAKEY		:= $(ORG)/private/cakey.$(FORM)
CACER		:= $(ORG)/certs/cacer.$(FORM)
CACERDER 	:= $(ORG)/certs/cacer.cer

# files for the user certificate
UCER		:= $(ORG)/certs/$(UPN)-cer.$(FORM)
UCSR		:= $(ORG)/certs/$(UPN)-csr.$(FORM)
UCERKEY		:= $(ORG)/private/$(UPN)-key.$(FORM)
UCERPFX		:= $(ORG)/certs/$(UPN).$(FORMPFX)

$(UCERPFX): $(UCER)
	openssl pkcs12 -export -inkey $(UCERKEY) -in $(UCER) \
		-name "$(UPN)" -out $(UCERPFX) 
	@echo "Share $(UCERPFX) with $(UPN)." 
	@echo "Configure $(CACERDER) as a certificate authority in Azure AD."

$(UCER): $(UCSR) $(CACER)
	openssl x509 -req -extfile $(CONFCR) -extensions cr_ext -days 365 \
		-in $(UCSR) -CA $(CACER) -CAkey $(CAKEY) -out $(UCER)

$(UCSR): $(UCERKEY)
	openssl req -config $(CONFCR) -new -reqexts cr_ext -outform $(FORM) \
		-key $(UCERKEY) -out $(UCSR)

$(UCERKEY): $(ORG) $(CACERDER)
	openssl genpkey -config $(CONFCR) -out $(UCERKEY) -outform $(FORM) \
		-algorithm RSA

$(CACERDER): $(CACER)
	openssl x509 -in $(CACER) -inform $(FORM) -out $(CACERDER) -outform $(FORMDER)

$(CACER): $(CAKEY)
	openssl req -config $(CONFCA) -x509 -days 3650 -reqexts ca_ext \
		-outform $(FORM) -key $(CAKEY) -out $(CACER)
		
$(CAKEY): $(ORG)
	openssl genpkey -config $(CONFCA) -out $(CAKEY) -outform $(FORM) \
		-algorithm RSA
$(ORG):
	mkdir -p $(ORG) $(ORG)/certs $(ORG)/private
	chmod 700 $(ORG)/private
	cp ORG-CA.cnf $(CONFCA)
	cp ORG-CR.cnf $(CONFCR)
	
clean:
	rm $(CAKEY) $(CACER) $(CACERDER) $(UCER) $(UCSR) $(UCERKEY) $(UCERPFX) $(CONFCA) $(CONFCR)
	rmdir $(ORG)/certs $(ORG)/private
	rmdir $(ORG)
	

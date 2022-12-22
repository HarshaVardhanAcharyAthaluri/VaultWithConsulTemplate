# VaultWithConsulTemplate
Vault + SpringBoot+ SSL+ ConsulTemplate for certificate auto renewal and revoke

# Certificates Automation with Vault and Consul Template
its a quick setup we use UI to configure CA

Get Consul-Template from : https://releases.hashicorp.com/consul-template/
- Enable the PKI Engine in Vault
- Create a Root Certificate
- Configure a PKI Role
- Fetching Certificates

# Start the Vault
`` vault server -dev``

# Enable the PKI Engine
- Vault supports many Secrets Engines and our topic today is PKI so we will enable the PKI Backend from the command line as follows:

`` vault secrets enable pki ``
or via the GUI naviage to http://vault-server:8200 and click on enable new engine and enable the PKI Engine.
![This is an image](https://github.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/blob/main/1.JPG)
- Select PKI Engine
![This is an image](https://github.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/blob/main/2.svg)
- Give the Name
![This is an image](https://github.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/blob/main/3.svg)
- Now Configure Root CA By selecting PKI Engine which we created (pki_root_CA)
![This is an image](https://github.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/blob/main/4.svg)
![This is an image](https://github.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/blob/main/5.svg)
# Configure a Role
- All future requests will target certain Roles. This will be a collection of Roles varies from DB Certs to Web Certs, each with a specific domain. For example, policies will eventually be set based on those Roles, of who is allowed to access which role, and finally how long the Cert should live for “TTL” under each role (5 seconds expiry “TTL” but could be renewed up to 24 hours “Max TTL” ).
![This is an image](https://github.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/blob/main/6.svg)
![This is an image](https://github.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/blob/main/7.svg)
![This is an image](https://github.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/blob/main/8.svg)
![This is an image](https://github.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/blob/main/9.svg)
![This is an image](https://github.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/blob/main/10.svg)
![This is an image](https://github.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/blob/main/11.svg)
![This is an image](https://github.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/blob/main/12.svg)
# Fetching Certificates or Issue the Certificate to test is our Role had that privillages
![This is an image](https://github.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/blob/main/13.svg)
![This is an image](https://github.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/blob/main/14.svg)
![This is an image](https://github.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/blob/main/15.svg)

Now that we have a fully working Role that allows us to fetch certificates, we want to automate the renewal of the certificates. This could be easily handled by schedulers or config management on the host itself by calling the Vault API and deploying a new certificate when the TTL is reached. However, in our case, we will assume that we have Consul Template deployed on the host in order to automate the deployment.

# Consul Template Deployment & Configuration 
You can download the latest release from Consul Template.
https://releases.hashicorp.com/consul-template/
# Configuration
We will use a simple configuration for our Consul Template covering only the Vault integration scope, to create a config.hcl file with the following

``
vault {
  address = "http://localhost:8200"
  token="hvs.1wYTvtf3esDZ5hsQ7uFm5hSf"
  unwrap_token = false
  renew_token = false
}
template {
contents="{{ with secret \"pki_root_CA/issue/role_root_ca\" \"common_name=localhost\" }}{{ .Data.certificate }}{{ end }}"
destination="./localhost.cert"
}
template {
  contents="{{ with secret \"pki_root_CA/issue/role_root_ca\" \"common_name=localhost\" }}{{ .Data.private_key }}{{ end }}"
  destination="./localhost.key"
}
``
# Running Consul Template
`` consul-template -config config.hcl ``

Now notice how the certificate file will be regenerated every 30 sec (default TTL on the Role). You can always check the time validity on the certificate by issuing the following command against the certificate.

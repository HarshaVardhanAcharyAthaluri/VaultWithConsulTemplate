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
<code><img  src="https://raw.githubusercontent.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/master/screenshots/1.JPG"></code><br/>
- Select PKI Engine <br/>
<code><img  src="https://raw.githubusercontent.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/master/screenshots/2.JPG"></code><br/>
- Give the Name <br/>
<code><img  src="https://raw.githubusercontent.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/master/screenshots/3.JPG"></code><br/>
- Now Configure Root CA By selecting PKI Engine which we created (pki_root_CA) <br/>
<code><img  src="https://raw.githubusercontent.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/master/screenshots/4.JPG"></code><br/>
<code><img  src="https://raw.githubusercontent.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/master/screenshots/5.JPG"></code><br/>
<code><img  src="https://raw.githubusercontent.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/master/screenshots/6.JPG"></code><br/>
# Configure a Role
- All future requests will target certain Roles. This will be a collection of Roles varies from DB Certs to Web Certs, each with a specific domain. For example, policies will eventually be set based on those Roles, of who is allowed to access which role, and finally how long the Cert should live for “TTL” under each role (5 seconds expiry “TTL” but could be renewed up to 24 hours “Max TTL” ).<br/>

<code><img  src="https://raw.githubusercontent.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/master/screenshots/7.JPG"></code><br/>
<code><img  src="https://raw.githubusercontent.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/master/screenshots/8.JPG"></code><br/>
<code><img  src="https://raw.githubusercontent.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/master/screenshots/9.JPG"></code><br/>
<code><img  src="https://raw.githubusercontent.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/master/screenshots/10.JPG"></code><br/>
<code><img  src="https://raw.githubusercontent.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/master/screenshots/11.JPG"></code><br/>
<code><img  src="https://raw.githubusercontent.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/master/screenshots/12.JPG"></code><br/>
<code><img src="https://raw.githubusercontent.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/master/screenshots/13.JPG"></code><br/>
# Fetching Certificates or Issue the Certificate to test is our Role had that privillages

<code><img src="https://raw.githubusercontent.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/master/screenshots/14.JPG"></code><br/>
<code><img src="https://raw.githubusercontent.com/HarshaVardhanAcharyAthaluri/VaultWithConsulTemplate/master/screenshots/15.JPG"></code><br/>

Now that we have a fully working Role that allows us to fetch certificates, we want to automate the renewal of the certificates. This could be easily handled by schedulers or config management on the host itself by calling the Vault API and deploying a new certificate when the TTL is reached. However, in our case, we will assume that we have Consul Template deployed on the host in order to automate the deployment.

# Consul Template Deployment & Configuration 
You can download the latest release from Consul Template.
https://releases.hashicorp.com/consul-template/
# Configuration
We will use a simple configuration for our Consul Template covering only the Vault integration scope, to create a config.hcl file with the following

```
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
```
# Running Consul Template
`` consul-template -config config.hcl ``

Now notice how the certificate file will be regenerated every 30 sec (default TTL on the Role). You can always check the time validity on the certificate by issuing the following command against the certificate.

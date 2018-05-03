import requests
import json
import hvac
import sys
import os
client = hvac.Client()
client = hvac.Client(url='http://azc-vault.spacelyspacesprockets.info:8200', token=os.environ['VAULT_TOKEN'])
envDetails = client.read('secret/cluster_details')
vault_fqdn = envDetails['data']['cluster_address']
os.system("export VAULT_ADDR="+vault_fqdn)
vault_url = 'http://' + vault_fqdn + ':8200'
database_url = envDetails['data']['db_address']
vault_license = ""
license_payload = {
    "text": vault_license
}

payload_init = {
        "recovery_shares": 1,
        "recovery_threshold": 1,
        "secret_shares": 1,
        "stored_shares": 1,
        "secret_threshold": 1
    }

mount_payload = {
    "type":"database",
    "config": {
    "plugin": "mysql-database-plugin"
  }
}

database_config_payload = {
  "plugin_name": "mysql-database-plugin",
  "allowed_roles": "read-only",
  "connection_url": "admin:temppass@tcp("+database_url+":3306)/"
}

database_read_creds = {
    "db_name": "mysqldb",
    "creation_statements": "CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%'",
    "default_ttl": "5m",
    "max_ttl": "24h"
}


r = requests.put(vault_url + "/v1/sys/init", data=json.dumps(payload_init))
data = json.loads(r.text)
print r.text
root_toke =  data['root_token']
os.system("export VAULT_TOKEN=" + root_toke)
print "Initializing Vault"
print "Command run:"
print "vault operator init -stored-shares=1 -recovery-shares=1 -recovery-threshold=1 -key-shares=1 -key-threshold=1"
print "Root Token: " + root_toke
print ""
client.write('secret/cluster_token', root_toke=root_toke)
x = raw_input('Don\'t forget to reboot your instances! ')
headers = {'X-Vault-Token': root_toke}
license_r = requests.put(vault_url+"/v1/sys/license",headers=headers, data=license_payload)

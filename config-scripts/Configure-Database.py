import requests
import json
import hvac
import sys
import os
client = hvac.Client()
client = hvac.Client(url='http://azc-vault.spacelyspacesprockets.info:8200', token=os.environ['VAULT_TOKEN'])
envDetails = client.read('secret/cluster_details')
vault_fqdn = envDetails['data']['cluster_address']
vault_url = 'http://' + vault_fqdn + ':8200'
database_url = envDetails['data']['db_address']

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

root_token = client.read('secret/cluster_token')
root_toke = root_token['data']['root_toke']
headers = {'X-Vault-Token': root_toke}

print "Setting up Database Backend: "
print "Command Run: \n"
print "vault secrets enable -path=aws-mysql database"
print ""
mysql_backend_r = requests.post(vault_url+'/v1/sys/mounts/aws-mysql', headers=headers, data=json.dumps(mount_payload))
raw_input("Next...")
print ""
print "Configuring Database Connectivity: "
print "Command Run: \n"
print "vault write aws-mysql/config/mysqldb \\\n plugin_name=mysql-database-plugin \\\n connection_url=\"{{username}}:{{password}}@tcp(127.0.0.1:3306)/\" \\\n allowed_roles=\"my-role\" \\\n username=\"root\" \\\n password=\"mysql\""
print ""
mysql_config_r = requests.post(vault_url+'/v1/aws-mysql/config/mysqldb', headers=headers, data=json.dumps(database_config_payload))
raw_input("Next...")
print mysql_config_r.text
print ""
print "Configuring Database Creation Statement: "
print "Command Run: \n"
print "vault write aws-mysql/roles/read-only \\\n db_name=my-mysql-database \\\n creation_statements=\"CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';\" \\\n default_ttl=\"1h\" \\\n max_ttl=\"24h\"\n \n "
mysql_create_statement = requests.post(vault_url+'/v1/aws-mysql/roles/read-only', headers=headers, data=json.dumps(database_read_creds))
raw_input("Database Config Complete")

print "\n\nexport VAULT_ADDR=" + vault_url
print "export VAULT_TOKEN=" + root_token['data']['root_toke'] + "\n\n"

print "\nTo create new credentials: "
print "vault read aws-mysql/creds/read-only"
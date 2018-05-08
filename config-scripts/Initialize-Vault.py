import requests
import json
import hvac
import sys
import os
import argparse
import time

parser = argparse.ArgumentParser()
parser.add_argument("-fqdn", required=True, help="FQDN of Vault Server, e.g. vault.server.address", type=str)
args = parser.parse_args()


client = hvac.Client()
#client = hvac.Client(url='http://azc-vault.spacelyspacesprockets.info:8200', token=os.environ['VAULT_TOKEN'])
#envDetails = client.read('secret/cluster_details')
vault_fqdn = args.fqdn
os.system("export VAULT_ADDR="+vault_fqdn)
vault_url = 'http://' + vault_fqdn + ':8200'
vault_license = "01MV4UU43BK5HGYYTOJZWFQMTMNNEWU33JLFKFM3KNI5JGYWKXKV2FSMSVGBGVGMLMLJDU252MKRCXSTTKIV2FSVDMNBHDESLZLJDUSNCNPJKXSSLJO5UVSM2WPJSEOOLULJMEUZTBK5IWST3JJF4FUR2GNVHG2SLXJZBTA6SOGJITITCUIUYU26SRORGUIZZRLJUTC3CPKRTTETL2KU2U2VCONBMXUSLJJRBUU4DCNZHDAWKXPBZVSWCSOBRDENLGMFLVC2KPNFEXCSLJO5UWCWCOPJSFOVTGMRDWY5C2KNETMSLKJF3U2VDHORGUIULUJVKGQVKNKRVTMTKUMM3E26SZOVGXUZ3ZJV5E2MSOKRGTAV3JJFZUS3SOGBMVQSRQLAZVE4DCK5KWST3JJF4U2RCFGRGFIQJQJRKEKNCWIRATCT3KIF3U62SBO5LWSSLTJFWVMNDDI5WHSWKYKJYGEMRVMZSEO3DULJJUSNSJNJEXOTKUNN2E2RCRORGVI3CVJVCFCNSOKRVTMTSUNN2U6VDLGVLWSSLTJFXEE6LCGJJDCWJTKFUU62KKGJMVQVTTMRBUS42JNVNHGWKXMR5ES2TQG5EW4QTILEZHI2C2GJKWST3JJJ3WG3KWORQVQVTUJFXDCOJOOZQXK3DUHJ3DCOSZKNXSW6KWGJAUE6KPMZWDA6JTIFUXAM3GJNLGY5DZNJZFU22KJFMHUR32GRMTO2DINNRXEU3SONXUGQTFPFYVURDCOJUTCSCJNJEXA42FPJKESRTLGZQTI5BYNVAUQRKFIRNHGQTHHU6Q"
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
#client.write('secret/east_cluster_token', root_toke=root_toke)
x = raw_input('Reboot your Vault Servers - Hit Enter after you\'ve done so... ')
time.sleep(60)
client = hvac.Client(url='http://'+vault_fqdn+':8200', token=root_toke)
value = client.read('sys/license')
print value
x = raw_input('Ready to Apply License?')
client.write('sys/license',text=vault_license)
value = client.read('sys/license')
print value

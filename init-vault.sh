#!/usr/bin/env bash

instance_id="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
public_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
new_hostname="vault-$${instance_id}"

# stop consul and nomad so they can be configured correctly
systemctl stop vault
systemctl stop consul

# clear the consul and nomad data directory ready for a fresh start
rm -rf /opt/consul/data/*
rm -rf /opt/vault/data/*

# set the hostname (before starting consul and nomad)
hostnamectl set-hostname "$${new_hostname}"
echo "127.0.0.1 $(hostname)" | sudo tee --append /etc/hosts

#Add localhost to /etc/resolv.conf to resolve dns
sudo sed -i '1s/^/nameserver 127.0.0.1\n/' /etc/resolv.conf

# seeing failed nodes listed  in consul members with their solo config
# try a 2 min sleep to see if it helps with all instances wiping data
# in a similar time window
sleep 60

cat << EOF > /etc/systemd/system/vault.service
[Unit]
Description=Vault Agent
Requires=consul-online.target
After=consul-online.target
[Service]
Restart=on-failure
PermissionsStartOnly=true
ExecStartPre=/sbin/setcap 'cap_ipc_lock=+ep' /usr/local/bin/vault
ExecStart=/usr/local/bin/vault server -config /etc/vault.d
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM
User=vault
Group=vault
[Install]
WantedBy=multi-user.target
EOF

sudo chmod 0664 /etc/systemd/system/vault*

systemctl daemon-reload

rm -f /etc/consul.d/consul-default.json
rm -f /etc/consul.d/consul-server.json
rm -f /etc/vault.d/

cat <<EOF >> /etc/consul.d/consul.json
{
  "datacenter": "${local_region}",
  "server": false,
  "leave_on_terminate": true,
  "advertise_addr": "$${local_ipv4}",
  "data_dir": "/opt/consul/data",
  "client_addr": "0.0.0.0",
  "log_level": "INFO",
  "retry_join": ["provider=aws tag_key=environment_name tag_value=${environment_name}"]
}
EOF
chown consul:consul /etc/consul.d/consul.json
# start consul once it is configured correctly
systemctl start consul

# currently no additional configuration required for vault
# todo: support TLS in hashistack and pass in {vault_use_tls} once available
# start vault once it is configured correctly
systemctl start vault

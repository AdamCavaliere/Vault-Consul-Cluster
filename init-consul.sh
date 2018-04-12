#!/usr/bin/env bash

instance_id="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
public_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
new_hostname="consul-$${instance_id}"

# stop consul and nomad so they can be configured correctly

systemctl stop consul
# clear the consul and nomad data directory ready for a fresh start
rm -rf /opt/consul/data/*

# set the hostname (before starting consul and nomad)
hostnamectl set-hostname "$${new_hostname}"
echo "127.0.0.1 $(hostname)" | sudo tee --append /etc/hosts

#Add localhost to /etc/resolv.conf to resolve dns
sudo sed -i '1s/^/nameserver 127.0.0.1\n/' /etc/resolv.conf

# seeing failed nodes listed  in consul members with their solo config
# try a 2 min sleep to see if it helps with all instances wiping data
# in a similar time window
sleep 120


sudo chmod 0664 /etc/systemd/system/consul*

systemctl daemon-reload

rm -f /etc/consul.d/consul-default.json
rm -f /etc/consul.d/consul-server.json

{


  "datacenter": "${local_region}",
  "server": true,
  "bootstrap_expect": ${cluster_size},
  "leave_on_terminate": true,
  "advertise_addr": "$${local_ipv4}",
  "data_dir": "/opt/consul/data",
  "client_addr": "0.0.0.0",
  "log_level": "INFO",
  "ui": true,
  "retry_join": ["provider=aws tag_key=environment_name tag_value=${environment_name}"]

}

cat <<EOF >> /etc/consul.d/consul.json
{
  "raft_protocol": 3,
  "autopilot": { "cleanup_dead_servers": true },
  "datacenter": "${local_region}",
  "server": true,
  "bootstrap_expect": ${cluster_size},
  "leave_on_terminate": true,
  "advertise_addr": "$${local_ipv4}",
  "data_dir": "/opt/consul/data",
  "client_addr": "0.0.0.0",
  "log_level": "INFO",
  "ui": true,
  "retry_join": ["provider=aws tag_key=environment_name tag_value=${environment_name}"]
}
EOF
chown consul:consul /etc/consul.d/consul.json
# start consul once it is configured correctly
systemctl start consul

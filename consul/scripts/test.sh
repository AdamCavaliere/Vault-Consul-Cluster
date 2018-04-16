VAULT_BUILD=$(date '+%Y%m%d%H%M%S')
cat <<EOF | sudo tee testfile
{
"node_meta": {"cluster_version": "$VAULT_BUILD"}
}
EOF

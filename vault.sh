#!/bin/bash

#vault output
VO='init_output_vault.txt'

# Initialize Vault (only needed the first time you set up Vault)
#sudo vault operator init > $VO

# Extract the root token and unseal keys (for demo purposes; do not do this in production)
ROOT_TOKEN=$(grep 'Root Token:' $VO | awk '{print substr($0, index($0,$3))}')
UNSEAL_KEY1=$(grep 'Unseal Key 1:' $VO | awk '{print substr($0, index($0,$4))}')
UNSEAL_KEY2=$(grep 'Unseal Key 2:' $VO | awk '{print substr($0, index($0,$4))}')
UNSEAL_KEY3=$(grep 'Unseal Key 3:' $VO | awk '{print substr($0, index($0,$4))}')

echo $ROOT_TOKEN
echo $UNSEAL_KEY1

# Unseal Vault (this may need to be done multiple times depending on your threshold setting)
vault operator unseal $UNSEAL_KEY1
vault operator unseal $UNSEAL_KEY2
vault operator unseal $UNSEAL_KEY3

# Log in to Vault
vault login $ROOT_TOKEN

# Enable the database secrets engine
vault secrets enable database

# Configure Vault with the PostgreSQL plugin and connection info
vault write database/config/ogrego \
    plugin_name=postgresql-database-plugin \
    connection_url="postgresql://{{username}}:{{password}}@localhost:5432/ogrego?sslmode=allow"
    allowed_roles="gocsvdb" \
    username="vaultuser" \
    password="AQUb7HBGJVex6vg"

# Create a role with SQL statements for creating and revoking users
vault write database/roles/gocsvdb \
    db_name=ogrego \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO \"{{name}}\" ; GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO \"{{name}}\" ; ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO \"{{name}}\" ; ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO \"{{name}}\" ;" \
    revocation_statements="ALTER ROLE \"{{name}}\" NOLOGIN;REASSIGN OWNED BY \"{{name}}\" TO ogrego; DROP OWNED BY \"{{name}}\"; DROP ROLE IF EXISTS \"{{name}}\";"
    default_ttl="1h" \
    max_ttl="24h"

# Clean up (for demo purposes; do not do this in production)
#rm vault_init_output.txt


# read own kv2 secrets
path "secret/data/auth_approle_role_bff" {
  capabilities = [ "read"]
}
path "secret/data/auth_approle_role_bff/*" {
  capabilities = [ "read" ]
}

# read own kv1 secrets
path "env/auth_approle_role_bff" {
  capabilities = [ "read"]
}
path "env/auth_approle_role_bff/*" {
  capabilities = [ "read" ]
}

# get readonly/readwrite postgres secrets
path "database/creds/read*" {
  capabilities = ["read"]
}

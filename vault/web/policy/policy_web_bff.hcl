path "secret/data/auth_approle_role_web_bff" {
  capabilities = [ "read"]
}
path "secret/data/auth_approle_role_web_bff/*" {
  capabilities = [ "read" ]
}
path "env/auth_approle_role_web_bff" {
  capabilities = [ "read"]
}
path "env/auth_approle_role_web_bff/*" {
  capabilities = [ "read" ]
}
path "database/creds/read*" {
  capabilities = ["read"]
}

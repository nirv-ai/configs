# read own secrets
path "secret/data/bff" {
  capabilities = [ "read"]
}
path "secret/data/bff/*" {
  capabilities = [ "read" ]
}

# get readonly/readwrite postgres secrets
path "database/creds/read*" {
  capabilities = ["read"]
}

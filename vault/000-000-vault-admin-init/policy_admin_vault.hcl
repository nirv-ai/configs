# kv-v2
path "secret/*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo"]
}

# kv-v1
path "env/*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo"]
}

path "sys/*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo" ]
}

path "auth/*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo" ]
}

path "database/*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo" ]
}

path "pki*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo" ]
}

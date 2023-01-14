
path "secret/*" {
  capabilities = ["create", "read", "update", "delete", "list", "patch", "sudo"]
}

path "env/*" {
  capabilities = ["create", "read", "update", "delete", "list", "patch", "sudo"]
}

path "sys/*" {
  capabilities = ["create", "read", "update", "delete", "list", "patch", "sudo"]
}

path "auth/*" {
  capabilities = ["create", "read", "update", "delete", "list", "patch", "sudo"]
}

path "auth/token/root" {
  capabilities = ["deny"]
}

path "database/*" {
  capabilities = ["create", "read", "update", "delete", "list", "patch", "sudo"]
}

path "pki*" {
  capabilities = ["create", "read", "update", "delete", "list", "patch", "sudo"]
}

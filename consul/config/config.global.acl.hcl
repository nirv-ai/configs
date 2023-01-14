acl {
  default_policy = "deny"
  down_policy = "async-cache"
  policy_ttl = "1h"
  role_ttl = "1h"
  token_ttl = "1h"
  enable_token_persistence = false # immutable everything
  enable_token_replication = false # existing global tokens in secondary datacenters will be lost
  enabled = true

  # TODO: this is going to help the bootstrapping process
  // tokens = {}
}

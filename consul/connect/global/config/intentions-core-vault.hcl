Kind = "service-intentions"
Name = "core-vault"
Sources = [
  {
    Name   = "core-proxy"
    Action = "allow"
  },
  {
    Name   = "web-bff"
    Action = "allow"
  }
]

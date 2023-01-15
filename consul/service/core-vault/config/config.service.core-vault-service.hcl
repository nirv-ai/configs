# always use services so you can declare multiple instances
# start index at 1 as thats what docker uses
services {
  enable_tag_override = false
  id                  = "core-vault-1"
  name                = "core-vault"
  port                = 8200
  tags                = ["primary", "mesh"]


  check {
    id         = "check-self"
    name       = "core-vault"
    service_id = "core-vault-1"
    args = [
      "/bin/sh",
      "-c",
      "curl https://dev.nirv.ai:8200/v1/sys/health || exit $?"
    ]
    interval = "5s"
    timeout  = "1s"
  }

  connect {
    sidecar_service {
      port = 21000 # you need to manually start envoy, see bootstrap.sh
    }
  }

  meta {
    app = "core-vault"
  }
}

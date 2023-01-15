# always use services so you can declare multiple instances
# start index at 1 as thats what docker uses
services {
  name = "core-vault"
  id   = "core-vault-1"
  tags = ["primary", "mesh"]
  port = 8200

  connect {
    sidecar_service {
      port = 7979 # you need to manually start envoy, see bootstrap.sh
    }
  }

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
}

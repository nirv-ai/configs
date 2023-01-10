service {
  name = "core-proxy"
  id = "core-proxy-1"
  tags = ["v1", "mesh"]
  port = 8404

  connect {
    sidecar_service {
      proxy {
        upstreams = [
          {
            destination_name = "core-vault"
            local_bind_port = 8300
          }
          // {
          //   destination_name = "web-postgres"
          //   local_bind_port = 5432
          // },
          // {
          //   destination_name = "web-bff"
          //   local_bind_port = 3001
          // },
        ]
      }
    }
  }

  check {
    id =  "check-core-proxy",
    name = "Service core-proxy status check",
    service_id = "core-proxy-1",
    tcp  = "localhost:8404/health",
    interval = "1s",
    timeout = "1s"
  }
}

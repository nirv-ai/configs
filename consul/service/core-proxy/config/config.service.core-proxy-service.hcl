# always use services so you can declare multiple instances
# start index at 1 as thats what docker uses
services {
  enable_tag_override = false
  id                  = "core-proxy-1"
  name                = "core-proxy"
  port                = 8080
  tags                = ["primary", "mesh"]
  kind                = "connect-proxy"

  checks = [
    {
      id         = "check-self-edge",
      name       = "core-proxy",
      service_id = "core-proxy-1",
      tcp        = "localhost:8080"
      interval   = "5s",
      timeout    = "1s"
    },
    {
      id         = "check-self-stats",
      name       = "core-proxy",
      service_id = "core-proxy-1",
      interval   = "30s",
      timeout    = "1s",
      args = [
        "/bin/sh",
        "-c",
        "curl -kf -H 'user-agent: just stopping by and wanted to say hello'  https://localhost:8404/health || exit $?"
      ]
    }
  ]

  connect {
    sidecar_service {
      port = 21000 # you need to manually start envoy, see bootstrap.sh
      proxy {
        destination_service_id   = "core-proxy-1"
        destination_service_name = "core-proxy"
        local_service_address    = "127.0.0.1"
        local_service_port       = 8080
        mode                     = "direct"

        config {}
        expose {
          checks = true
        }
        upstreams = [
          {
            destination_name = "core-vault"
            destination_type = "service"
            local_bind_port  = 8200

            config {}
            mesh_gateway {
              mode = ""
            }
          }
        ]

      }
    }
  }

  meta {
    app = "core-proxy"
  }
}

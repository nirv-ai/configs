# @see https://developer.hashicorp.com/consul/docs/discovery/services
# dont set services.{kind|proxy}: we only support sidecar services
# services: can declare multiple instances
services {
  enable_tag_override = false
  id                  = "core-proxy-1" # docker starts at 1
  name                = "core-proxy"
  port                = 8080
  tags                = ["primary", "mesh"]

  # might as well always use checks
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



  # @see https://developer.hashicorp.com/consul/docs/connect/registration/sidecar-service
  # you need to manually start envoy, see bootstrap.sh
  connect {
    # accepts any* field in a servcie definition field
    sidecar_service {
      port = 21000
      proxy {
        expose {
          checks = true
          paths = [
            { # edge
              path            = "/"
              local_path_port = 8080
              listener_port   = 28080
            },
            { # stats
              path            = "/stats"
              local_path_port = 8404
              listener_port   = 28404
            },
            { # expose vault via haproxy
              path            = "/"
              local_path_port = 8200
              listener_port   = 28200
            }
          ]
        }
        upstreams = [
          {
            destination_name = "core-vault"
            destination_type = "service"
            local_bind_port  = 8200

            config = {
              handshake_timeout_ms = 1000
            }
            mesh_gateway = {
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

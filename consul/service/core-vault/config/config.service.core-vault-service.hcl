# @see https://developer.hashicorp.com/consul/docs/discovery/services
# dont set services.{kind|proxy}: we only support sidecar services
# services: can declare multiple instances
services {
  enable_tag_override = false
  id                  = "core-vault-1" # docker starts at 1
  name                = "core-vault"
  port                = 8200
  tags                = ["primary", "mesh"]

  # might as well always use checks
  checks = [
    {
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
  ]

  # @see https://developer.hashicorp.com/consul/docs/connect/registration/sidecar-service
  # you need to manually start envoy, see bootstrap.sh
  connect {
    sidecar_service {
      # accepts any* field in a servcie definition field
      port = 21000

      proxy {
        config = {}

        expose {
          checks = true

          paths = [
            {
              path            = "/"
              local_path_port = 8200
              listener_port   = 28200
            }
          ]
        }
      }
    }
  }

  meta {
    app = "core-vault"
  }
}

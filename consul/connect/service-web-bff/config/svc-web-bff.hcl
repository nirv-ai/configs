service {
  name = "web-bff"
  id = "web-bff-1"
  tags = ["v1"]
  port = 3001

  connect {
    sidecar_service {
      proxy {
        upstreams = [
          {
            destination_name = "web-postgres"
            local_bind_port = 5432
          },
          {
            destination_name = "core-vault"
            local_bind_port = 8300
          }
        ]
      }
    }
  }
  checks = [
    {
      id =  "check-self",
      name = "Payments status check",
      service_id = "web-bff-1",
      tcp  = "web-bff${FQDN_SUFFIX}:3001",
      interval = "1s",
      timeout = "1s"
    },
    // {
    //   id =  "check-proxy-self",
    //   name = "Payments status check",
    //   service_id = "web-bff-1",
    //   tcp  = "web-bff${FQDN_SUFFIX}:3001",
    //   interval = "1s",
    //   timeout = "1s"
    // },
  ]
}

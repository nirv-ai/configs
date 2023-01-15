# always use services so you can declare multiple instances
# start index at 1 as thats what docker uses
services {
  name = "core-proxy"
  id   = "core-proxy-1"
  tags = ["primary", "mesh"]
  port = 8080

  connect {
    sidecar_service {
      port = 7979 # you need to manually start envoy, see bootstrap.sh
    }
  }

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
}

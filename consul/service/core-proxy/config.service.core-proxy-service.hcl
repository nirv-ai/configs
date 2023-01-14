service {
  name = "core-proxy"
  id = "core-proxy-1"
  tags = ["v1", "mesh"]
  port = 8080

  connect {
    sidecar_service {
      port = 7979 # you need to manually start envoy, see bootstrap.sh
    }
  }

  check {
    id =  "check-self",
    name = "core-proxy",
    service_id = "core-proxy-1",
    args = [
      "/bin/sh",
      "-c",
      "curl -kf -H 'user-agent: just stopping by and wanted to say hello'  https://localhost:8404/health || exit $?"
    ]
    interval = "5s",
    timeout = "1s"
  }
}

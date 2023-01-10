service {
  name = "core-vault"
  id = "core-vault-1"
  tags = ["v1", "mesh"]
  port = 8300

  connect {
    sidecar_service {}
  }

  check {
    id =  "check-self",
    name = "Service core-vault status check",
    service_id = "core-vault-1",
    tcp  = "localhost:8404/health", # todo: this should be /v1/sys/health endpoint
    interval = "1s",
    timeout = "1s"
  }
}

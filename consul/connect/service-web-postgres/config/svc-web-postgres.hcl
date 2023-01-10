service {
  name = "web-postgres"
  id = "web-postgres-1"
  tags = ["v1", "mesh"]
  port = 5432

  connect {
    sidecar_service {}
  }

  check {
    id =  "check-web-postgres",
    name = "Service web-postgres status check",
    service_id = "web-postgres-1",
    tcp  = "localhost:5432",
    interval = "1s",
    timeout = "1s"
  }
}

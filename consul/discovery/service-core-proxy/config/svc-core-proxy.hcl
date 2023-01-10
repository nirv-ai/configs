service {
  name = "web-proxy"
  id = "web-proxy-1"
  tags = ["v1"]
  port = 5432

  check {
    id =  "check-self",
    name = "service web-proxy status check",
    service_id = "web-proxy-1",
    tcp  = "localhost:8404/health",
    interval = "1s",
    timeout = "1s"
  }
}

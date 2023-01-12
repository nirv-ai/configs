service {
  name = "core-vault"
  id = "core-vault-1"
  tags = ["v1"]
  port = 8300

  // check {
  //   id =  "check-self",
  //   name = "service core-proxy status check",
  //   service_id = "core-proxy-1",
  //   tcp  = "localhost:8404/health",
  //   interval = "1s",
  //   timeout = "1s"
  // }
}

# internal
variable "NOMAD_DC" {
  type    = string
  default = "us_east"
}
variable "NOMAD_REGION" {
  type    = string
  default = "global"
}
variable "REG_HOST_PORT" {
  type    = string
  default = "5000"
}
# from env_file
variable "name" {
  type = string
}
variable "services" {
  type = object({
    core-consul = object({
      domainname = string
      entrypoint     = list(string)
      image          = string
      extra_hosts = list(string)

      environment = object({
        CA_CERT = string
        CONSUL_ALT_DOMAIN = string
        CONSUL_CLIENT_CERT = string
        CONSUL_CLIENT_KEY = string
        CONSUL_CONFIG_DIR = string
        CONSUL_DNS_TOKEN = string # TODO: dont reuse
        CONSUL_ENVOY_PORT = string
        CONSUL_FQDN_ADDR = string
        CONSUL_GID = string # TODO: dont reuse
        CONSUL_HTTP_ADDR = string
        CONSUL_HTTP_SSL = string
        CONSUL_HTTP_TOKEN = string # TODO: dont reuse
        CONSUL_NODE_PREFIX = string
        CONSUL_PORT_CUNT = string
        CONSUL_PORT_DNS = string
        CONSUL_PORT_SERF_LAN = string
        CONSUL_PORT_SERF_WAN = string
        CONSUL_TLS_SERVER_NAME = string
        CONSUL_UID = string # TODO dont reuse
        ENVOY_GID = string # TODO: dont reuse
        ENVOY_UID = string # TODO: dont reuse
        MESH_HOSTNAME = string
        MESH_SERVER_HOSTNAME = string
        PROJECT_HOSTNAME = string
      })
      ports = list(object({
        mode      = string
        protocol  = string
        // published = string
        target    = string
      }))
      volumes = list(object({
        type   = string
        source = string
        target = string
      }))
    })

    // core-vault = object({
    //   cap_add        = list(string)
    //   entrypoint     = list(string)
    //   image          = string
    //   environment = object({
    //     PROJECT_HOSTNAME = string
    //     PROJECT_NAME     = string
    //   })
    //   ports = list(object({
    //     mode      = string
    //     published = string
    //     protocol  = string
    //     target    = number
    //   }))
    //   volumes = list(object({
    //     type   = string
    //     source = string
    //     target = string
    //     bind = object({
    //       create_host_path = bool
    //     })
    //   }))
    // })

    // core-proxy = object({
    //   entrypoint     = list(string)
    //   image          = string
    //   environment = object({
    //     PROJECT_HOSTNAME = string
    //     PROJECT_NAME     = string
    //   })
    //   ports = list(object({
    //     mode      = string
    //     protocol  = string
    //     published = string
    //     target    = string
    //   }))
    //   volumes = list(object({
    //     type   = string
    //     source = string
    //     target = string
    //   }))
    // })
  })
}
variable "networks" {
  type = map(map(string))
}
variable "secrets" {
  type = object({
    mesh_ca = object({
      name = string
      file = string
    })
    mesh_core_proxy = object({
      name = string
      file = string
    })
    mesh_core_proxy_privkey = object({
      name = string
      file = string
    })
  })
}
variable "x-mesh-ca" {
  type = object({
    target = string
  })
}
variable "x-mesh-core-proxy" {
  type = object({
    target = string
  })
}
variable "x-mesh-core-proxy-privkey" {
  type = object({
    target = string
  })
}
variable "x-mesh-core-vault" {
  type = object({
    target = string
  })
}
variable "x-mesh-core-vault-privkey" {
  type = object({
    target = string
  })
}
variable "x-mesh-server" {
  type = object({
    target = string
  })
}
variable "x-mesh-server-privkey" {
  type = object({
    target = string
  })
}
variable "x-nirvai-cert" {
  type = object({
    target = string
  })
}
variable "x-nirvai-chain" {
  type = object({
    target = string
  })
}
variable "x-nirvai-combined" {
  type = object({
    target = string
  })
}
variable "x-nirvai-fullchain" {
  type = object({
    target = string
  })
}
variable "x-nirvai-privkey" {
  type = object({
    target = string
  })
}
# ignored variables
variable "x-deploy" {}
variable "x-service-defaults" {}
variable "x-service-healthcheck" {}

locals {
  # consul_group
  consul    = var.services.core-consul
  consulenv = var.services.core-consul.environment

  # proxy_group
  // proxy    = var.services.core-proxy
  // proxyenv = var.services.core-proxy.environment

  # vault_group
  // vault    = var.services.core-vault
  // vaultenv = var.services.core-vault.environment
}

job "core" {
  datacenters = ["${var.NOMAD_DC}"]
  region      = "${var.NOMAD_REGION}"
  type        = "service"
  priority = 100

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  meta {
    run_uuid = "${uuidv4()}" # turn off in prod
    env = "validation" # maybe get this from ${env[NOMAD_ENV]} but needs to be setup
  }

  # temp disable until we get this shiz figured out
  reschedule {
    attempts = 0
    unlimited = false
  }

  group "consul" {
    count = 1

    network {
      mode     = "bridge"
      port "consul_ui" {
        to = "${local.consul.ports[0].target}"
      }
    }

    restart {
      attempts = 0
      mode = "fail"
    }

    scaling {
      enabled = true
      min = 1
      max = 1
    }

    service {
      provider = "nomad"
    }

    task "core-consul" {
      driver = "docker"
      leader = true
      user = "root" # su-exec: must be run as root, drops privs to docker USER

      # @see https://developer.hashicorp.com/nomad/docs/drivers/docker
      config {
        healthchecks {
          disable = true
        }

        auth_soft_fail     = true # dont fail on auth errors
        force_pull         = true
        image              = "${local.consul.image}"
        image_pull_timeout = "10m"
        ports              = ["consul_ui"]
        init = true

        mount {
          type = "bind"
          target = "${local.consul.volumes[0].target}"
          source = "${local.consul.volumes[0].source}"
          readonly = false
          bind_options {
            propagation = "rshared"
          }
        }
        mount {
          type = "bind"
          target = "${local.consul.volumes[1].target}"
          source = "${local.consul.volumes[1].source}"
          readonly = false
          bind_options {
            propagation = "rshared"
          }
        }
        mount {
          type = "bind"
          target = "${local.consul.volumes[2].target}"
          source = "${local.consul.volumes[2].source}"
          readonly = true
        }
        mount {
          type = "bind"
          target = "/run/secrets/${var.x-mesh-ca.target}"
          source = "${var.secrets.mesh_ca.file}"
        }
        mount {
          type = "bind"
          target = "/run/secrets/${var.x-mesh-core-proxy.target}"
          source = "${var.secrets.mesh_core_proxy.file}"
        }
        mount {
          type = "bind"
          target = "/run/secrets/${var.x-mesh-core-proxy-privkey.target}"
          source = "${var.secrets.mesh_core_proxy_privkey.file}"
        }

        // volumes = [
        //   "${local.consul.volumes[0].source}:${local.consul.volumes[0].target}",
        //   "${local.consul.volumes[1].source}:${local.consul.volumes[1].target}",
        //   "${local.consul.volumes[2].source}:${local.consul.volumes[2].target}"
        // ]
      }

      env {
        CA_CERT = "${local.consulenv.CA_CERT}"
        CONSUL_ALT_DOMAIN = "${local.consulenv.CONSUL_ALT_DOMAIN}"
        CONSUL_CLIENT_CERT = "${local.consulenv.CONSUL_CLIENT_CERT}"
        CONSUL_CLIENT_KEY = "${local.consulenv.CONSUL_CLIENT_KEY}"
        CONSUL_CONFIG_DIR = "${local.consulenv.CONSUL_CONFIG_DIR}"
        CONSUL_DNS_TOKEN = "${local.consulenv.CONSUL_DNS_TOKEN}" # TODO: dont reuse
        CONSUL_ENVOY_PORT = "${local.consulenv.CONSUL_ENVOY_PORT}"
        CONSUL_FQDN_ADDR = "${local.consulenv.CONSUL_FQDN_ADDR}"
        CONSUL_GID = "${local.consulenv.CONSUL_GID}" # TODO: dont reuse
        CONSUL_HTTP_ADDR = "${local.consulenv.CONSUL_HTTP_ADDR}"
        CONSUL_HTTP_SSL = "${local.consulenv.CONSUL_HTTP_SSL}"
        CONSUL_HTTP_TOKEN = "${local.consulenv.CONSUL_HTTP_TOKEN}" # TODO: dont reuse
        CONSUL_NODE_PREFIX = "${local.consulenv.CONSUL_NODE_PREFIX}"
        CONSUL_PORT_CUNT = "${local.consulenv.CONSUL_PORT_CUNT}"
        CONSUL_PORT_DNS = "${local.consulenv.CONSUL_PORT_DNS}"
        CONSUL_PORT_SERF_LAN = "${local.consulenv.CONSUL_PORT_SERF_LAN}"
        CONSUL_PORT_SERF_WAN = "${local.consulenv.CONSUL_PORT_SERF_WAN}"
        CONSUL_TLS_SERVER_NAME = "${local.consulenv.CONSUL_TLS_SERVER_NAME}"
        CONSUL_UID = "${local.consulenv.CONSUL_UID}" # TODO dont reuse
        ENVOY_GID = "${local.consulenv.ENVOY_GID}" # TODO: dont reuse
        ENVOY_UID = "${local.consulenv.ENVOY_UID}" # TODO: dont reuse
        MESH_HOSTNAME = "${local.consulenv.MESH_HOSTNAME}"
        MESH_SERVER_HOSTNAME = "${local.consulenv.MESH_SERVER_HOSTNAME}"
        PROJECT_HOSTNAME = "${local.consulenv.PROJECT_HOSTNAME}"
      }

      # max 30mb (3 + 3 * 5mb)
      logs {
        max_files     = 3
        max_file_size = 5
      }

      resources {
        memory = 256 # MB
        cpu = 500
      }
    }
  }

  // group "proxy_group" {
  //   count = 1
  //   restart {
  //     attempts = 1
  //   }

  //   network {
  //     mode     = "overlay"
  //     // hostname = "${local.proxy.hostname}"

  //     port "edge" {
  //       # host port set as: NOMAD_HOST_PORT_edge
  //       to = "${local.proxy.ports[0].target}"
  //     }
  //     port "vault" {
  //       # host port set as: NOMAD_HOST_PORT_vault
  //       to = "${local.proxy.ports[1].target}"
  //     }
  //     port "stats" {
  //       # host port set as: NOMAD_HOST_PORT_stats
  //       to = "${local.proxy.ports[2].target}"
  //     }
  //   }

  //   task "proxy_task" {
  //     driver = "docker"

  //     config {
  //       healthchecks {
  //         disable = true
  //       }
  //       auth_soft_fail     = true # dont fail on auth errors
  //       entrypoint         = "${local.proxy.entrypoint}"
  //       force_pull         = true
  //       image              = "${local.proxyenv.PROJECT_HOSTNAME}:${var.REG_HOST_PORT}/${local.proxy.image}"
  //       image_pull_timeout = "10m"
  //       ports              = ["edge", "vault", "stats"]

  //       volumes = [
  //         "${local.proxy.volumes[0].source}:${local.proxy.volumes[0].target}",
  //         "${local.proxy.volumes[1].source}:${local.proxy.volumes[1].target}",
  //         "${local.proxy.volumes[2].source}:${local.proxy.volumes[2].target}"
  //       ]
  //     }

  //     env {
  //       PROJECT_HOSTNAME = "${local.proxyenv.PROJECT_HOSTNAME}"
  //       PROJECT_NAME     = "${local.proxyenv.PROJECT_NAME}"
  //     }
  //   }
  // }

  // group "vault_group" {
  //   count = 1
  //   restart {
  //     attempts = 1
  //   }

  //   network {
  //     mode     = "overlay"
  //     // hostname = "${local.vault.hostname}"
  //     port "vault" {
  //       # host port set as: NOMAD_HOST_PORT_vault
  //       to = "${local.vault.ports[0].target}"
  //     }
  //   }

  //   task "vault_task" {
  //     driver = "docker"

  //     config {
  //       healthchecks {
  //         disable = true
  //       }
  //       auth_soft_fail     = true # dont fail on auth errors
  //       entrypoint         = "${local.vault.entrypoint}"
  //       force_pull         = true
  //       image              = "${local.vaultenv.PROJECT_HOSTNAME}:${var.REG_HOST_PORT}/${local.vault.image}"
  //       image_pull_timeout = "10m"
  //       ports              = ["vault"]

  //       cap_add = [
  //         "${local.vault.cap_add[0]}"
  //       ]


  //       volumes = [
  //         "${local.vault.volumes[0].source}:${local.vault.volumes[0].target}",
  //         "${local.vault.volumes[1].source}:${local.vault.volumes[1].target}",
  //         "${local.vault.volumes[2].source}:${local.vault.volumes[2].target}"
  //       ]
  //     }

  //     env {
  //       // VAULT_ADDR = "https://$PROJECT_HOSTNAME:${NOMAD_PORT_vault}"
  //       PROJECT_HOSTNAME = "${local.vaultenv.PROJECT_HOSTNAME}"
  //       PROJECT_NAME     = "${local.vaultenv.PROJECT_NAME}"
  //     }
  //   }
  // }
}

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
  type = map(object({
      name = string
      file = string
    })
  )
}
# ignored variables
variable "x-deploy" {}
variable "x-mesh-ca" {}
variable "x-mesh-core-proxy" {}
variable "x-mesh-core-proxy-privkey" {}
variable "x-mesh-core-vault" {}
variable "x-mesh-core-vault-privkey" {}
variable "x-mesh-server" {}
variable "x-mesh-server-privkey" {}
variable "x-nirvai-cert" {}
variable "x-nirvai-chain" {}
variable "x-nirvai-combined" {}
variable "x-nirvai-fullchain" {}
variable "x-nirvai-privkey" {}
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

  meta {
    run_uuid = "${uuidv4()}" # turn off in prod
  }

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "consul_group" {
    count = 1
    restart {
      attempts = 1
    }

    network {
      mode     = "bridge"
      port "postgres" {
        # host port set as: NOMAD_HOST_PORT_postgres
        to = "${local.consul.ports[0].target}"
      }
    }

    # TODO: still receiving permission errors
    // volume "dev_core-postgres" {
    //   type      = "host"
    //   source    = "dev_core-postgres"
    //   read_only = false
    // }

    task "consul_task" {
      driver = "docker"

      config {
        healthchecks {
          disable = true
        }
        auth_soft_fail     = true # dont fail on auth errors
        force_pull         = true
        image              = "${local.consulenv.PROJECT_HOSTNAME}:${var.REG_HOST_PORT}/${local.consul.image}"
        image_pull_timeout = "10m"
        ports              = ["postgres"]

        volumes = [
          "${local.consul.volumes[0].source}:${local.consul.volumes[0].target}"
          "${local.consul.volumes[1].source}:${local.consul.volumes[1].target}"
          "${local.consul.volumes[2].source}:${local.consul.volumes[2].target}"
        ]
      }

      // volume_mount {
      //   volume      = "dev_core-postgres"
      //   destination = "${local.consul.volumes[0].target}/pgdata"
      //   read_only   = false
      // }

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

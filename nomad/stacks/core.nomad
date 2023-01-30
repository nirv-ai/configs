# internal
variable "NOMAD_DC" {
  type    = string
  default = "us-east"
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
variable "services" {
  type = object({
    core-consul = object({
      domainname  = string
      entrypoint  = list(string)
      image       = string
      extra_hosts = list(string)

      environment = object({
        CONSUL_ADDR_BIND     = string
        CONSUL_ADDR_BIND_LAN = string
        CONSUL_ADDR_BIND_WAN = string
        CONSUL_ADDR_CLIENT   = string
        CONSUL_ALT_DOMAIN    = string
        CONSUL_CACERT        = string
        CONSUL_CLIENT_CERT   = string
        CONSUL_CLIENT_KEY    = string
        CONSUL_DIR_BASE      = string
        CONSUL_DIR_CONFIG    = string
        CONSUL_DIR_DATA      = string
        CONSUL_DNS_TOKEN     = string
        CONSUL_GID           = string
        CONSUL_HTTP_TOKEN    = string
        CONSUL_NODE_PREFIX   = string
        CONSUL_PID_FILE      = string
        CONSUL_PORT_HOST     = string
        CONSUL_PORT_CUNT     = string
        CONSUL_PORT_DNS      = string
        CONSUL_PORT_GRPC     = string
        CONSUL_PORT_SERF_LAN = string
        CONSUL_PORT_SERF_WAN = string
        CONSUL_PORT_SERVER   = string
        CONSUL_UID           = string
        MESH_HOSTNAME        = string
        MESH_SERVER_HOSTNAME = string
      })
      ports = list(object({
        mode     = string
        protocol = string
        // published = string
        target = string
      }))
      volumes = list(object({
        type   = string
        source = string
        target = string
      }))
    })

    core-proxy = object({
      domainname  = string
      entrypoint  = list(string)
      image       = string
      extra_hosts = list(string)

      environment = object({
        // PROXY_PORT_WEB_H     = string
        // PROXY_PORT_WEB_S     = string
        // VAULT_HOSTNAME       = string
        // WEB_BFF_HOSTNAME     = string
        // WEB_BFF_PORT         = string
        // WEB_UI_HOSTNAME      = string
        // WEB_UI_PORT          = string
        CERTS_DIR_CUNT       = string
        CONSUL_ADDR_BIND     = string
        CONSUL_ADDR_BIND_LAN = string
        CONSUL_ADDR_BIND_WAN = string
        CONSUL_ADDR_CLIENT   = string
        CONSUL_ALT_DOMAIN    = string
        CONSUL_CACERT        = string
        CONSUL_CLIENT_CERT   = string
        CONSUL_CLIENT_KEY    = string
        CONSUL_DIR_BASE      = string
        CONSUL_DIR_CONFIG    = string
        CONSUL_DIR_DATA      = string
        CONSUL_ENVOY_PORT    = string # TODO: need to pull this out of envoy config
        CONSUL_GID           = string
        CONSUL_HTTP_TOKEN    = string
        CONSUL_NODE_PREFIX   = string
        CONSUL_PID_FILE      = string
        CONSUL_PORT_CUNT     = string
        CONSUL_PORT_DNS      = string
        CONSUL_PORT_GRPC     = string
        CONSUL_PORT_SERF_LAN = string
        CONSUL_PORT_SERF_WAN = string
        CONSUL_PORT_SERVER   = string
        CONSUL_UID           = string
        MESH_HOSTNAME        = string
        MESH_SERVER_HOSTNAME = string
        PROJECT_CERTS        = string # e.g. dev.nirv.ai cert
        PROJECT_DOMAIN_NAME  = string
        PROJECT_HOSTNAME     = string
        PROXY_AUTH_NAME      = string
        PROXY_AUTH_PASS      = string
        PROXY_PORT_EDGE      = string
        PROXY_PORT_STATS     = string
        PROXY_PORT_VAULT     = string
        VAULT_PORT_CUNT      = string
      })
      ports = list(object({
        mode      = string
        protocol  = string
        published = string
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
  })
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
    mesh_core_vault = object({
      name = string
      file = string
    })
    mesh_core_vault_privkey = object({
      name = string
      file = string
    })
    mesh_server = object({
      name = string
      file = string
    })
    mesh_server_privkey = object({
      name = string
      file = string
    })
    nirvai_combined = object({
      name = string
      file = string
    })
    nirvai_fullchain = object({
      name = string
      file = string
    })
    nirvai_privkey = object({
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
variable "name" {}
variable "networks" {}
variable "x-deploy" {}
variable "x-service-defaults" {}
variable "x-service-healthcheck" {}

locals {
  # TODO: cert related files should be placed in nomad secrets
  # ^ we can now resolve this via env vars
  # job
  jobkeys = {
    ca = {
      target = "/run/secrets/${var.x-mesh-ca.target}"
      source = "${var.secrets.mesh_ca.file}"
    }
  }
  # consul_group
  consul    = var.services.core-consul
  consulenv = var.services.core-consul.environment
  consulkeys = {
    consul_pub = {
      target = "/run/secrets/${var.x-mesh-server.target}"
      source = "${var.secrets.mesh_server.file}"
    }
    consul_prv = {
      target = "/run/secrets/${var.x-mesh-server-privkey.target}"
      source = "${var.secrets.mesh_server_privkey.file}"
    }
  }


  # proxy_group
  proxy    = var.services.core-proxy
  proxyenv = var.services.core-proxy.environment
  proxykeys = {
    proxy_pub = {
      target = "/run/secrets/${var.x-mesh-core-proxy.target}"
      source = "${var.secrets.mesh_core_proxy.file}"
    }
    proxy_prv = {
      target = "/run/secrets/${var.x-mesh-core-proxy-privkey.target}"
      source = "${var.secrets.mesh_core_proxy_privkey.file}"
    }
    host_combined = {
      target = "/run/secrets/${var.x-nirvai-combined.target}"
      source = "${var.secrets.nirvai_combined.file}"
    }
  }

  # vault_group
  // vault    = var.services.core-vault
  // vaultenv = var.services.core-vault.environment
}

job "core" {
  datacenters = ["${var.NOMAD_DC}"]
  region      = "${var.NOMAD_REGION}"
  type        = "service"
  priority    = 100

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  // meta {
  //   run_uuid = "${uuidv4()}" # turn off in prod
  // }

  # temp disable until we get this shiz figured out
  reschedule {
    attempts  = 0
    unlimited = false
  }

  group "consul" {
    count = 1

    network {
      mode = "bridge"

      port "consul_ui" {
        static = "${local.consulenv.CONSUL_PORT_HOST}"
        to     = "${local.consulenv.CONSUL_PORT_CUNT}"
      }
      port "consul_dns" {
        to     = "${local.consulenv.CONSUL_PORT_DNS}"
      }
      port "consul_grpc" {
        to     = "${local.consulenv.CONSUL_PORT_GRPC}"
      }
      port "consul_serf_lan" {
        to     = "${local.consulenv.CONSUL_PORT_SERF_LAN}"
      }
      port "consul_serf_wan" {
        to     = "${local.consulenv.CONSUL_PORT_SERF_WAN}"
      }
      port "consul_server" {
        to     = "${local.consulenv.CONSUL_PORT_SERVER}"
      }
    }

    restart {
      attempts = 0
      mode     = "fail"
    }

    scaling {
      enabled = true
      min     = 1
      max     = 1
    }

    service {
      provider = "nomad"
      tags     = ["consul", "core-consul"]
      task     = "core-consul"
    }

    task "core-consul" {
      driver = "docker"
      leader = true
      user   = "consul"

      config {
        auth_soft_fail     = true # dont fail on auth errors
        entrypoint         = "${local.consul.entrypoint}"
        extra_hosts        = "${local.consul.extra_hosts}"
        force_pull         = true
        image              = "${local.consul.image}"
        image_pull_timeout = "1m"
        init               = true
        interactive        = false

        ports = ["consul_ui", "consul_dns", "consul_serf_lan", "consul_serf_wan"]

        healthchecks {
          disable = true
        }

        # TODO: these indexed mounts are going to fail
        # ^ as soon as the order changes in compose file
        mount { # consul/config
          type     = "bind"
          target   = "${local.consul.volumes[0].target}"
          source   = "${local.consul.volumes[0].source}"
          readonly = false
          bind_options {
            propagation = "rshared"
          }
        }
        mount { # consul/data
          type     = "bind"
          target   = "${local.consul.volumes[1].target}"
          source   = "${local.consul.volumes[1].source}"
          readonly = false
          bind_options {
            propagation = "rshared"
          }
        }
        mount { #dockersock
          type     = "bind"
          target   = "${local.consul.volumes[2].target}"
          source   = "${local.consul.volumes[2].source}"
          readonly = true
        }
        mount {
          type   = "bind"
          target = "${local.jobkeys.ca.target}"
          source = "${local.jobkeys.ca.source}"
        }
        mount {
          type   = "bind"
          target = "${local.consulkeys.consul_pub.target}"
          source = "${local.consulkeys.consul_pub.source}"
        }
        mount {
          type   = "bind"
          target = "${local.consulkeys.consul_prv.target}"
          source = "${local.consulkeys.consul_prv.source}"
        }
      } # end config

      env {
        CONSUL_ADDR_BIND     = "${local.consulenv.CONSUL_ADDR_BIND}"
        CONSUL_ADDR_BIND_LAN = "${local.consulenv.CONSUL_ADDR_BIND_LAN}"
        CONSUL_ADDR_BIND_WAN = "${local.consulenv.CONSUL_ADDR_BIND_WAN}"
        CONSUL_ADDR_CLIENT   = "${local.consulenv.CONSUL_ADDR_CLIENT}"
        CONSUL_ALT_DOMAIN    = "${local.consulenv.CONSUL_ALT_DOMAIN}"
        CONSUL_CACERT        = "${local.consulenv.CONSUL_CACERT}"
        CONSUL_CLIENT_CERT   = "${local.consulenv.CONSUL_CLIENT_CERT}"
        CONSUL_CLIENT_KEY    = "${local.consulenv.CONSUL_CLIENT_KEY}"
        CONSUL_DIR_BASE      = "${local.consulenv.CONSUL_DIR_BASE}"
        CONSUL_DIR_CONFIG    = "${local.consulenv.CONSUL_DIR_CONFIG}"
        CONSUL_DIR_DATA      = "${local.consulenv.CONSUL_DIR_DATA}"
        CONSUL_DNS_TOKEN     = "${local.consulenv.CONSUL_DNS_TOKEN}"
        CONSUL_GID           = "${local.consulenv.CONSUL_GID}"
        CONSUL_HTTP_TOKEN    = "${local.consulenv.CONSUL_HTTP_TOKEN}"
        CONSUL_NODE_PREFIX   = "${local.consulenv.CONSUL_NODE_PREFIX}"
        CONSUL_PID_FILE      = "${local.consulenv.CONSUL_PID_FILE}"
        CONSUL_PORT_CUNT     = "${local.consulenv.CONSUL_PORT_CUNT}"
        CONSUL_PORT_DNS      = "${NOMAD_PORT_consul_dns}"
        CONSUL_PORT_GRPC     = "${NOMAD_PORT_consul_grpc}"
        CONSUL_PORT_SERF_LAN = "${NOMAD_PORT_consul_serf_lan}"
        CONSUL_PORT_SERF_WAN = "${NOMAD_PORT_consul_serf_wan}"
        CONSUL_PORT_SERVER   = "${NOMAD_PORT_consul_server}"
        CONSUL_UID           = "${local.consulenv.CONSUL_UID}"
        DATACENTER           = "${var.NOMAD_DC}"
        MESH_HOSTNAME        = "${local.consulenv.MESH_HOSTNAME}"
        MESH_SERVER_HOSTNAME = "${local.consulenv.MESH_SERVER_HOSTNAME}"
      } # end env

      # max 30mb (3 + 3 * 5mb)
      logs {
        max_files     = 3
        max_file_size = 5
      }

      # TODO: this shiz is wayyy off, check nomad ui and increase + surplus
      resources {
        memory = 256 # MB
        cpu    = 500
      }
    } # end task
  }   # end group

  group "proxy" {
    count = 1

    network {
      mode = "bridge"

      port "proxy_edge" {
        static = "${local.proxyenv.PROXY_PORT_EDGE}"
        to     = "${local.proxyenv.PROXY_PORT_EDGE}"
      }
      port "proxy_stats" {
        static = "${local.proxyenv.PROXY_PORT_STATS}"
        to     = "${local.proxyenv.PROXY_PORT_STATS}"
      }
      port "proxy_vault" {
        static = "${local.proxyenv.PROXY_PORT_VAULT}"
        to     = "${local.proxyenv.PROXY_PORT_VAULT}"
      }
      port "consul_cunt" {
        to     = "${local.proxyenv.CONSUL_PORT_CUNT}"
      }
      port "consul_dns" {
        to     = "${local.proxyenv.CONSUL_PORT_DNS}"
      }
      port "consul_grpc" {
        to     = "${local.proxyenv.CONSUL_PORT_GRPC}"
      }
      port "consul_serf_lan" {
        to     = "${local.proxyenv.CONSUL_PORT_SERF_LAN}"
      }
      port "consul_serf_wan" {
        to     = "${local.proxyenv.CONSUL_PORT_SERF_WAN}"
      }
      port "consul_server" {
        to     = "${local.proxyenv.CONSUL_PORT_SERVER}"
      }
    } # end network

    restart {
      attempts = 0
      mode     = "fail"
    }

    scaling {
      enabled = true
      min     = 1
      max     = 1
    }

    service {
      provider = "nomad"
      tags     = ["proxy", "core-proxy"]
      task     = "core-proxy"
    }

    task "core-proxy" {
      driver = "docker"
      leader = true
      user   = "root"

      config {
        auth_soft_fail     = true # dont fail on auth errors
        entrypoint         = "${local.proxy.entrypoint}"
        extra_hosts        = "${local.proxy.extra_hosts}"
        force_pull         = true
        image              = "${local.proxy.image}"
        image_pull_timeout = "1m"
        init               = true
        interactive        = false

        ports = ["proxy_edge", "proxy_stats", "proxy_vault"]

        # TODO: haproxy has working docker healthchecks
        healthchecks {
          disable = true
        }

        # TODO: these index mount points have the same issue as consuls
        mount { # consul/config
          type     = "bind"
          target   = "${local.proxy.volumes[0].target}"
          source   = "${local.proxy.volumes[0].source}"
          readonly = false
          bind_options {
            propagation = "rshared"
          }
        }
        mount { # consul/data
          type     = "bind"
          target   = "${local.proxy.volumes[1].target}"
          source   = "${local.proxy.volumes[1].source}"
          readonly = false
          bind_options {
            propagation = "rshared"
          }
        }
        mount { # consul/envoy
          type     = "bind"
          target   = "${local.proxy.volumes[2].target}"
          source   = "${local.proxy.volumes[2].source}"
          readonly = false
          bind_options {
            propagation = "rshared"
          }
        }
        mount { # haproxy
          type     = "bind"
          target   = "${local.proxy.volumes[3].target}"
          source   = "${local.proxy.volumes[3].source}"
          readonly = false
          bind_options {
            propagation = "rshared"
          }
        }
        mount { #dockersock
          type     = "bind"
          target   = "${local.proxy.volumes[4].target}"
          source   = "${local.proxy.volumes[4].source}"
          readonly = true
        }
        mount {
          type   = "bind"
          target = "${local.jobkeys.ca.target}"
          source = "${local.jobkeys.ca.source}"
        }
        mount {
          type   = "bind"
          target = "${local.proxykeys.proxy_pub.target}"
          source = "${local.proxykeys.proxy_pub.source}"
        }
        mount {
          type   = "bind"
          target = "${local.proxykeys.proxy_prv.target}"
          source = "${local.proxykeys.proxy_prv.source}"
        }
        # e.g. dev.nirv.ai,
        # TODO: change from host_combined to something like ingress_combined
        mount {
          type   = "bind"
          target = "${local.proxykeys.host_combined.target}"
          source = "${local.proxykeys.host_combined.source}"
        }
      } # end config

      env {
        // PROXY_PORT_WEB_H     = "${local.proxyenv.PROXY_PORT_WEB_H}"
        // PROXY_PORT_WEB_S     = "${local.proxyenv.PROXY_PORT_WEB_S}"
        // VAULT_HOSTNAME       = "${local.proxyenv.VAULT_HOSTNAME}"
        // VAULT_PORT_CUNT      = "${local.proxyenv.VAULT_PORT_CUNT}"
        // WEB_BFF_HOSTNAME     = "${local.proxyenv.WEB_BFF_HOSTNAME}"
        // WEB_BFF_PORT         = "${local.proxyenv.WEB_BFF_PORT}"
        // WEB_UI_HOSTNAME      = "${local.proxyenv.WEB_UI_HOSTNAME}"
        // WEB_UI_PORT          = "${local.proxyenv.WEB_UI_PORT}"
        CERTS_DIR_CUNT       = "${local.proxyenv.CERTS_DIR_CUNT}"
        CONSUL_ADDR_BIND     = "${local.proxyenv.CONSUL_ADDR_BIND}"
        CONSUL_ADDR_BIND_LAN = "${local.proxyenv.CONSUL_ADDR_BIND_LAN}"
        CONSUL_ADDR_BIND_WAN = "${local.proxyenv.CONSUL_ADDR_BIND_WAN}"
        CONSUL_ADDR_CLIENT   = "${local.proxyenv.CONSUL_ADDR_CLIENT}"
        CONSUL_ALT_DOMAIN    = "${local.proxyenv.CONSUL_ALT_DOMAIN}"
        CONSUL_CACERT        = "${local.proxyenv.CONSUL_CACERT}"
        CONSUL_CLIENT_CERT   = "${local.proxyenv.CONSUL_CLIENT_CERT}"
        CONSUL_CLIENT_KEY    = "${local.proxyenv.CONSUL_CLIENT_KEY}"
        CONSUL_DIR_BASE      = "${local.proxyenv.CONSUL_DIR_BASE}"
        CONSUL_DIR_CONFIG    = "${local.proxyenv.CONSUL_DIR_CONFIG}"
        CONSUL_DIR_DATA      = "${local.proxyenv.CONSUL_DIR_DATA}"
        CONSUL_ENVOY_PORT    = "${local.proxyenv.CONSUL_ENVOY_PORT}"
        CONSUL_GID           = "${local.proxyenv.CONSUL_GID}"
        CONSUL_HTTP_TOKEN    = "${local.proxyenv.CONSUL_HTTP_TOKEN}"
        CONSUL_NODE_PREFIX   = "${local.proxyenv.CONSUL_NODE_PREFIX}"
        CONSUL_PID_FILE      = "${local.proxyenv.CONSUL_PID_FILE}"
        CONSUL_PORT_CUNT      = "${NOMAD_PORT_consul_cunt}"
        CONSUL_PORT_DNS      = "${NOMAD_PORT_consul_dns}"
        CONSUL_PORT_GRPC     = "${NOMAD_PORT_consul_grpc}"
        CONSUL_PORT_SERF_LAN = "${NOMAD_PORT_consul_serf_lan}"
        CONSUL_PORT_SERF_WAN = "${NOMAD_PORT_consul_serf_wan}"
        CONSUL_PORT_SERVER   = "${NOMAD_PORT_consul_server}"
        CONSUL_UID           = "${local.proxyenv.CONSUL_UID}"
        DATACENTER           = "${var.NOMAD_DC}"
        MESH_HOSTNAME        = "${local.proxyenv.MESH_HOSTNAME}"
        MESH_SERVER_HOSTNAME = "${local.proxyenv.MESH_SERVER_HOSTNAME}"
        PROJECT_CERTS        = "${local.proxyenv.PROJECT_CERTS}" # e.g. dev.nirv.ai
        PROJECT_DOMAIN_NAME  = "${local.proxyenv.PROJECT_DOMAIN_NAME}"
        PROJECT_HOSTNAME     = "${local.proxyenv.PROJECT_HOSTNAME}"
        PROXY_AUTH_NAME      = "${local.proxyenv.PROXY_AUTH_NAME}"
        PROXY_AUTH_PASS      = "${local.proxyenv.PROXY_AUTH_PASS}"
        PROXY_PORT_EDGE      = "${NOMAD_PORT_proxy_edge}"
        PROXY_PORT_STATS     = "${NOMAD_PORT_proxy_stats}"
        PROXY_PORT_VAULT     = "${NOMAD_PORT_proxy_vault}"
      } # end env

      # max 30mb (3 + 3 * 5mb)
      logs {
        max_files     = 3
        max_file_size = 5
      }

      # TODO: this shiz is wayyy off, check nomad ui and increase + surplus
      resources {
        memory = 256 # MB
        cpu    = 500
      }

      template {
        change_mode = "restart"
        destination = "local/testing.hcl"
        env = false
        data = <<EOH
          upstream my_app {
            {{- range nomadService "core-consul" }}
            server {{ .Address }}:{{ .Port }};{{- end }}
          }
        EOH
      }
    } # end task
  }   # end group

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

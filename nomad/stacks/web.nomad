# TODO: we cant use 99% of vars provided by dev as its all open source

variable "name" {
  type = string
}
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
variable "WEB_ENV" {
  type    = string
  default = "development"
}
variable "networks" {
  type = map(map(string))
}
variable "volumes" {
  type = object({
    nirvai_web_postgres = object({
      name     = string
      external = bool
    })
  })
}
variable "services" {
  type = object({
    web_vault = object({
      cap_add        = list(string)
      container_name = string
      entrypoint     = list(string)
      hostname       = string
      image          = string
      environment = object({
        PROJECT_HOSTNAME = string
        PROJECT_NAME     = string
      })
      ports = list(object({
        mode      = string
        published = string
        protocol  = string
        target    = number
      }))
      volumes = list(object({
        type   = string
        source = string
        target = string
        bind = object({
          create_host_path = bool
        })
      }))
    })

    web_postgres = object({
      container_name = string
      hostname       = string
      image          = string
      environment = object({
        DEFAULT_DB                = string
        DEFAULT_DB_ADMIN          = string
        DEFAULT_DB_ADMIN_PW       = string
        DEFAULT_DB_HOST           = string
        DEFAULT_DB_PORT           = string
        DEFAULT_DB_USER           = string
        DEFAULT_SCHEMA            = string
        PGDATA                    = string
        PGPASSWORD                = string
        POSTGRES_DB               = string
        POSTGRES_HOST_AUTH_METHOD = string
        POSTGRES_INITDB_ARGS      = string
        POSTGRES_PASSWORD         = string
        POSTGRES_USER             = string
        PROJECT_HOSTNAME          = string
        PROJECT_NAME              = string
        R_ROLE                    = string
        RW_ROLE                   = string
        VAULT_U                   = string
        VAULT_P                   = string
      })
      ports = list(object({
        mode      = string
        published = string
        protocol  = string
        target    = number
      }))
      volumes = list(object({
        type   = string
        source = string
        target = string
      }))
    })

    web_bff = object({
      container_name = string
      entrypoint     = list(string)
      healthcheck    = map(string)
      hostname       = string
      image          = string
      environment = object({
        WEB_BFF_PORT          = string
        BFF_APP_ROLE          = string
        BFF_DB_CORE_ROLE      = string
        NODE_ENV              = string
        WEB_POSTGRES_PORT     = string
        WEB_POSTGRES_HOSTNAME = string
        PROJECT_HOSTNAME      = string
        PROJECT_NAME          = string
        VAULT_ADDR            = string
      })
      ports = list(object({
        mode      = string
        published = string
        protocol  = string
        target    = string
      }))
      volumes = list(object({
        type   = string
        source = string
        target = string
      }))
    })

    core_proxy = object({
      container_name = string
      entrypoint     = list(string)
      hostname       = string
      image          = string
      environment = object({
        PROJECT_HOSTNAME = string
        PROJECT_NAME     = string
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
  })
}

locals {
  # postgres_group
  postgres    = var.services.web_postgres
  postgresenv = var.services.web_postgres.environment

  # vault_group
  vault    = var.services.web_vault
  vaultenv = var.services.web_vault.environment

  # bff_group
  bff    = var.services.web_bff
  bffenv = var.services.web_bff.environment

  # proxy_group
  proxy    = var.services.core_proxy
  proxyenv = var.services.core_proxy.environment
}

job "dev_core" {
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

  group "postgres_group" {
    count = 1
    restart {
      attempts = 1
    }

    network {
      mode     = "bridge"
      hostname = "${local.postgres.hostname}"
      port "postgres" {
        # host port set as: NOMAD_HOST_PORT_postgres
        to = "${local.postgres.ports[0].target}"
      }
    }

    # TODO: still receiving permission errors
    // volume "dev_web_postgres" {
    //   type      = "host"
    //   source    = "dev_web_postgres"
    //   read_only = false
    // }

    task "postgres_task" {
      driver = "docker"

      config {
        healthchecks {
          disable = true
        }
        auth_soft_fail     = true # dont fail on auth errors
        force_pull         = true
        image              = "${local.postgresenv.PROJECT_HOSTNAME}:${var.REG_HOST_PORT}/${local.postgres.image}"
        image_pull_timeout = "10m"
        ports              = ["postgres"]

        volumes = [
          "${local.vault.volumes[0].source}:${local.vault.volumes[0].target}"
        ]
      }

      // volume_mount {
      //   volume      = "dev_web_postgres"
      //   destination = "${local.postgres.volumes[0].target}/pgdata"
      //   read_only   = false
      // }

      env {
        DEFAULT_DB                = "${local.postgresenv.DEFAULT_DB}"
        DEFAULT_DB_ADMIN          = "${local.postgresenv.DEFAULT_DB_ADMIN}"
        DEFAULT_DB_ADMIN_PW       = "${local.postgresenv.DEFAULT_DB_ADMIN_PW}"
        DEFAULT_DB_HOST           = "${local.postgresenv.DEFAULT_DB_HOST}"
        DEFAULT_DB_PORT           = "${local.postgresenv.DEFAULT_DB_PORT}"
        DEFAULT_DB_USER           = "${local.postgresenv.DEFAULT_DB_USER}"
        DEFAULT_SCHEMA            = "${local.postgresenv.DEFAULT_SCHEMA}"
        ENV                       = "${var.WEB_ENV}"
        PGDATA                    = "${local.postgresenv.PGDATA}"
        PGPASSWORD                = "${local.postgresenv.PGPASSWORD}"
        POSTGRES_DB               = "${local.postgresenv.POSTGRES_DB}"
        POSTGRES_HOST_AUTH_METHOD = "${local.postgresenv.POSTGRES_HOST_AUTH_METHOD}"
        POSTGRES_INITDB_ARGS      = "${local.postgresenv.POSTGRES_INITDB_ARGS}"
        POSTGRES_PASSWORD         = "${local.postgresenv.POSTGRES_PASSWORD}"
        POSTGRES_USER             = "${local.postgresenv.POSTGRES_USER}"
        PROJECT_HOSTNAME          = "${local.postgresenv.PROJECT_HOSTNAME}"
        PROJECT_NAME              = "${local.postgresenv.PROJECT_NAME}"
        R_ROLE                    = "${local.postgresenv.R_ROLE}"
        RW_ROLE                   = "${local.postgresenv.RW_ROLE}"
        VAULT_P                   = "${local.postgresenv.VAULT_P}"
        VAULT_U                   = "${local.postgresenv.VAULT_U}"
      }
    }
  }

  group "vault_group" {
    count = 1
    restart {
      attempts = 1
    }

    network {
      mode     = "bridge"
      hostname = "${local.vault.hostname}"
      port "vault" {
        # host port set as: NOMAD_HOST_PORT_vault
        to = "${local.vault.ports[0].target}"
      }
    }

    task "vault_task" {
      driver = "docker"

      config {
        healthchecks {
          disable = true
        }
        auth_soft_fail     = true # dont fail on auth errors
        entrypoint         = "${local.vault.entrypoint}"
        force_pull         = true
        image              = "${local.vaultenv.PROJECT_HOSTNAME}:${var.REG_HOST_PORT}/${local.vault.image}"
        image_pull_timeout = "10m"
        ports              = ["vault"]

        cap_add = [
          "${local.vault.cap_add[0]}"
        ]


        volumes = [
          "${local.vault.volumes[0].source}:${local.vault.volumes[0].target}",
          "${local.vault.volumes[1].source}:${local.vault.volumes[1].target}",
          "${local.vault.volumes[2].source}:${local.vault.volumes[2].target}"
        ]
      }

      env {
        // VAULT_ADDR = "https://$PROJECT_HOSTNAME:${NOMAD_PORT_vault}"
        PROJECT_HOSTNAME = "${local.vaultenv.PROJECT_HOSTNAME}"
        PROJECT_NAME     = "${local.vaultenv.PROJECT_NAME}"
      }
    }
  }

  group "bff_group" {
    count = 1
    restart {
      attempts = 1
    }

    network {
      mode     = "bridge"
      hostname = "${local.bff.hostname}"
      port "bff" {
        # host port set as: NOMAD_HOST_PORT_bff
        to = "${local.bff.ports[0].target}"
      }
    }

    task "bff_task" {
      driver = "docker"

      config {
        healthchecks {
          disable = true
        }
        auth_soft_fail     = true # dont fail on auth errors
        entrypoint         = "${local.bff.entrypoint}"
        force_pull         = true
        image              = "${local.bffenv.PROJECT_HOSTNAME}:${var.REG_HOST_PORT}/${local.bff.image}"
        image_pull_timeout = "10m"
        ports              = ["bff"]

        volumes = [
          "${local.bff.volumes[0].source}:${local.bff.volumes[0].target}",
          "${local.bff.volumes[1].source}:${local.bff.volumes[1].target}"
        ]
      }

      env {
        WEB_BFF_PORT          = "${local.bffenv.WEB_BFF_PORT}"
        BFF_APP_ROLE          = "${local.bffenv.BFF_APP_ROLE}"
        BFF_DB_CORE_ROLE      = "${local.bffenv.BFF_DB_CORE_ROLE}"
        NODE_ENV              = "${local.bffenv.NODE_ENV}"
        WEB_POSTGRES_PORT     = "${local.bffenv.WEB_POSTGRES_PORT}"
        WEB_POSTGRES_HOSTNAME = "${local.bffenv.WEB_POSTGRES_HOSTNAME}"
        PROJECT_HOSTNAME      = "${local.bffenv.PROJECT_HOSTNAME}"
        PROJECT_NAME          = "${local.bffenv.PROJECT_NAME}"
        VAULT_ADDR            = "${local.bffenv.VAULT_ADDR}"
      }
    }
  }

  group "proxy_group" {
    count = 1
    restart {
      attempts = 1
    }

    network {
      mode     = "bridge"
      hostname = "${local.proxy.hostname}"

      port "edge" {
        # host port set as: NOMAD_HOST_PORT_edge
        to = "${local.proxy.ports[0].target}"
      }
      port "vault" {
        # host port set as: NOMAD_HOST_PORT_vault
        to = "${local.proxy.ports[1].target}"
      }
      port "stats" {
        # host port set as: NOMAD_HOST_PORT_stats
        to = "${local.proxy.ports[2].target}"
      }
    }

    task "proxy_task" {
      driver = "docker"

      config {
        healthchecks {
          disable = true
        }
        auth_soft_fail     = true # dont fail on auth errors
        entrypoint         = "${local.proxy.entrypoint}"
        force_pull         = true
        image              = "${local.proxyenv.PROJECT_HOSTNAME}:${var.REG_HOST_PORT}/${local.proxy.image}"
        image_pull_timeout = "10m"
        ports              = ["edge", "vault", "stats"]

        volumes = [
          "${local.proxy.volumes[0].source}:${local.proxy.volumes[0].target}",
          "${local.proxy.volumes[1].source}:${local.proxy.volumes[1].target}",
          "${local.proxy.volumes[2].source}:${local.proxy.volumes[2].target}"
        ]
      }

      env {
        PROJECT_HOSTNAME = "${local.proxyenv.PROJECT_HOSTNAME}"
        PROJECT_NAME     = "${local.proxyenv.PROJECT_NAME}"
      }
    }
  }
}

variable "name" {
  type = string
}

variable "services" {
  type = object({
    core_vault = object({
      cap_add        = list(string)
      container_name = string
      entrypoint     = list(string)
      image          = string
      environment = object({
        DATA_CENTER       = string
        DEFAULT_DB        = string
        PROJECT_HOST_NAME = string
        PROJECT_NAME      = string
        R_ROLE            = string
        REG_HOST_PORT     = string
        REGION            = string
        RW_ROLE           = string
      })
      ports = list(object({
        mode      = string
        published = string
        protocol  = string
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

    core_postgres = object({
      container_name = string
      image          = string
      environment = object({
        DATA_CENTER               = string
        DEFAULT_DB                = string
        DEFAULT_SCHEMA            = string
        PGDATA                    = string
        POSTGRES_DB               = string
        POSTGRES_HOST_AUTH_METHOD = string
        POSTGRES_INITDB_ARGS      = string
        PROJECT_HOST_NAME         = string
        PROJECT_NAME              = string
        R_ROLE                    = string
        REG_HOST_PORT             = string
        REGION                    = string
        RW_ROLE                   = string
      })
      ports = list(object({
        mode      = string
        published = string
        protocol  = string
      }))
      volumes = list(object({
        type   = string
        source = string
        target = string
      }))
    })

    core_bff = object({
      command        = list(string)
      container_name = string
      healthcheck    = map(string)
      image          = string
      environment = object({
        BFF_APP_ROLE      = string
        BFF_DB_CORE_ROLE  = string
        DATA_CENTER       = string
        PROJECT_HOST_NAME = string
        PROJECT_NAME      = string
        REG_HOST_PORT     = string
        REGION            = string
      })
      ports = list(object({
        mode      = string
        published = string
        protocol  = string
      }))
      volumes = list(object({
        type   = string
        source = string
        target = string
      }))
    })

    core_proxy = object({
      container_name = string
      image          = string
      environment = object({
        DATA_CENTER       = string
        PROJECT_HOST_NAME = string
        PROJECT_NAME      = string
        REG_HOST_PORT     = string
        REGION            = string
      })
      ports = list(object({
        mode      = string
        published = string
        protocol  = string
      }))
      volumes = list(object({
        type   = string
        source = string
        target = string
      }))
    })
  })
}

variable "volumes" {
  type = object({
    nirvai_core_postgres = object({
      name     = string
      external = bool
    })
  })
}

locals {
  volumes = var.volumes

  # vault_group
  vault    = var.services.core_vault
  vaultenv = var.services.core_vault.environment

  # postgres_group
  postgres    = var.services.core_postgres
  postgresenv = var.services.core_postgres.environment

  # bff_group
  bff    = var.services.core_bff
  bffenv = var.services.core_bff.environment

  # proxy_group
  proxy    = var.services.core_proxy
  proxyenv = var.services.core_proxy.environment
}

job "dev_core" {
  datacenters = ["${local.vaultenv.DATA_CENTER}"]
  region      = "${local.vaultenv.REGION}"
  type        = "service"

  meta {
    # turn off in prod
    run_uuid = "${uuidv4()}"
  }

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  # Specify this job to have rolling updates, two-at-a-time, with
  # 30 second intervals.
  update {
    stagger      = "30s"
    max_parallel = 1
  }

  group "vault_group" {
    count = 1
    restart {
      attempts = 0
    }

    network {
      // mode = "bridge" //cant be used with hostname
      // hostname = "${local.vault.hostname}"

      port "vault" {
        # todo: map a nomadport to exposed image port
        // static = parseint(local.vaultenv.VAULT_PORT_A_HOST, 10)
      }
    }

    task "vault_task" {
      driver = "docker"

      config {
        healthchecks {
          disable = true
        }
        auth_soft_fail     = true # dont fail on auth errors
        force_pull         = true
        image              = "${local.vaultenv.PROJECT_HOST_NAME}:${local.vaultenv.REG_HOST_PORT}/${local.vault.image}"
        image_pull_timeout = "10m"
        // hostname = "${local.vaultenv.PROJECT_HOST_NAME}"
        cap_add = [
          "${local.vault.cap_add[0]}"
        ]

        ports = ["vault"]

        entrypoint = "${local.vault.entrypoint}"
        volumes = [
          "${local.vault.volumes[0].source}:${local.vault.volumes[0].target}",
          "${local.vault.volumes[1].source}:${local.vault.volumes[1].target}",
          "${local.vault.volumes[2].source}:${local.vault.volumes[2].target}"
        ]
      }

      # @see https://developer.hashicorp.com/nomad/docs/job-specification/env
      env {
        DATA_CENTER           = "${local.vaultenv.DATA_CENTER}"
        DEFAULT_DB            = "${local.vaultenv.DEFAULT_DB}"
        # todo: these should be nomad specific
        // DEFAULT_DB_HOST       = "${local.vaultenv.DEFAULT_DB_HOST}"
        // DEFAULT_DB_PORT       = "${local.vaultenv.DEFAULT_DB_PORT}"
        ENV                   = "development"
        PROJECT_HOST_NAME     = "${local.vaultenv.PROJECT_HOST_NAME}"
        PROJECT_NAME          = "${local.vaultenv.PROJECT_NAME}"
        R_ROLE                = "${local.vaultenv.R_ROLE}"
        REGION                = "${local.vaultenv.REGION}"
        RW_ROLE               = "${local.vaultenv.RW_ROLE}"
        # this needs to consume the nomad port
        // VAULT_ADDR            = "${local.vaultenv.VAULT_ADDR}"
      }

      // resources {
      //   cpu    = 500
      //   memory = 256
      // }
    }
  }

  group "postgres_group" {
    count = 1
    restart {
      attempts = 0
    }

    network {
      // mode = "bridge" //cant be used with hostname
      // hostname = "${local.vault.hostname}"

      port "postgres" {
        # todo: map a nomadport to the exposed image port
        // static = parseint(local.postgresenv.POSTGRES_PORT_A_HOST, 10)
      }
    }

    task "postgres_task" {
      driver = "docker"

      config {
        healthchecks {
          disable = true
        }
        auth_soft_fail     = true # dont fail on auth errors
        force_pull         = true
        image              = "${local.postgresenv.PROJECT_HOST_NAME}:${local.postgresenv.REG_HOST_PORT}/${local.postgres.image}"
        image_pull_timeout = "10m"
        ports              = ["postgres"]

        volumes = [
          "${local.vault.volumes[0].source}:${local.vault.volumes[0].target}"
        ]
      }

      # @see https://developer.hashicorp.com/nomad/docs/job-specification/env
      env {
        DATA_CENTER               = "${local.postgresenv.DATA_CENTER}"
        DEFAULT_DB                = "${local.postgresenv.DEFAULT_DB}"
        // DEFAULT_DB_ADMIN          = "${local.postgresenv.DEFAULT_DB_ADMIN}"
        // DEFAULT_DB_ADMIN_PW       = "${local.postgresenv.DEFAULT_DB_ADMIN_PW}"
        // DEFAULT_DB_HOST           = "${local.postgresenv.DEFAULT_DB_HOST}"
        // DEFAULT_DB_MAX_CONN       = "${local.postgresenv.DEFAULT_DB_MAX_CONN}"
        // DEFAULT_DB_PORT           = "${local.postgresenv.DEFAULT_DB_PORT}"
        // DEFAULT_DB_USER           = "${local.postgresenv.DEFAULT_DB_USER}"
        DEFAULT_SCHEMA            = "${local.postgresenv.DEFAULT_SCHEMA}"
        ENV                       = "development"
        PGDATA                    = "${local.postgresenv.PGDATA}"
        // PGPASSWORD                = "${local.postgresenv.PGPASSWORD}"
        POSTGRES_HOST_AUTH_METHOD = "${local.postgresenv.POSTGRES_HOST_AUTH_METHOD}"
        POSTGRES_INITDB_ARGS      = "${local.postgresenv.POSTGRES_INITDB_ARGS}"
        // POSTGRES_PASSWORD         = "${local.postgresenv.POSTGRES_PASSWORD}"
        // POSTGRES_USER             = "${local.postgresenv.POSTGRES_USER}"
        PROJECT_HOST_NAME         = "${local.postgresenv.PROJECT_HOST_NAME}"
        PROJECT_NAME              = "${local.postgresenv.PROJECT_NAME}"
        R_ROLE                    = "${local.postgresenv.R_ROLE}"
        REGION                    = "${local.postgresenv.REGION}"
        RW_ROLE                   = "${local.postgresenv.RW_ROLE}"
      }

      // resources {
      //   cpu    = 500
      //   memory = 256
      // }
    }
  }

  group "bff_group" {
    count = 1
    restart {
      attempts = 0
    }

    network {
      // mode = "bridge" //cant be used with hostname
      // hostname = "${local.vault.hostname}"

      port "bff" {
        # todo: map a nomadport to exposed image port
        // static = parseint(local.bffenv.APP_PORT, 10)
      }
    }

    task "bff_task" {
      driver = "docker"

      config {
        healthchecks {
          disable = true
        }
        auth_soft_fail     = true # dont fail on auth errors
        force_pull         = true
        image              = "${local.bffenv.PROJECT_HOST_NAME}:${local.bffenv.REG_HOST_PORT}/${local.bff.image}"
        image_pull_timeout = "10m"
        # todo: this needs to be entrypoint
        // command            = "${local.bff.command[0]}"
        // args               = ["${local.bff.command[1]}"]
        ports              = ["bff"]

        volumes = [
          "${local.bff.volumes[0].source}:${local.bff.volumes[0].target}",
          "${local.bff.volumes[1].source}:${local.bff.volumes[1].target}"
        ]
      }

      # @see https://developer.hashicorp.com/nomad/docs/job-specification/env
      env {
        APP_PORT              = "${local.bffenv.APP_PORT}"
        BFF_APP_ROLE          = "${local.bffenv.BFF_APP_ROLE}"
        BFF_DB_CORE_ROLE      = "${local.bffenv.BFF_DB_CORE_ROLE}"
        # TODO: need to assign and retrieve these
        // BFF_ROLE_ID           = "${local.bffenv.BFF_ROLE_ID}"
        // BFF_SECRET_ID         = "${local.bffenv.BFF_SECRET_ID}"
        DATA_CENTER           = "${local.bffenv.DATA_CENTER}"
        ENV                   = "development"
        NODE_ENV              = "development"
        # todo: think this needs to be nomad postgres port
        // POSTGRES_PORT_A_HOST  = "${local.bffenv.POSTGRES_PORT_A_HOST}"
        PROJECT_HOST_NAME     = "${local.bffenv.PROJECT_HOST_NAME}"
        PROJECT_NAME          = "${local.bffenv.PROJECT_NAME}"
        REGION                = "${local.bffenv.REGION}"
        # this needs to consume the nomad port
        # and pretty sure we hard coded this in the node app
        // VAULT_ADDR            = "${local.vaultenv.VAULT_ADDR}"
      }

      // resources {
      //   cpu    = 500
      //   memory = 256
      // }
    }
  }

  # we need to setup the server templates in haproxy
  group "proxy_group" {
    count = 1
    restart {
      attempts = 0
    }

    network {
      // mode = "bridge" //cant be used with hostname
      // hostname = "${local.vault.hostname}"

      port "edge" {
        # todo: map a nomadport to exposed image port
        // static = parseint(local.proxyenv.PROXY_PORT_A_HOST, 10)
      }
      port "vault" {
        # todo: map a nomadport to exposed image port
        // static = parseint(local.proxyenv.PROXY_PORT_B_HOST, 10)
      }
      port "stats" {
        # todo: map a nomadport to exposed image port
        // static = parseint(local.proxyenv.PROXY_PORT_C_HOST, 10)
      }
    }

    task "proxy_task" {
      driver = "docker"

      config {
        healthchecks {
          disable = true
        }
        auth_soft_fail     = true # dont fail on auth errors
        force_pull         = true
        image              = "${local.proxyenv.PROJECT_HOST_NAME}:${local.proxyenv.REG_HOST_PORT}/${local.proxy.image}"
        image_pull_timeout = "10m"
        ports              = ["edge", "vault", "stats"]

        volumes = [
          "${local.proxy.volumes[0].source}:${local.proxy.volumes[0].target}",
          "${local.proxy.volumes[1].source}:${local.proxy.volumes[1].target}",
          "${local.proxy.volumes[2].source}:${local.proxy.volumes[2].target}"
        ]
      }

      # @see https://developer.hashicorp.com/nomad/docs/job-specification/env
      env {
        DATA_CENTER       = "${local.proxyenv.DATA_CENTER}"
        ENV               = "development"
        PROJECT_HOST_NAME = "${local.proxyenv.PROJECT_HOST_NAME}"
        PROJECT_NAME      = "${local.proxyenv.PROJECT_NAME}"
        REGION            = "${local.proxyenv.REGION}"
      }

      // resources {
      //   cpu    = 500
      //   memory = 256
      // }
    }
  }
}

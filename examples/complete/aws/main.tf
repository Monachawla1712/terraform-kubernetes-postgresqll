locals {
  name        = "postgresql"
  region      = "us-east-2"
  environment = "prodd"
  additional_tags = {
    Owner      = "organization_name"
    Expires    = "Never"
    Department = "Engineering"
  }
  store_password_to_secret_manager = true
  custom_credentials_enabled       = true
  custom_credentials_config = {
    postgres_password = "60rbJs901a6Oa9hzUM5x7s8Q"
    repmgr_password   = "IWHLlEYOt25jL4Io7pancB"
  }
}

module "aws" {
  source                           = "git@github.com:sq-ia/terraform-kubernetes-postgresql.git//modules/resources/aws"
  name                             = local.name
  environment                      = local.environment
  cluster_name                     = ""
  store_password_to_secret_manager = local.store_password_to_secret_manager
  custom_credentials_enabled       = local.custom_credentials_enabled
  custom_credentials_config        = local.custom_credentials_config
}

module "postgresql" {
  source                      = "git@github.com:sq-ia/terraform-kubernetes-postgresql.git"
  postgresql_exporter_enabled = true
  custom_credentials_enabled  = local.custom_credentials_enabled
  custom_credentials_config   = local.custom_credentials_config
  repmgr_password             = module.aws.postgresql_credential.repmgr_password
  postgres_password           = module.aws.postgresql_credential.postgres_password
  postgresql_config = {
    name                             = local.name
    environment                      = local.environment
    replicaCount                     = 3
    storage_class                    = "gp2"
    postgresql_values                = file("./helm/postgresql.yaml")
    store_password_to_secret_manager = local.store_password_to_secret_manager
  }
}

module "postgresql" {
  source            = "../../"
  environment       = var.environment
  workload          = var.workload
  subscription_id   = var.subscription_id
  tenant_id         = var.tenant_id

  postgresql        = var.postgresql
}

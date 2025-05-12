module "network" {
  source          = "./modules/network"
  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "IAMRoles" {
  source = "./modules/IAMRoles"
}

module "security_groups" {
  source = "./modules/security-groups"
  vpc_id = module.network.vpc_id
}

module "edge_layer" {
  source                    = "./modules/edge_layer"
  aws_region                = var.aws_region
  presentation_alb_dns_name = module.ecs-frontend.presentation_alb_dns_name
  presentation_alb_id       = module.ecs-frontend.presentation_alb_id
}

module "ecs-frontend" {
  source                      = "./modules/ecs-frontend"
  vpc_id                      = module.network.vpc_id
  aws_region                  = var.aws_region
  public_subnet_ids           = module.network.public_subnet_ids
  presentation_alb_sg_id      = module.security_groups.presentation_alb_sg_id
  presentation_sg_id          = module.security_groups.presentation_sg_id
  ecs_execution_role_arn      = module.IAMRoles.ecs_execution_role_arn
  ecs_task_role_arn           = module.IAMRoles.ecs_task_role_arn
  business_logic_alb_dns_name = module.ecs-backend.business_logic_alb_dns_name
  depends_on                  = [module.IAMRoles, module.ecs-backend]
}

module "ecs-backend" {
  source                      = "./modules/ecs-backend"
  vpc_id                      = module.network.vpc_id
  aws_region                  = var.aws_region
  image_uri_backend           = var.image_uri_backend
  family_name_backend         = var.family_name_backend
  public_subnet_ids           = module.network.public_subnet_ids
  private_subnets_ids         = module.network.private_subnets_ids
  business_logic_alb_sg_id    = module.security_groups.business_logic_alb_sg_id
  business_logic_sg_id        = module.security_groups.business_logic_sg_id
  documentdb_cluster_endpoint = module.database.documentdb_cluster_endpoint
  ecs_execution_role_arn      = module.IAMRoles.ecs_execution_role_arn
  ecs_task_role_arn           = module.IAMRoles.ecs_task_role_arn
  depends_on                  = [module.IAMRoles, module.database]
}

module "database" {
  source              = "./modules/database"
  db_name             = var.db_name
  db_username         = var.db_username
  db_password         = var.db_password
  vpc_id              = module.network.vpc_id
  vpc_cidr            = module.network.vpc_cidr
  private_subnets_ids = module.network.private_subnets_ids
  DocumentDB_sg_id    = module.security_groups.DocumentDB_sg_id
  depends_on          = [module.network]
}

module "monitoring" {
  source            = "./modules/monitoring"
  image_id          = var.image_id
  key_name          = var.key_name
  public_subnet_ids = module.network.public_subnet_ids
  # private_subnet_ids = module.network.private_subnet_ids
  Monitoring_sg_id = module.security_groups.Monitoring_sg_id
  depends_on       = [module.ecs-frontend]
}
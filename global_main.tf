# Initialize the modules
module "network" {
  source = "./modules/network"
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
  public_subnet_ids           = module.network.public_subnet_ids
  business_logic_alb_sg_id    = module.security_groups.business_logic_alb_sg_id
  business_logic_sg_id        = module.security_groups.business_logic_sg_id
  documentdb_cluster_endpoint = module.database.documentdb_cluster_endpoint
  ecs_execution_role_arn      = module.IAMRoles.ecs_execution_role_arn
  ecs_task_role_arn           = module.IAMRoles.ecs_task_role_arn
  depends_on                  = [module.IAMRoles, module.database]
}

module "database" {
  source                       = "./modules/database"
  vpc_id                       = module.network.vpc_id
  vpc_cidr                     = module.network.vpc_cidr
  DocumentDB_sg                = module.security_groups.DocumentDB_sg
  public_subnet_documentDB_ids = module.network.public_subnet_documentDB_ids
  depends_on                   = [module.network]
}

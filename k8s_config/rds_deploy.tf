resource "random_string" "random" {
  length  = 2
  special = false
  lower   = true
  upper   = false
}

data "aws_secretsmanager_secret" "pwsecret" {
  name = "path/to/secret"
}

data "aws_secretsmanager_secret_version" "retrieve" {
  secret_id = data.aws_secretsmanager_secret.pwsecret.id
}

resource "aws_db_subnet_group" "subnet_group" {
  name 		    = var.subnet_group_name
  subnet_ids 	    = var.subnet_ids
}

module "rds_deploy" {
  count             = var.RDScount
  source            = "./modules/rds"
  storage           = var.minStorage
  max_storage       = var.maxStorage
  engine            = var.engine
  engine_version    = var.engineVersion
  LicenseModel      = var.License_Model
  instance          = var.instanceClass
  allow_upgrade     = var.allowUpgrade
  apply_immediately = var.applyImmediately
  dbname            = "${var.DBname}${random_string.random.result}${count.index + 1}"
  user              = var.DBuser
  password          = data.aws_secretsmanager_secret_version.retrieve.secret_string
  skip_snap         = var.skipSnapshot
  multiAZ           = var.multiAZ
  RDSTags           = var.tags
  sgIDs             = [aws_security_group.portal.id]
  subnet_group      = var.subnet_group_name

  depends_on = [
    aws_security_group.portal,
    aws_db_subnet_group.subnet_group
  ]
}

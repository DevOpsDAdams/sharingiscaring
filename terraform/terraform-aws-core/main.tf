module "pager_duty_sns" {
    source                              = "./modules/sns"
    pager_duty_integration_url          = var.pager_duty_integration_url
    par_it_support_info_url             = var.slack_chatbot_support_info_url
}

# MarkLogic
The MarkLogic project is a canonical layer for tracking data processing within OneAmerica.

# Environments
The following environments are handled by this repository
1.	Dev oa-rg-marklogic-development-001
2.	Test oa-rg-marklogic-test-001
3.	Production oa-rg-marklogic-production-001
4.	DR oa-rg-marklogic-dr-001
5.  Model (Future Deployment)

# Init and Plan
When building out and deploying to a MarkLogic environment, the following steps must be used in order to Initialize the environment, perform a plan and perform an apply.

- `terraform init -backend-config=key="mark_logic_<<env>>.tfstate"`
- `terraform plan -out='mark_logic_<<env>>.tfplan' -var-file="<<env>>/terraform.tfvars.json"`


# Apply
When the Plan completes, you'll get a message with a statement "To perform exactly these actions, run the following command to apply:"

You can then perform an apply based upon the plan, with a command similar to the following:

- `terraform apply "mark_logic_<<env>>.tfplan"`

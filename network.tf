# In the network.tf file, we set up the provider for AWS and the VPC declaration. 
# Together with the Route53 configuration, the option specified for the vpc creation enables an internal name resolution for our VPC. 
# As you may be aware, Terraform can be used to build infrastructures for many environments, such as AWS, Azure, Google Cloud, VMware, and many others. 
# A full list is available here: https://www.terraform.io/docs/providers/index.html . 
# In this article, we are using AWS as the provider.

provider "aws" {
  #access_key = "${var.aws_access_key}"
  #secret_key = "${var.aws_secret_key}"
  shared_credentials_file = "${var.credentialsfile}"

  region = "${var.region}"
}

resource "aws_vpc" "terraformmain" {
  cidr_block = "${var.vpc-fullcidr}"

  #### this 2 true values are for use the internal vpc dns resolution
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "My terraform vpc"
  }
}

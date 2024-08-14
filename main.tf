terraform {
    backend "s3" {
        bucket = "your-terraform-state-bucket-name-CHANGEME"
        #bucket = "jgray-terraform-state"
        key = "state/thing3-s3.tfstate"
        region = "us-east-1"
        encrypt = true
    }
}

provider "aws" {
  region = "us-east-1"
}

module "s3-static-web-hosting" {
    source = "./modules/s3-static-web-hosting"
    domain = "YOURDOMAINHERE.com"
    domain_alias = "www.YOURDOMAINHERE.com"
    #domain = "notnormal.cloud"
    #domain_alias = "www.notnormal.cloud"
}
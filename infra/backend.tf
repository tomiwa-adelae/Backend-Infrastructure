terraform {
  backend "s3" {
    bucket       = "terraform-state-cornerstone"
    key          = "terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
    # profile        = "cornerstone"                         
  }
}

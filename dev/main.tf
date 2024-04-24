module "dev" {
    source = "../module/blog"
    access_key = var.accesskey
    secret_key = var.secretkey
}
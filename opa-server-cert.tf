#resource "tls_self_signed_cert" "opa_server_cert_ca" {
#  is_ca_certificate     = true
#  key_algorithm         = "RSA"
#  private_key_pem       = tls_private_key.opa_server_cert_ca_key.private_key_pem
#  validity_period_hours = 87600 # 10 years
#  allowed_uses = [
#    "digital_signature",
#    "key_encipherment",
#    "client_auth",
#    "server_auth"
#  ]
#  subject {
#    common_name         = "opa.opa.svc"
#    organizational_unit = var.organizational_unit
#    organization        = var.organization
#    street_address      = var.street_address
#    locality            = var.locality
#    province            = var.province
#    postal_code         = var.postal_code
#    country             = var.country
#    serial_number       = var.serial_number
#  }
#}
#

resource "tls_private_key" "opa_server_cert_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "opa_server_cert_request" {
  key_algorithm         = "RSA"
  private_key_pem       = tls_private_key.opa_server_cert_key.private_key_pem
  subject {
    common_name  = "${kubernetes_service.opa.metadata.0.name}.${kubernetes_namespace.opa_namespace.metadata.0.name}.svc"
    organizational_unit = var.organizational_unit
    organization        = var.organization
    street_address      = var.street_address
    locality            = var.locality
    province            = var.province
    postal_code         = var.postal_code
    country             = var.country
    serial_number       = var.serial_number
  }
}

resource "kubernetes_certificate_signing_request" "opa_server_signed_cert" {
  metadata {
    name = "opa-server-cert-request"
  }
  auto_approve = true
  spec {
    usages = ["client auth", "server auth"]
    request = tls_cert_request.opa_server_cert_request.cert_request_pem
  }
}

resource "kubernetes_secret" "opa_server_cert" {
  metadata {
    name      = "opa-server-cert"
    namespace = kubernetes_namespace.opa_namespace.metadata.0.name
  }
  type = "kubernetes.io/tls"
  data = {
    "ca.crt" : var.cluster_certificate_authority
    "tls.crt" : kubernetes_certificate_signing_request.opa_server_signed_cert.certificate
    "tls.key" : tls_private_key.opa_server_cert_key.private_key_pem
  }
}
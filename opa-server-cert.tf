resource "tls_private_key" "opa_server_cert_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "opa_server_cert_request" {
  dns_names       = [kubernetes_service.opa.load_balancer_ingress[0].hostname, "${kubernetes_service.opa.metadata.0.name}.${kubernetes_namespace.opa_namespace.metadata.0.name}.svc"]
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.opa_server_cert_key.private_key_pem
  subject {
    common_name         = "${kubernetes_service.opa.metadata.0.name}.${kubernetes_namespace.opa_namespace.metadata.0.name}.svc"
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
    labels = merge({
      # Other labels go here
    }, local.resource_labels)
  }
  auto_approve = true
  spec {
    usages  = ["client auth", "server auth"]
    request = tls_cert_request.opa_server_cert_request.cert_request_pem
  }
}

resource "kubernetes_secret" "opa_server_cert" {
  metadata {
    name      = "opa-server-cert"
    namespace = kubernetes_namespace.opa_namespace.metadata.0.name
    labels = merge({
      # Other labels go here
    }, local.resource_labels)
  }
  type = "kubernetes.io/tls"
  data = {
    "ca.crt" : var.cluster_certificate_authority
    "tls.crt" : kubernetes_certificate_signing_request.opa_server_signed_cert.certificate
    "tls.key" : tls_private_key.opa_server_cert_key.private_key_pem
  }
}
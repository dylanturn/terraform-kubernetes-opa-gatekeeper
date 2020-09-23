resource "k8s_manifest" "app_projects" {
  depends_on = [kubernetes_certificate_signing_request.opa_server_signed_cert]
  content = templatefile("${path.module}/templates/webhook-configuration.yaml", {
    cluster_ca_bundle : var.cluster_certificate_authority,
    service_name : kubernetes_namespace.opa_namespace.metadata.0.name,
    service_namespace : kubernetes_service.opa.metadata.0.name
  })
}
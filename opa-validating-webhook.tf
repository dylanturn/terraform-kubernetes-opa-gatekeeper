# resource "kubernetes_validating_webhook_configuration" "opa_validating_webhook" {
#   depends_on = [kubernetes_certificate_signing_request.opa_server_signed_cert]
#   metadata {
#     name = "opa-validating-webhook"
#     labels = merge({
#     }, local.resource_labels)
#   }
#   webhook {
#     name                      = "validating-webhook.openpolicyagent.org"
#     admission_review_versions = ["v1"]
#     side_effects              = "None"
#     namespace_selector {
#       match_expressions {
#         key      = "openpolicyagent.org/webhook"
#         operator = "NotIn"
#         values = [
#           "ignore"
#         ]
#       }
#     }
#     rule {
#       api_groups   = ["*"]
#       api_versions = ["*"]
#       operations   = ["CREATE", "UPDATE"]
#       resources    = ["*"]
#     }
#     client_config {
#       ca_bundle = var.cluster_certificate_authority
#       service {
#         name      = kubernetes_service.opa.metadata.0.name
#         namespace = kubernetes_namespace.opa_namespace.metadata.0.name
#         port      = 443
#       }
#     }
#   }
# }

resource "k8s_manifest" "app_projects" {
  depends_on = [kubernetes_certificate_signing_request.opa_server_signed_cert]
  content = templatefile("${path.module}/templates/webhook-configuration.yaml", {
    cluster_ca_bundle : var.cluster_certificate_authority,
    service_name : kubernetes_namespace.opa_namespace.metadata.0.name,
    service_namespace : kubernetes_service.opa.metadata.0.name
  })
}
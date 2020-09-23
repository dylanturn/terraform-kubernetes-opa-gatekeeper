resource "kubernetes_cluster_role_binding" "opa_viewer" {
  metadata {
    name = "opa-viewer"
    labels = merge({
      # Other labels go here
    }, local.resource_labels)
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "system:serviceaccounts:opa"
    namespace = kubernetes_namespace.opa_namespace.metadata.0.name
  }
}
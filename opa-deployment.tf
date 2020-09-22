resource "kubernetes_deployment" "opa" {
  metadata {
    name      = "opa"
    namespace = kubernetes_namespace.opa_namespace.metadata.0.name
    labels = merge({
      "app" : "opa"
    }, local.resource_labels)
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app" : "opa"
      }
    }
    template {
      metadata {
        name      = "opa"
        namespace = kubernetes_namespace.opa_namespace.metadata.0.name
        labels = merge({
          "app" : "opa"
        }, local.resource_labels)
      }
      spec {
        container {
          # WARNING: OPA is NOT running with an authorization policy configured. This
          # means that clients can read and write policies in OPA. If you are
          # deploying OPA in an insecure environment, be sure to configure
          # authentication and authorization on the daemon. See the Security page for
          # details: https://www.openpolicyagent.org/docs/security.html.
          name  = "opa"
          image = "${var.image_repository}/${var.opa_image_name}:${var.opa_version}"
          args = [
            "run",
            "--server",
            "--tls-cert-file=/certs/tls.crt",
            "--tls-private-key-file=/certs/tls.key",
            "--addr=0.0.0.0:443",
            "--addr=http://127.0.0.1:8181"
          ]
          volume_mount {
            name       = "opa-server"
            mount_path = "/certs"
            read_only  = true
          }
        }
        container {
          name  = "kube-mgmt"
          image = "${var.image_repository}/${var.kube_mgmt_image_name}:${var.kube_mgmt_version}"
          args = [
            "--replicate-cluster=v1/namespaces",
            "--replicate=extensions/v1beta1/ingresses"
          ]
          volume_mount {
            name = "opa-service-account-token"
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount/token"
          }
        }
        volume {
          name = "opa-service-account-token"
          secret {
            secret_name = kubernetes_secret.namespace_default_token.metadata.0.name
          }
        }
        volume {
          name = "opa-server"
          secret {
            secret_name = kubernetes_secret.opa_server_cert.metadata.0.name
          }
        }
      }
    }
  }
}
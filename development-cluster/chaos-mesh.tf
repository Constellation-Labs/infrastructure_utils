resource "helm_release" "chaos_mesh" {
  namespace        = "chaos-mesh"
  create_namespace = true

  name       = "chaos-mesh"
  repository = "https://charts.chaos-mesh.org"
  chart      = "chaos-mesh"
  version    = "2.4.2"

  set {
    name  = "controllerManager.replicaCount"
    value = 1
  }

}
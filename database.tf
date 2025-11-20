##################################################################
########################## DATABASE ##############################
##################################################################

data "kubectl_path_documents" "db_doc" {
  pattern = "../k8s/db/*.yaml"
}

resource "kubectl_manifest" "db_manifest" {
  for_each   = data.kubectl_path_documents.db_doc.manifests
  yaml_body  = each.value
  #depends_on = [kubectl_manifest.gp2_default]
}
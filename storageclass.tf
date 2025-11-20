resource "kubectl_manifest" "oficina_gp2" {
  yaml_body = <<YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: oficina-gp2
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
parameters:
  type: gp2
  fsType: ext4
allowVolumeExpansion: true
reclaimPolicy: Delete
YAML
}

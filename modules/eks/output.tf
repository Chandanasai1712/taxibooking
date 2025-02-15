output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "cluster_id_value" {
  value = aws_eks_cluster.eks.cluster_id
}
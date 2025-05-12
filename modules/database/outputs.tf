output "documentdb_cluster_endpoint" {
  value       = aws_docdb_cluster.documentdb_cluster.endpoint
  description = "The primary endpoint of the Amazon DocumentDB Cluster."
}
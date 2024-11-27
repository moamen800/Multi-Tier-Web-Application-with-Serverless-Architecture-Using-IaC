####################################### CloudFront Distribution #######################################
resource "aws_cloudfront_distribution" "cdn" {
  enabled = true # Enable CloudFront distribution to accept end-user requests

  # Origin: ALB for dynamic content
  origin {
    domain_name = var.presentation_alb_dns_name    # ALB DNS name as origin
    origin_id   = "ALB-${var.presentation_alb_id}" # Unique origin ID
    custom_origin_config {
      http_port              = 80             # ALB HTTP port
      https_port             = 443            # Optional: if you configure SSL for ALB
      origin_protocol_policy = "match-viewer" # Allow both HTTP and HTTPS traffic based on viewer's protocol
      origin_ssl_protocols   = ["TLSv1.2"]    # Set valid SSL protocols for HTTPS traffic
    }
  }

  # Default cache behavior: Handling of content by CloudFront 
  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "POST", "PUT", "OPTIONS", "PATCH", "DELETE"] # Allow all necessary methods
    cached_methods           = ["GET", "HEAD", "OPTIONS"]                                   # Cache only the essential methods
    target_origin_id         = "ALB-${var.presentation_alb_id}"                             # Reference the ALB origin
    viewer_protocol_policy   = "allow-all"                                                  # Allow both HTTP and HTTPS traffic
    min_ttl                  = 60                                                           # Minimum cache TTL (1 minute)
    default_ttl              = 600                                                          # Default TTL (10 minutes)
    max_ttl                  = 900                                                          # Maximum TTL (15 minutes)
    compress                 = true                                                         # Enable automatic compression of objects
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"                       # Managed Cache Policy for optimized caching
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"                       # Managed Origin Request Policy
  }

  # Geo restriction
  restrictions {
    geo_restriction {
      restriction_type = "whitelist" # Allow only countries in the locations list
      locations        = ["EG"]      # Country code for Egypt
    }
  }

  # CloudFront Viewer Certificate (SSL for HTTPS traffic)
  viewer_certificate {
    cloudfront_default_certificate = true # Use CloudFront's default SSL certificate for HTTPS traffic
  }

  # Attach WAF Web ACL for additional security
  web_acl_id = aws_wafv2_web_acl.WAF_presentation_acl.arn # Attach the WAF Web ACL
}

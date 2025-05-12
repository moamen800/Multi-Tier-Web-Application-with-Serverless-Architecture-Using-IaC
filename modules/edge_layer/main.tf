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

  # Geo restriction: no restrictions (open globally)
  restrictions {
    geo_restriction {
      restriction_type = "whitelist" # Allow only countries in the locations list
      locations        = ["EG"]      # Country code for Egypt
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # Attach WAF Web ACL for additional security
  web_acl_id = aws_wafv2_web_acl.WAF_presentation_acl.arn # Attach the WAF Web ACL
}



######################################## WAF Web ACL #######################################
resource "aws_wafv2_web_acl" "WAF_presentation_acl" {
  name        = "WAF-Presentation-ACL"                                     # Name of the Web ACL
  description = "Blocks IPs from Egypt exceeding 1k requests in 5 minutes" # Description of the Web ACL
  scope       = "CLOUDFRONT"                                               # This ACL is for CloudFront distribution
  provider    = aws.us_east_1                                              # Specify the AWS provider for us-east-1 region

  # Default action to allow all requests
  default_action {
    allow {}
  }

  # Rule for Rate-Based Condition (Egypt-based)
  rule {
    name     = "RateBasedRule-Egypt" # Name of the rate-based rule
    priority = 1                     # Rule priority, lower number means higher priority

    action {
      block {
        custom_response {
          response_code = 403 # Set the HTTP response code to 403 Forbidden
        }
      }
    }

    statement {
      rate_based_statement {
        limit              = 500  # Max requests allowed per 5-minute window
        aggregate_key_type = "IP" # Aggregate rate limit by IP address

        scope_down_statement {
          geo_match_statement {
            country_codes = ["EG"] # Scope the rate-based rule down to Egypt (EG) only
          }
        }
      }
    }

    # CloudWatch metrics configuration for visibility
    visibility_config {
      cloudwatch_metrics_enabled = true                  # CloudWatch metrics are disabled
      metric_name                = "RateBasedRuleMetric" # Metric name for this rule
      sampled_requests_enabled   = true                  # Enable sampled requests for analysis
    }
  }

  # Rule for AWS Managed Common Rule Set
  rule {
    name     = "AWS-CommonRuleSet" # Name of the rule
    priority = 2                   # Rule priority, lower number means higher priority

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet" # Common AWS managed rule group
        vendor_name = "AWS"                          # Vendor of the rule set 
      }
    }

    # CloudWatch metrics configuration for visibility
    visibility_config {
      cloudwatch_metrics_enabled = true                     # CloudWatch metrics are disabled
      metric_name                = "AWSCommonRuleSetMetric" # Metric name for this rule
      sampled_requests_enabled   = true                     # Enable sampled requests for analysis
    }
  }

  # Visibility configuration for the entire Web ACL
  visibility_config {
    cloudwatch_metrics_enabled = true                       # CloudWatch metrics for the Web ACL
    metric_name                = "WAFPresentationACLMetric" # Metric name for the Web ACL
    sampled_requests_enabled   = true                       # Enable sampled requests for analysis
  }
}

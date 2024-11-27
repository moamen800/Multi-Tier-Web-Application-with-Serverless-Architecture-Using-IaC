resource "aws_wafv2_web_acl" "WAF_presentation_acl" {
  name        = "WAF-Presentation-ACL"                       # Name of the Web ACL
  description = "WAF ACL to protect CloudFront distribution" # Description of the ACL
  scope       = "CLOUDFRONT"                                 # This ACL is for CloudFront distribution

  # Default action to block all requests
  default_action {
    allow {}
  }

  # Rule for AWS Managed Common Rule Set
  rule {
    name     = "AWS-CommonRuleSet" # Name of the rule
    priority = 1                   # Rule priority, lower number means higher priority

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
      cloudwatch_metrics_enabled = false                    # Enable CloudWatch metrics
      metric_name                = "AWSCommonRuleSetMetric" # Metric name for this rule
      sampled_requests_enabled   = false                    # Enable sampled requests for analysis
    }
  }

  # Visibility configuration for the entire Web ACL
  visibility_config {
    cloudwatch_metrics_enabled = false                      # Enable CloudWatch metrics for the Web ACL
    metric_name                = "WAFPresentationACLMetric" # Metric name for the Web ACL
    sampled_requests_enabled   = false                      # Enable sampled requests for analysis
  }
}


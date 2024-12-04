resource "aws_wafv2_web_acl" "WAF_presentation_acl" {
  name        = "WAF-Presentation-ACL"                       # Name of the Web ACL
  description = "WAF ACL to protect CloudFront distribution" # Description of the ACL
  scope       = "CLOUDFRONT"                                 # This ACL is for CloudFront distribution

  # Default action to allow all requests
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
      cloudwatch_metrics_enabled = false                    # CloudWatch metrics are disabled
      metric_name                = "AWSCommonRuleSetMetric" # Metric name for this rule
      sampled_requests_enabled   = false                    # Enable sampled requests for analysis
    }
  }

  # Rule for Rate-Based Condition (Egypt-based)
  rule {
    name     = "RateBasedRule-Egypt"  # Name of the rate-based rule
    priority = 2                      # Rule priority, lower number means higher priority

    action {
      block {
        custom_response {
          response_code = 403 # Set the HTTP response code to 403 Forbidden
        }
      }
    }

    statement {
      rate_based_statement {
        limit              = 10000           # Max requests allowed per 5-minute window
        aggregate_key_type = "IP"            # Aggregate rate limit by IP address

        scope_down_statement {
          geo_match_statement {
            country_codes = ["EG"]    # Scope the rate-based rule down to Egypt (EG) only
          }
        }
      }
    }

    # CloudWatch metrics configuration for visibility
    visibility_config {
      cloudwatch_metrics_enabled = false                    # CloudWatch metrics are disabled
      metric_name                = "RateBasedRuleMetric"    # Metric name for this rule
      sampled_requests_enabled   = false                    # Enable sampled requests for analysis
    }
  }

  # Visibility configuration for the entire Web ACL
  visibility_config {
    cloudwatch_metrics_enabled = false                      # CloudWatch metrics for the Web ACL
    metric_name                = "WAFPresentationACLMetric" # Metric name for the Web ACL
    sampled_requests_enabled   = false                      # Enable sampled requests for analysis
  }
}

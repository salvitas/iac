locals {
  appsync_origin = "AppSyncOrigin"
  static_web_origin = "S3OriginStaticWebContent"
  static_app_origin = "S3OriginAppContent"
}

data "aws_route53_zone" "selected" {
  name         = var.hosted_zone_name
  private_zone = false
}

provider "aws" {
  alias = "virginia"
  region = "us-east-1"
}

data "aws_acm_certificate" "issued" {
  domain   = var.cert_name
  provider = aws.virginia // ACM certs for CloudFront needs to be in this region! https://docs.aws.amazon.com/acm/latest/userguide/acm-regions.html
  statuses = ["ISSUED"]
}

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  aliases = ["${terraform.workspace}.${data.aws_route53_zone.selected.name}"]

  origin {
    origin_id   = local.appsync_origin
    domain_name = var.appsync_domain_name
    origin_path = ""
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = ["TLSv1.2", "SSLv3"]
    }
  }

  origin {
    origin_id   = local.static_web_origin
    domain_name = var.static_bucket_domain
    origin_path = "/web"
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = ["TLSv1.2", "SSLv3"]
    }
  }

  origin {
    origin_id   = local.static_app_origin
    domain_name = var.static_bucket_domain
    origin_path = "/app"
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = ["TLSv1.2", "SSLv3"]
    }
  }

  default_cache_behavior {
    target_origin_id = local.static_web_origin
    allowed_methods  = ["HEAD", "GET"]
    cached_methods   = ["HEAD", "GET"]
//    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized (https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html)
    compress = true
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    target_origin_id = local.appsync_origin
    path_pattern     = "/graphql*"
    allowed_methods  = ["HEAD", "GET", "OPTIONS", "PUT", "PATCH", "POST", "DELETE"]
    cached_methods   = ["HEAD", "GET"]
//    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # Managed-CachingDisabled https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html
//    origin_request_policy_id = "7a5990bc-5246-4035-8bdb-30036881d9cb" // TBR

    forwarded_values {
      query_string = false
      headers      = ["*"]

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "https-only"
  }

  ordered_cache_behavior {
    target_origin_id = local.static_app_origin
    path_pattern     = "/app/*"
    allowed_methods  = ["HEAD", "GET"]
    cached_methods   = ["HEAD", "GET"]
//    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingDisabled https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    compress = true
    viewer_protocol_policy = "redirect-to-https"
  }


  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for the AppSync API and static web site"
  default_root_object = "index.html"
  http_version = "http2"
  price_class = "PriceClass_100" // Small class = Only U.S, Canada and Europe | 200 = + Asia & Africa | 300 = All Worldwide Cloudfront

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.issued.arn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
    cloudfront_default_certificate = false
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

//  logging_config {
//    include_cookies = false
//    bucket          = "mylogs.s3.amazonaws.com"
//  }
}

resource "aws_route53_record" "graphql" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${terraform.workspace}.${data.aws_route53_zone.selected.name}"
  type    = "A"
  alias {
    evaluate_target_health = false
    name = aws_cloudfront_distribution.cloudfront_distribution.domain_name
    zone_id = aws_cloudfront_distribution.cloudfront_distribution.hosted_zone_id
  }

}
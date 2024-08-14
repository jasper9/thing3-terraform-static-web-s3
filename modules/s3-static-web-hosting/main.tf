// SECTION - S3 for var.domain -----------------------------------------------------

resource "aws_s3_bucket" "domain" {
    bucket = var.domain
    force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "domain" {
    depends_on = [aws_s3_bucket.domain]
    bucket = var.domain
    index_document {
        suffix = "index.html"
    }

    error_document {
        key = "error.html"
    }
}

resource "aws_s3_bucket_ownership_controls" "domain" {
  depends_on = [aws_s3_bucket.domain]
  bucket = var.domain
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "domain" {
  bucket = aws_s3_bucket.domain.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "domain" {
  depends_on = [
    aws_s3_bucket_ownership_controls.domain,
    aws_s3_bucket_public_access_block.domain,
  ]

  bucket = aws_s3_bucket.domain.id
  acl    = "public-read"
}

resource "aws_s3_object" "domain" {
  depends_on = [ aws_s3_bucket_ownership_controls.domain ]
  bucket = aws_s3_bucket.domain.id
  key    = "index.html"
  source = "example_index.html"
  acl    = "public-read"
  content_type = "text/html"
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  depends_on = [ aws_s3_bucket_ownership_controls.domain ]
  bucket = aws_s3_bucket.domain.id
  policy = templatefile("./s3-policy.json", { bucket = var.domain })
}


// SECTION - S3 for var.domain_alias -----------------------------------------------------

resource "aws_s3_bucket" "domain_alias" {
    bucket = var.domain_alias
    force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "domain_alias" {
    depends_on = [aws_s3_bucket.domain_alias]
    bucket = var.domain_alias
    redirect_all_requests_to {
        host_name = var.domain
  }
}


// SECTION - ROUTE53 -----------------------------------------------------

resource "aws_route53_zone" "domain" {
    name = var.domain
}

resource "aws_route53_record" "a" {
    depends_on = [aws_s3_bucket_website_configuration.domain]
    zone_id = aws_route53_zone.domain.zone_id
    name = var.domain
    type = "A"

    alias {
        name = aws_s3_bucket_website_configuration.domain.website_endpoint
        zone_id = aws_s3_bucket.domain.hosted_zone_id
        evaluate_target_health = false
    }
}

resource "aws_route53_record" "www" {
    depends_on = [aws_s3_bucket_website_configuration.domain]
    zone_id = aws_route53_zone.domain.zone_id
    name = "www.${var.domain}"
    type = "A"

    alias {
      name = aws_s3_bucket_website_configuration.domain.website_endpoint
      zone_id = aws_s3_bucket.domain.hosted_zone_id
      evaluate_target_health = false
    }
}
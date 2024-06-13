resource "aws_s3_bucket" "manas_test_site" {
    bucket = var.site_domain
  
}

resource "aws_s3_bucket_public_access_block" "manas_test_site" {
bucket = aws_s3_bucket.manas_test_site.id
block_public_policy = false
block_public_acls = false
ignore_public_acls = false
restrict_public_buckets = false
  
}

resource "aws_s3_bucket_website_configuration" "manas_test_site" {
  bucket = aws_s3_bucket.manas_test_site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "manas_test_site" {
  bucket = aws_s3_bucket.manas_test_site.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "manas_test_site" {
  bucket = aws_s3_bucket.manas_test_site.id

  acl = "public-read"
  depends_on = [
    aws_s3_bucket_ownership_controls.manas_test_site,
    aws_s3_bucket_public_access_block.manas_test_site
  ]
}

resource "aws_s3_bucket_policy" "manas_test_site" {
  bucket = aws_s3_bucket.manas_test_site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [aws_s3_bucket.manas_test_site.arn,
          "${aws_s3_bucket.manas_test_site.arn}/*",
        ]
      },
    ]
  })

  depends_on = [
    aws_s3_bucket_public_access_block.manas_test_site
  ]
}

data "cloudflare_zones" "domain" {
  filter {
    name = var.site_domain
  }
}

resource "cloudflare_record" "site_cname" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = var.site_domain
  value   = aws_s3_bucket_website_configuration.manas_test_site.website_endpoint
  type    = "CNAME"

  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "www" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = "www"
  value   = var.site_domain
  type    = "CNAME"

  ttl     = 1
  proxied = true
}
output "public-ip-address"{
    value = aws_instance.example-ec2-instance.public_ip
}
output "s3-bucket-endpoint"{
    value = aws_s3_bucket_website_configuration.example-website.website_endpoint
}
#provider details
provider "aws"{
    region = var.aws_region
}
#ec2 instance creation
resource "aws_instance" "example-ec2-instance"{
    ami = var.ami_id
    instance_type = "t2.micro"
    tags ={
        Name = "ec2-terraform" #name of the instance to be created
    }
}
#s3 bucket creation
resource "aws_s3_bucket" "example-s3-bucket"{
    bucket = "vidhu-terraform-s3-bucket"
}
#s3 bucket website configuration
resource "aws_s3_bucket_website_configuration" "example-website"{
    bucket = aws_s3_bucket.example-s3-bucket.id
    index_document {
        suffix = "index.html"
    } 
}
#s3 bucket public access block to allow public access
resource "aws_s3_bucket_public_access_block" "example-public-access-block"{
    bucket = aws_s3_bucket.example-s3-bucket.id
    block_public_acls = false
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false
}

#uploading index.html and hello1.txt and hello2.txt to s3 bucket
resource "aws_s3_object" "index-object"{
    bucket = aws_s3_bucket.example-s3-bucket.id
    key = "index.html"
    source = "./index.html"
    content_type = "text/html"
}

resource "aws_s3_object" "object1"{
    bucket = aws_s3_bucket.example-s3-bucket.id
    key = "hello1.txt"
    source = "./hello1.txt"
    content_type = "text/html"  
}
resource "aws_s3_object" "object2"{
    bucket = aws_s3_bucket.example-s3-bucket.id
    key = "hello2.txt"
    source = "./hello2.txt"
    content_type = "text/html"  
}
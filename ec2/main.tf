provider "aws" {
    region ="ap-southeast-2"
}
resource "aws_instance" "example" {
    ami = "ami-0a8f40a451672ea1d"
    instance_type = "t2.micro"
}
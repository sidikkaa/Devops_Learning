provider "aws" {
  region = "us-east-1"
}
 
# --- VPC ---
resource "aws_vpc" "xops_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "xops-vpc" }
}
 
# --- Subnet ---
resource "aws_subnet" "xops_subnet" {
  vpc_id                  = aws_vpc.xops_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "xops-subnet" }
}
 
# --- Internet Gateway ---
resource "aws_internet_gateway" "xops_igw" {
  vpc_id = aws_vpc.xops_vpc.id
  tags   = { Name = "xops-igw" }
}
 
# --- Route Table ---
resource "aws_route_table" "xops_rt" {
  vpc_id = aws_vpc.xops_vpc.id
 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.xops_igw.id
  }
  tags = { Name = "xops-rt" }
}
 
# --- Associate Route Table with Subnet ---
resource "aws_route_table_association" "xops_rta" {
  subnet_id      = aws_subnet.xops_subnet.id
  route_table_id = aws_route_table.xops_rt.id
}
 
# --- Security Group ---
resource "aws_security_group" "xops_sg" {
  name        = "xops-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.xops_vpc.id
 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  tags = { Name = "xops-sg" }
}
 
# --- EC2 Instance ---
resource "aws_instance" "xops_web" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.xops_subnet.id
  vpc_security_group_ids = [aws_security_group.xops_sg.id]
  key_name      = "ec2" # Your EC2 key pair name in AWS
 
  tags = { Name = "xops-webserver" }
 
  # Copy HTML file
  provisioner "file" {
    source      = "index.html"
    destination = "/tmp/index.html"
 
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("ec2.pem")
      host        = self.public_ip
    }
  }
 
  # Install Apache and move file
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
      "sudo mv /tmp/index.html /var/www/html/index.html",
      "sudo chown apache:apache /var/www/html/index.html"
    ]
 
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("ec2.pem")
      host        = self.public_ip
    }
  }
}
 
# Output public IP
output "web_public_ip" {
  value = aws_instance.xops_web.public_ip
}
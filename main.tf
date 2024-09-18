
resource "aws_s3_bucket" "s3_bucket" {
  bucket         = var.s3
}

resource "aws_key_pair" "kp" {
  key_name = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_vpc" "myvpc" {
  
  cidr_block = var.vpc_cidr
  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = var.subnet_cidr
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true


  tags = {
    Name = "Public_subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.subnet1.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_security_group" "webSg" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name =" my-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "in_rule1" {
    description = "http traffic"
  security_group_id = aws_security_group.webSg.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 80
  to_port = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "in_rule2" {
  description = "ssh connection"
  security_group_id = aws_security_group.webSg.id
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 22
  to_port = 22
}

resource "aws_vpc_security_group_egress_rule" "out_rule1" {
    description = "Allow all outbound traffic"
    security_group_id = aws_security_group.webSg.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"    
  
}

resource "aws_instance" "myinstance" {

    ami = var.ec2_ami
    instance_type = var.instance_type
    key_name = aws_key_pair.kp.key_name
    vpc_security_group_ids = [aws_security_group.webSg.id]
    subnet_id = aws_subnet.subnet1.id

    tags = {
      Name = "web_server"
    }

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host = self.public_ip
    }


  provisioner "file" {
    source = "app.py"
    destination = "/home/ubuntu/app.py"
  }

  provisioner "file" {
    source = "cmd_script.sh"
    destination = "/home/ubuntu/cmd_script.sh"
  }

  provisioner "remote-exec" {
  inline = [
    "sudo bash ./cmd_script.sh"
  ]
}

    
}
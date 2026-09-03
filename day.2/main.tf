resource "aws_vpc" "my_vpc" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = "my_vpc"
    
    }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = var.public_subnet_cidr
    availability_zone = var.public_az
    map_public_ip_on_launch = true
    tags = {
        Name = "my_subnet"
    }
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = var.private_subnet_cidr
    availability_zone = var.private_az
    tags = {
        Name = "private_subnet"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
        Name = "igw"
    
    }
} 
resource "aws_eip" "nat_eip" {
    domain ="vpc"
    tags = {
        Name = "nat_eip"
    }
}
resource "aws_nat_gateway" "nat" {
    subnet_id = aws_subnet.public_subnet.id
    allocation_id = aws_eip.nat_eip.id
    tags = {
        Name = "nat-gateway"
    }
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.my_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "public_route_table"

    }
} 
resource "aws_route_table_association" "public_route_table_association" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.my_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat.id
    }
    tags = {
        Name = "private-route_table"

    }
}
resource "aws_route_table_association" "private_route_table_association" {
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private_route_table.id

}
resource "aws_security_group" "sg" {
    name        = "my_sg"
    description = "my_sg"
    vpc_id      = aws_vpc.my_vpc.id

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
}
resource "aws_instance" "public_instance" {
    ami                         = var.ami_id
    instance_type               = var.instance_type
    key_name                    = var.key_name
    count                       = 2
    vpc_security_group_ids      = [aws_security_group.sg.id]
    subnet_id                   = aws_subnet.public_subnet.id
    associate_public_ip_address = true
    user_data                   = file("${path.module}/user_data.sh")

    root_block_device {
        volume_size = var.volume_size
        volume_type = var.volume_type
    }

    tags = {
        Name = "public_instance"
    }
}
resource "aws_instance" "private_instance" {
    ami                    = "ami-090d68841c2a28756"
    instance_type          = "t3.micro"
    key_name               = "pem-1"
    count                  = 2
    vpc_security_group_ids = [aws_security_group.sg.id]
    subnet_id              = aws_subnet.private_subnet.id
    user_data              = file("${path.module}/user_data.sh")

    tags = {
        Name = "private_instance"
    }
}
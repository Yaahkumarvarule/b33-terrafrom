data "aws_vpc" "default" {
    default = true
}
resource "aws_security_group" "sg" {
    name = "sg_group"
    description = "sg"
    vpc_id = data.aws_vpc.default.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        name = "ec2_sg"
    }
}
resource "aws_instance" "ec2" {
    ami      = var.ami
    instance_type = var.instance_type
    key_name = var.key_name
    vpc_security_group_ids = [aws_security_group.sg.id]
    user_data = file("root/terraform-b33/day-2/user_data.sh")

    root_block_device {
        volume_size = var.volume_size
        volume_type = var.volume_type

    }
    tags = {
        Name = "ec2"
    
    }
}
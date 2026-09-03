variable "vpc_cidr" {
    default= "10.0.0.0/16"

}
variable "public_subnet_cidr" {
    default = "10.0.0.0/20"
}
variable "private_subnet_cidr" {
    default = "10.0.16.0/20"

}
variable "public_az" {
    default = "ap-south-1a"

}
variable "private_az" {
    default = "ap-south-1a"

}
variable "instance_type" {
    default = "t3.micro"

}
variable "ami_id" {
    default = "ami-090d68841c2a28756"

}
variable "key_name" {
    default = "pem-1" 
}

variable "volume_size" {
    default = 10
}
variable "volume_type" {
    default = "gp3"
}
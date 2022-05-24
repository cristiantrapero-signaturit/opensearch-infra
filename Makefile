all:

init:
	terraform init

plan:
	terraform plan

apply:
	terraform apply

install-terraform:
	./install-terraform.sh
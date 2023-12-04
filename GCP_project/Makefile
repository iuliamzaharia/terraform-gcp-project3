init:
	terraform init 
	
build:
	terraform plan && terraform apply -auto-approve

destroy:
	terraform init && terraform destroy -auto-approve

cleanup:
	find / -type d  -name ".terraform" -exec rm -rf {} \;
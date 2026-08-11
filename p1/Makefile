all: 
	vagrant up

up: all

list:
	vboxmanage list vms

validate: 
	vagrant validate

status:
	vagrant status

clean: 
	vagrant destroy -f

fclean: clean
	vagrant global-status --prune

.phony: all up list validate status clean fclean

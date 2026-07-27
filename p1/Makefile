all: 
	vagrant up

up: all

clean: 
	vagrant destroy -f

list:
	vboxmanage list vms

validate: 
	vagrant validate

.phony: all up clean validate list
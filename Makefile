build:
	docker build -t bryandollery/pipacker .

run:
	docker run -it --rm bryandollery/pipacker bash 

pack:
	docker run -it --rm -v $$(pwd)/raspbian.json:/root/raspbian.json -v $$(pwd)/rpi-provisioner.sh:/root/rpi-provisioner.sh -w /root bryandollery/pipacker packer build raspbian.json

pack2:
	docker run -it --rm -v $$(pwd)/raspbian.json:/usr/local/bin/raspbian.json -v $$(pwd)/rpi-provisioner.sh:/usr/local/bin/rpi-provisioner.sh -w /usr/local/bin bryandollery/pipacker packer build raspbian.json

#
# owfs - OneWire Server
# - data comes from devices on the OnwWire bus (see owfs.conf)
# - exposes owserver on port 4304 for others
#
# NOTE: Incomplete. Have not tested. 
# NOTE: Not sure how to access USB from Docker
# NOTE: Not sure where I'm going to put the owfs.conf file...
#
VM_NAME=owfs
DOCKER_IMAGE=stephenhouser/owfs
DATA_VOLUME=${VM_NAME}_data

include ../makefile.vars

ls:
	-@docker ps -a | grep ${VM_NAME} || echo "No container named: ${VM_NAME}"
	-@docker volume ls | grep ${DATA_VOLUME} || echo "No volume(s) named: ${DATA_VOLUME}"

volume:
	@echo "Creating volume ${DATA_VOLUME}..."
	docker volume create ${DATA_VOLUME}
	# Use a helper to copy initial setup files to the volume
	docker run -d -v ${DATA_VOLUME}:/data --name helper busybox true
	docker cp owfs.conf helper:/data/owfs.conf
	docker rm helper

build:
	docker build -t ${DOCKER_IMAGE}:latest .

container: build
	@echo "Creating container ${VM_NAME}..."
	docker run -d \
		--name ${VM_NAME} \
		-v ${DATA_VOLUME}/owfs.conf:/etc/owfs.conf:ro \
		-p 4304:4304 \
		${DOCKER_IMAGE}
# does the volume line above work? I just stuck it in there and have not tested.

start:
	@echo "Starting container ${VM_NAME}..."
	-@docker ps -a | grep ${VM_NAME} && docker start ${VM_NAME}

attach:
	-@docker ps -a | grep ${VM_NAME} && docker exec -it ${VM_NAME} /bin/sh

console:
	-@docker ps -a | grep ${VM_NAME} && docker attach ${VM_NAME}

stop:
	@echo "Stopping container ${VM_NAME}..."
	-@docker ps -a | grep ${VM_NAME} && docker stop ${VM_NAME}

clean-volume:
	@echo "Removing volume ${DATA_VOLUME}..."
	-@docker volume ls | grep ${DATA_VOLUME} && docker volume rm ${DATA_VOLUME}

clean: stop
	@echo "Removing container ${VM_NAME}..."
	-@docker ps -a | grep ${VM_NAME} && docker rm ${VM_NAME}

distclean: clean clean-volume
	@echo "Cleaning up volumes and images..."
	-@docker volume prune -f
	-@docker image prune -f

DOCKER_IMAGE_NAME = hdlcores:latest


help:  ## Shows the available targets
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'


build-docker:  ## Build the docker used for development
	docker build --tag ${DOCKER_IMAGE_NAME} -f Dockerfile .


.DEFAULT_GOAL := help
.PHONY: help build-docker

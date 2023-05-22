define run_in_container
	docker run -it --rm \
		-v $(PWD):/code -w /code \
		${DOCKER_IMAGE_NAME} $(1)
endef

DOCKER_IMAGE_NAME = hdlcores:latest


help:  ## Shows the available targets
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'


build-docker:  ## Build the docker used for development
	docker build --tag ${DOCKER_IMAGE_NAME} -f Dockerfile .


dockershell:  ## Run the development container
	@$(call run_in_container, bash)


.DEFAULT_GOAL := help
.PHONY: help build-docker dockershell

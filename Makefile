include project.cfg

DOCKER = DOCKER_BUILDKIT=1 docker

BUILD_DIR = .build

IMAGE_TAGS = latest $(tag) tools tests
IMAGES = $(foreach tag,$(IMAGE_TAGS),$(repo):$(tag))

# Runtime containers
CONTAINER_NAME = $(repo)

default: build
.PHONY: FORCE clean build run 
FORCE:

# Utility rules
# -------------

# $(BUILD_DIR) is used for targets
clean:
	rm -Rf $(BUILD_DIR)
	docker rmi $(IMAGES) || true

$(BUILD_DIR):
	mkdir $(BUILD_DIR)


# -- Vanilla Build Rules --
$(BUILD_DIR)/build: Dockerfile | $(BUILD_DIR)
	$(DOCKER) build \
		--tag $(repo):latest \
		--tag $(repo):$(tag) \
		.
	touch $(BUILD_DIR)/build


build: $(BUILD_DIR)/build


run: $(BUILD_DIR)/build
	docker run --rm \
		--publish=8888:8888 \
		--name="$(CONTAINER_NAME)" \
		--volume $(pwd):/home/jovyan \
		--user=$(id -u) \
		--group-add users \
		$(repo):latest
		
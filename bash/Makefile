platform = linux/amd64
repo = harbor.cyverse.org/vice/cli/bash
tag = gpu-24.04
repotag = $(repo):$(tag)

build:
	docker buildx build --rm --platform "$(platform)" -t "$(repotag)" .

push:
	docker push "$(repotag)"

rmi:
	socker rmi "$(repotag)"

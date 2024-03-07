build:
	docker run --rm -v $(shell pwd):/app -w/app --privileged debian:bookworm /bin/bash build.sh
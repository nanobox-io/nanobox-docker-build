all: build publish

stability?=latest

login:
	@vagrant ssh -c "docker login"

build:
	@echo "Building 'build' image..."
	@vagrant ssh -c "docker build -t nanobox/build /vagrant"

build-pre:
	@echo "Building 'pre-build' image..."
	@vagrant ssh -c "docker build -t nanobox/pre-build /vagrant/pre-build"

publish:
	@echo "Tagging 'build' image..."
	@vagrant ssh -c "docker tag -f nanobox/build nanobox/build:${stability}"
	@echo "Publishing 'build:${stability}'..."
	@vagrant ssh -c "docker push nanobox/build:${stability}"

publish-pre:
	@echo "Publishing 'pre-build'..."
	@vagrant ssh -c "docker push nanobox/pre-build"

pre: build-pre publish-pre

clean:
	@echo "Removing all images..."
	@vagrant ssh -c "docker rmi $(docker images -q)"

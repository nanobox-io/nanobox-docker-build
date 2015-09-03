all: stable

login:
	@vagrant ssh -c "docker login"

build:
	@echo "Building 'build' image..."
	@vagrant ssh -c "docker build -t nanobox/build /vagrant"

build-pre:
	@echo "Building 'pre-build' image..."
	@vagrant ssh -c "docker build -t nanobox/pre-build /vagrant/pre-build"

publish:
	@echo "Publishing 'build' image..."
	@vagrant ssh -c "docker push nanobox/build"

publish-alpha:
	@echo "Tagging 'build' image..."
	@vagrant ssh -c "docker tag nanobox/build nanobox/build:alpha"
	@echo "Publishing 'build:alpha'..."
	@vagrant ssh -c "docker push nanobox/build:alpha"

publish-pre:
	@echo "Publishing 'pre-build'..."
	@vagrant ssh -c "docker push nanobox/pre-build"

pre: build-pre publish-pre

stable: build publish

alpha: build publish-alpha

clean:
	@echo "Removing all images..."
	@vagrant ssh -c "docker rmi $(docker images -q)"
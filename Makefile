build:
	docker build -f Dockerfile . -t r15ch13/excavator
	docker build -f caddy.Dockerfile . -t r15ch13/excavator-caddy

clean:
	docker image rm r15ch13/excavator ||:
	docker image rm r15ch13/excavator-caddy ||:

push:
	docker image push r15ch13/excavator
	docker image push r15ch13/excavator-caddy

all: clean build push

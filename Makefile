# Makefile based demo for Torizon implementation
#
TCB = DOCKER_HUB_USERNAME="${DOCKER_HUB_USERNAME}" DOCKER_HUB_PASSWORD="${DOCKER_HUB_PASSWORD}" ./tcb.sh

all: build-tezi tcb-env-setup.sh settings.mk

settings.mk: settings.mk.in
	cp settings.mk.in settings.mk; \
	echo "Please edit settings.mk and rerun make"; \
	false

include settings.mk

.PHONY: build-tezi

build-tezi: stamps/build-tezi

stamps/build-tezi: stamps/build-hello-react tcbuild.yaml stamps/docker-image stamps/changes
	rm -rf tezi-output; ${TCB} build; \
	touch $@

stamps/docker-image: Dockerfile
	docker build -t ${DOCKERIMAGE} .; \
	touch $@

tcbuild.yaml:
	@${TCB} build --create-template; \
	grep -v '>>' tcbuild.yaml > tcbuild-clean.yaml; \
	mv -f tcbuild-clean.yaml tcbuild.yaml

stamps/build-hello-react: stamps/create-hello-react
	(cd hello-react && npm run build); \
	touch $@

stamps/create-hello-react:
	mkdir hello-react-git && mv hello-react/.git hello-react-git && rm -rf hello-react && \
	npx create-react-app hello-react && mv hello-react-git/.git hello-react && rmdir hello-react-git && \
	touch $@

stamps/changes:
	rm -rf changes; \
	${TCB} isolate --remote-host ${TORIZON_FQDN} \
	               --remote-username ${TORIZON_USERNAME} \
	               --remote-password ${TORIZON_PASSWORD} \
	               --changes-directory=changes; \
	touch $@

tcb-env-setup.sh:
	wget https://raw.githubusercontent.com/toradex/tcb-env-setup/master/tcb-env-setup.sh

.PHONY: clean
clean:
	test -n "$(docker image ls -q ${DOCKERIMAGE}" && docker rmi -f ${DOCKERIMAGE}; rm -f stamps/docker-image; \
	rm -rf tezi-output; rm -f stamps/build-tezi; \
	rm -rf hello-react/node_modules; rm -f stamps/build-hello-react; \
	rm -f tcb-env-setup.sh

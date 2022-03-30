# Makefile based demo for Torizon implementation
#
TCB = ./tcb.sh

all: ota-push tcb-env-setup.sh settings.mk

settings.mk: settings.mk.in
ifneq ("","$(wildcard settings.mk)")
	@echo "The file settings.mk.in is newer than settings.mk."
	@echo "Please review and edit as appropriate."
	@echo "If no changes are needed please run 'touch settings.mk'"
else
	@cp settings.mk.in settings.mk;
	@echo "Please edit settings.mk and rerun make";
endif
	@false

include settings.mk

.PHONY: build ota-push

ota-push: stamps/ota-push

stamps/ota-push: stamps/build credentials.zip
	${TCB} push --credentials credentials.zip --canonicalize --package-name ${OSTREE_REF} --package-version ${OSTREE_VERSION} ${OSTREE_REF}
	${TCB} push --credentials credentials.zip --canonicalize --package-name ${CONTAINERNAME} --package-version ${CONTAINERVERSION} docker-compose.yml

credentials.zip:
	@echo "Please download Torizon credentials to $(pwd)/credentials.zip."
	@echo "https://app.torizon.io/#/account"
	false

build: stamps/build

stamps/build: stamps/build-hello-react tcbuild.yaml stamps/docker-image stamps/changes
	rm -rf tezi-output
	${TCB} build --set DOCKER_HUB_USERNAME="${DOCKER_HUB_USERNAME}" --set DOCKER_HUB_PASSWORD="${DOCKER_HUB_PASSWORD}" --set OSTREE_REF="${OSTREE_REF}"
	@touch $@

stamps/docker-image: Dockerfile
	docker build -t ${DOCKERIMAGE} .
	docker login --username "${DOCKER_USERNAME}" --password "${DOCKER_PASSWORD}"
	docker push ${DOCKERIMAGE}
	touch $@

tcbuild.yaml:
	${TCB} build --create-template
	@grep -v '>>' tcbuild.yaml > tcbuild-clean.yaml
	@mv -f tcbuild-clean.yaml tcbuild.yaml

stamps/build-hello-react: stamps/create-hello-react
	(cd hello-react && npm run build)
	touch $@

stamps/create-hello-react:
	@mkdir hello-react-git && mv hello-react/.git hello-react-git && rm -rf hello-react
	npx create-react-app hello-react
	@mv hello-react-git/.git hello-react && rmdir hello-react-git
	touch $@

stamps/changes:
	@rm -rf changes
	${TCB} isolate --remote-host ${TORIZON_FQDN} \
	               --remote-username ${TORIZON_USERNAME} \
	               --remote-password ${TORIZON_PASSWORD} \
	               --changes-directory=changes
	touch $@

tcb-env-setup.sh:
	wget https://raw.githubusercontent.com/toradex/tcb-env-setup/master/tcb-env-setup.sh

.PHONY: clean
clean:
	docker rmi -f ${DOCKERIMAGE}
	rm -f stamps/docker-image
	rm -rf tezi-output; rm -f stamps/build
	rm -rf hello-react/node_modules; rm -f stamps/build-hello-react
	rm -f tcb-env-setup.sh

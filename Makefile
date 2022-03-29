# Makefile based demo for Torizon implementation
#
TCB := ./tcb.sh
DOCKERIMAGE := drewmoseley/hello-react:latest
TORIZON_PASSWORD := mysecretpassword
TORIZON_USERNAME := torizon
TORIZON_FQDN := apalis-imx8.lab.moseleynet.net

.PHONY: build_tezi

all: build_tezi

build_tezi: stamps/build_tezi

stamps/build_tezi: stamps/build-hello-react tcb-env-setup.sh tcbuild.yaml stamps/docker-image stamps/changes
	rm -rf tezi_output; ${TCB} build; \
	touch $@

stamps/docker-image: Dockerfile
	docker build -t ${DOCKERIMAGE} .; \
	touch $@

tcbuild.yaml: tcb-env-setup.sh
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
	@docker rmi -f ${DOCKERIMAGE} > /dev/null 2>&1 || true

# Makefile based demo for Torizon implementation
#
TCB := ./tcb.sh
DOCKERIMAGE := drewmoseley/hello-react:latest
TORIZON_PASSWORD := mysecretpassword
TORIZON_USERNAME := torizon
TORIZON_FQDN := apalis-imx8.lab.moseleynet.net

all: hello-react/build/index.html tcb-env-setup.sh tcbuild.yaml docker-image changes

.PHONY: docker-image
docker-image: docker-image.stamp

docker-image.stamp: Dockerfile
	docker build -t ${DOCKERIMAGE} .; \
	touch docker-image.stamp

tcbuild.yaml: tcb-env-setup.sh
	@${TCB} build --create-template; \
	grep -v '>>' tcbuild.yaml > tcbuild-clean.yaml; \
	mv -f tcbuild-clean.yaml tcbuild.yaml

hello-react/build/index.html: hello-react
	@[ -e hello-react/build/index.html ] || (cd hello-react && npm run build)

.PHONY: subdirs hello-react changes
hello-react:
	@[ -e hello-react/package.json ] || npx create-react-app hello-react

changes: changes.stamp

changes.stamp:
	@${TCB} isolate --remote-host ${TORIZON_FQDN} \
	                --remote-username ${TORIZON_USERNAME} \
	                --remote-password ${TORIZON_PASSWORD} \
	                --changes-directory=changes; \
	touch changes.stamp

tcb-env-setup.sh:
	wget https://raw.githubusercontent.com/toradex/tcb-env-setup/master/tcb-env-setup.sh

.PHONY: clean
clean:
	rm -f *.stamp; \
	[ $(docker images ${DOCKERIMAGE} | wc -l) -gt 1 ] && docker rmi -f ${DOCKERIMAGE}

.PHONY: distclean
distclean: clean
	rm -rf hello-react tcbuild.yaml

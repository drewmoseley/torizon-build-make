# Makefile based demo for Torizon implementation
#
TCB := ./tcb.sh

all: hello-react/build/index.html tcb-env-setup.sh tcbuild.yaml

tcbuild.yaml: tcb-env-setup.sh
	@${TCB} build --create-template; \
	grep -v '>>' tcbuild.yaml > tcbuild-clean.yaml; \
	mv -f tcbuild-clean.yaml tcbuild.yaml

hello-react/build/index.html: hello-react
	@[ -e hello-react/build/index.html ] || (cd hello-react && npm run build)

.PHONY: subdirs hello-react
hello-react:
	@[ -e hello-react/package.json ] || npx create-react-app hello-react

tcb-env-setup.sh:
	wget https://raw.githubusercontent.com/toradex/tcb-env-setup/master/tcb-env-setup.sh

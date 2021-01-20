VENV_NAME := scadajs1
APP := main
CONFIG := ../dcs-modules.txt

.PHONY: test update-deps update-app-version

# Check if we are in a VIRTUAL_ENV:
__c:
	$(if $(NODE_VIRTUAL_ENV),,$($(warning ************  WARNING: NOT INSIDE A VIRTUAL ENV  ************)))

__app: # Check if APP name is set
	$(if $(APP),,$($(error *** APP variable is not set. ***)))

test: __c
	es-check es5 './release/$(APP)/**/*.js'

update-deps: __c
	npm run interactive-update

update-app-version:
	touch lib/app-version.json

release: __c __prepare_release_dir __production __release_commit

__production: __app
	gulp --webapp $(APP) --production

development: __c __app
	@tmux rename-window "gulp" 2> /dev/null || true
	gulp --webapp $(APP)

update-scadajs:
	./tools/update-scadajs.sh

install-deps: __c
	@echo "Using configuration file: $${CONF:?}"
	./tools/install-modules.sh $(CONF)

get-deps-size:
	find . -name "node_modules" -type d -prune | xargs du -chs

clean-node-modules:
	find . -name "node_modules" -type d -prune -exec rm -rf '{}' +

clean-build:
	rm -rf ./build

clean-all: clean-build clean-node-modules

freeze-venv: __c
	freeze ./requirements.txt

create-venv:
	$(if $(SCADAJS_1_ENV),$(error SCADAJS_1_ENV variable is set, use it instead: $(SCADAJS_1_ENV)))
	$(eval NODE_VERSION := $(shell echo `grep "^#node@" nodeenv.txt | cut -d@ -f2` | sed 's/^$$/system/'))
	nodeenv --requirement=./nodeenv.txt --node=$(NODE_VERSION) --prompt="($(VENV_NAME))" --jobs=4 nodeenv

__prepare_release_dir:
	@( if [ ! -d release/$(APP) ]; then \
		 	mkdir -p release; \
			cd release; \
			git init $(APP); \
		fi \
	)

__release_commit:
	( cd release/$(APP) && git add . && git commit -m "unattended commit")

release-push:
	@( cd release/$(APP) && git push )

# VERSION defines the project version for the bundle. 
# Update this value when you upgrade the version of your project.
# To re-generate a bundle for another specific version without changing the standard setup, you can:
# - use the VERSION as arg of the bundle target (e.g make bundle VERSION=0.0.2)
# - use environment variables to overwrite this value (e.g export VERSION=0.0.2)
VERSION ?= 1.0.1

# TEST_MODE is used for testing an operator/bundle that is in develoment. This mode sets all utilized
# images to -dev versions for local deployment.
OPERATOR_TEST_MODE ?= false

# If in operator testing mode, use development images for bundle & image creation
ifeq ($(OPERATOR_TEST_MODE),true)
IMG := "docker.io/anchore/engine-operator-dev:latest"
BUNDLE_IMG := "docker.io/anchore/engine-operator-dev:bundle-latest"
BUNDLE_SCAN_IMG := $(BUNDLE_IMG)
REDHAT_IMG := $(IMG)
endif

# Image URL to use all building/pushing image targets
IMG ?= docker.io/anchore/engine-operator:v$(VERSION)

# BUNDLE_IMG defines the image:tag used for the bundle. 
# You can use it as an arg. (E.g make bundle-build BUNDLE_IMG=<some-registry>/<project-name-bundle>:<tag>)
BUNDLE_IMG ?= registry.connect.redhat.com/anchore/engine-operator-bundle:$(VERSION)

# Image URL to use for RedHat OperatorHub
REDHAT_IMG ?= registry.connect.redhat.com/anchore/engine-operator:v$(VERSION)

# Image tag for uploading to RedHat operatorhub publishing
BUNDLE_SCAN_IMG ?= scan.connect.redhat.com/ospid-e5cf441f-cf40-4f76-a8f7-b9b8046f5264/engine-operator-bundle:v$(VERSION)
REDHAT_SCAN_IMG ?= scan.connect.redhat.com/ospid-e0beb8be-3b8b-40a9-853a-ad5c227fd2a0/engine-operator:v$(VERSION)

# CHANNELS define the bundle channels used in the bundle. 
# Add a new line here if you would like to change its default config. (E.g CHANNELS = "preview,fast,stable")
# To re-generate a bundle for other specific channels without changing the standard setup, you can:
# - use the CHANNELS as arg of the bundle target (e.g make bundle CHANNELS=preview,fast,stable)
# - use environment variables to overwrite this value (e.g export CHANNELS="preview,fast,stable")
ifneq ($(origin CHANNELS), undefined)
BUNDLE_CHANNELS := --channels=$(CHANNELS)
endif

# DEFAULT_CHANNEL defines the default channel used in the bundle. 
# Add a new line here if you would like to change its default config. (E.g DEFAULT_CHANNEL = "stable")
# To re-generate a bundle for any other default channel without changing the default setup, you can:
# - use the DEFAULT_CHANNEL as arg of the bundle target (e.g make bundle DEFAULT_CHANNEL=stable)
# - use environment variables to overwrite this value (e.g export DEFAULT_CHANNEL="stable")
ifneq ($(origin DEFAULT_CHANNEL), undefined)
BUNDLE_DEFAULT_CHANNEL := --default-channel=$(DEFAULT_CHANNEL)
endif
BUNDLE_METADATA_OPTS ?= $(BUNDLE_CHANNELS) $(BUNDLE_DEFAULT_CHANNEL)

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: run
run: helm-operator ## Run against the configured Kubernetes cluster in ~/.kube/config
	$(HELM_OPERATOR) run

.PHONY: install
install: kustomize ## Install CRDs into a cluster
	$(KUSTOMIZE) build config/crd | kubectl apply -f -

PHONY: uninstall
uninstall: kustomize ## Uninstall CRDs from a cluster
	$(KUSTOMIZE) build config/crd | kubectl delete -f -

.PHONY: deploy
deploy: kustomize ## Deploy controller in the configured Kubernetes cluster in ~/.kube/config
	cd config/manager && $(KUSTOMIZE) edit set image controller=$(IMG)
	$(KUSTOMIZE) build config/default | kubectl apply -f -

.PHONY: undeploy
undeploy: kustomize ## Undeploy controller in the configured Kubernetes cluster in ~/.kube/config
	$(KUSTOMIZE) build config/default | kubectl delete -f -

.PHONY: deploy-olm
deploy-olm: ## Deploy operator using OLM
	operator-sdk run bundle $(BUNDLE_IMG)

.PHONY: undeploy-olm
undeploy-olm: ## Undeploy operator using OLM
	operator-sdk cleanup anchore-engine

.PHONY: docker-build
docker-build: ## Build the docker image
	docker build -t $(IMG) . --no-cache

.PHONY: docker-push
docker-push: ## Push the docker image
	docker push $(IMG)

.PHONY: docker-push-redhat
docker-push-redhat: ## Push the RedHat docker image
	docker tag $(IMG) $(REDHAT_SCAN_IMG)
	docker push $(REDHAT_SCAN_IMG)

PATH  := $(PATH):$(PWD)/bin
SHELL := env PATH=$(PATH) /bin/sh
OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH := $(shell uname -m | sed 's/x86_64/amd64/')

.PHONY: kustomize
KUSTOMIZE = $(shell pwd)/bin/kustomize
kustomize: ## Download kustomize locally if necessary, preferring the $(pwd)/bin path over global if both exist.
ifeq (,$(wildcard $(KUSTOMIZE)))
ifeq (,$(shell which kustomize 2>/dev/null))
	@{ \
	set -e ;\
	mkdir -p $(dir $(KUSTOMIZE)) ;\
	curl -sSLo - https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v3.5.4/kustomize_v3.5.4_$(OS)_$(ARCH).tar.gz | \
	tar xzf - -C bin/ ;\
	}
else
KUSTOMIZE = $(shell which kustomize)
endif
endif

.PHONY: helm-operator
HELM_OPERATOR = $(shell pwd)/bin/helm-operator
helm-operator: ## Download helm-operator locally if necessary, preferring the $(pwd)/bin path over global if both exist.
ifeq (,$(wildcard $(HELM_OPERATOR)))
ifeq (,$(shell which helm-operator 2>/dev/null))
	@{ \
	set -e ;\
	mkdir -p $(dir $(HELM_OPERATOR)) ;\
	curl -sSLo $(HELM_OPERATOR) https://github.com/operator-framework/operator-sdk/releases/download/v1.9.0/helm-operator_$(OS)_$(ARCH) ;\
	chmod +x $(HELM_OPERATOR) ;\
	}
else
HELM_OPERATOR = $(shell which helm-operator)
endif
endif

# Generate bundle manifests and metadata, then validate generated files.
define REDHATLABELS
# Labels for RedHat partner portal uploads to operatorhub/marketplace
LABEL com.redhat.openshift.versions="v4.5,v4.6"
LABEL com.redhat.delivery.operator.bundle=true
LABEL com.redhat.delivery.backport=true
endef

.PHONY: bundle
export REDHATLABELS
CREATED_AT = $(shell TZ=UTC date +%FT%TZ)
bundle: kustomize ## Use kustomize to create the bundle directory for pushing to the RedHat marketplace
	operator-sdk generate kustomize manifests -q
	cd config/manager && $(KUSTOMIZE) edit set image controller=$(REDHAT_IMG)
	if ! $(OPERATOR_TEST_MODE); then \
		cd config/manager && $(KUSTOMIZE) edit add patch --path manager_redhat_patch.yaml; \
	fi
	$(KUSTOMIZE) build config/manifests | operator-sdk generate bundle -q --overwrite --version $(VERSION) $(BUNDLE_METADATA_OPTS)
	echo "$$REDHATLABELS" >> bundle.Dockerfile
	sed -i -e 's|REDHAT_IMAGE|$(REDHAT_IMG)|' -e 's|CREATED_AT|"$(CREATED_AT)"|' bundle/manifests/anchore-engine.clusterserviceversion.yaml
	operator-sdk bundle validate ./bundle
	git restore config/manager/kustomization.yaml

.PHONY: docker-bundle-build
docker-bundle-build: bundle ## Build the bundle image.
	docker build -f bundle.Dockerfile -t $(BUNDLE_IMG) . --no-cache
	if ! $(OPERATOR_TEST_MODE); then \
		mkdir -p bundle/$(VERSION); \
		mv bundle/{manifests,metadata,tests} bundle/$(VERSION)/; \
	fi

.PHONY: docker-bundle-push
docker-bundle-push: ## Push the bundle image to dockerhub
	docker tag $(BUNDLE_IMG) $(BUNDLE_SCAN_IMG)
	docker push $(BUNDLE_SCAN_IMG)

.PHONY: clean
clean: ## Clean up testing artifacts
	rm -rf bundle/{manifests,metadata,tests}
	git restore config/manager/kustomization.yaml
	$(MAKE) undeploy-olm
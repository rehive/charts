# Makefile for publishing Helm charts

CHART_NAME ?= rehive-service
CHART_DIR := $(CHART_NAME)
CHART_YAML := $(CHART_DIR)/Chart.yaml
CHART_VERSION := $(shell grep 'version:' $(CHART_YAML) | awk '{print $$2}')
GCP_REGION := europe-west4
GCP_PROJECT_ID := rehive-services
GCP_REPOSITORY := rehive-helm-charts

.PHONY: create-chart
create-chart:
	helm create $(CHART_NAME)

.PHONY: package-chart
package-chart:
	helm package $(CHART_NAME)

.PHONY: move-chart
move-chart:
	mv $(CHART_NAME)-$(CHART_VERSION).tgz docs

.PHONY: update-index
update-index:
	helm repo index docs --url https://rehive.github.io/charts

.PHONY: login-gcloud
login-gcloud:
	gcloud auth print-access-token | helm registry login -u oauth2accesstoken --password-stdin https://$(GCP_REGION)-docker.pkg.dev

.PHONY: push-gcloud
push-gcloud:
	helm push docs/$(CHART_NAME)-$(CHART_VERSION).tgz oci://$(GCP_REGION)-docker.pkg.dev/$(GCP_PROJECT_ID)/$(GCP_REPOSITORY)

.PHONY: publish
publish: package-chart move-chart update-index login-gcloud push-gcloud

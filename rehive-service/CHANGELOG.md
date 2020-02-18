# Change Log

This file documents all notable changes to Rehive Service Helm Chart. The release
numbering uses [semantic versioning](http://semver.org).

## v0.1.39

### Minor changes

* * Reverted our deployments back to the extensions/v1beta1 because chart upgrade
* from extensions/v1beta1 to apps/v1 Deployment is not possible as documented
* [here](https://github.com/helm/helm/issues/6583)

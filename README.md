# Rehive Charts Repo

Rehive's Kubernetes Helm charts repository.


### Publishing

GitHub pages is set up to point to the `docs` folder. Publishing charts:

```console
helm create mychart # Only run this when creating a new helm chart
helm package mychart
mv mychart-0.1.0.tgz docs
helm repo index docs --url https://rehive.github.io/charts
git add -i
git commit -av
git push origin master
```
Now let's also push to Google Artifact Registry (Later we can stop publishing to GitHub pages)

```console
gcloud auth print-access-token | helm registry login -u oauth2accesstoken --password-stdin https://europe-west4-docker.pkg.dev
helm push docs/rehive-service-1.1.0.tgz oci://europe-west4-docker.pkg.dev/rehive-services/rehive-helm-charts
```

To add this repository, run `helm repo add rehive
https://rehive.github.io/charts`

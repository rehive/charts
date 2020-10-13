# Rehive Charts Repo

Rehive's Kubernetes Helm charts repository.

### How It Works

GitHub pages is set up to point to the `docs` folder. Publishing charts:

```console
$ helm create mychart # Only run this when creating a new helm chart
$ helm package mychart
$ mv mychart-0.1.0.tgz docs
$ helm repo index docs --url https://rehive.github.io/charts
$ git add -i
$ git commit -av
$ git push origin master
```

To add this repository, run `helm repo add rehive
https://rehive.github.io/charts`

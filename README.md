## Project Overview

This repository demonstrates a minimal CI/CD pipeline that builds, tags and releases a custom Nginx-based container image and deploys it to Kubernetes. The goal is to showcase automated releases, changelog generation, and an environment for local testing.

Contents

- GitHub Actions workflows for release and branch builds
- `Dockerfile` and Nginx assets for the image
- Kubernetes manifest(s) under `k8s/` with a Kustomize-friendly layout
- `localdev.sh` helper for local testing

Requirements

- Docker (for local image build/run)
- Git
- Minikube

Quick start (local)

1. Build the image locally:

```bash
docker build -t my-nginx:local .
docker run --rm -p 8080:80 my-nginx:local
```

2. Open http://localhost:8080 to verify the app is served.

Release workflow (main)

- Trigger: a tag push with commands: (git tag v1.2.3 git push origin v.1.2.3) pushed to `main`.
- Steps performed by the workflow:
    - Generate a changelog using `git-cliff`
    - Build and publish the Docker image to GitHub Container Registry (GHCR)
    - Create a GitHub Release using the changelog

Branch builds (dev images)

- Trigger: pushes to non-`main` branches.
- Produces a dev-tagged image (example `0.0.1-dev-<run_number>`) published to GHCR for testing by third parties.

Changelog policy

- This repo uses `git-cliff` to produce consistent changelogs from commit history (Conventional Commits recommended).

How external testers can pull images

- Public package (if GHCR package is public):

```bash
docker pull ghcr.io/<owner>/my-nginx:<tag>
docker run --rm -p 8080:80 ghcr.io/<owner>/my-nginx:<tag>
```

- Private package: authenticate using a Personal Access Token (PAT) with `read:packages`:

```bash
echo "${PAT}" | docker login ghcr.io -u <GH_USERNAME> --password-stdin
docker pull ghcr.io/<owner>/my-nginx:<tag>
```

Kubernetes deployment

- The `k8s/nginx.yaml` manifest contains a simple Deployment and Service. Use Kustomize or edit the image reference to point to the desired tag.
You can use the script localdev.sh for speed up the deployment in local.

```bash
kubectl apply -k k8s/
```

Notes & Improvements

- For CI performance consider using a self-hosted runner to avoid repeated Rust toolchain installs for `git-cliff`.
- `.git-cliff.toml` can be added to customize changelog formatting (I can add a sensible default if desired).
- You may want to make GHCR visibility explicit (public vs private) depending on whether third-party testers should pull images without auth.
- Use github and github Actions is a choice for keep everything in the same enviroiment.

### Interesting Moments

https://github.com/orgs/community/discussions/25768


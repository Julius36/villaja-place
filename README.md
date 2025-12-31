# tofu-configs

Comprehensive infrastructure and deployment configs for the villaja app project.

This repository contains Tofu, Helm, ArgoCD and container tooling used to build, package and deploy the Villaja application to Kubernetes. It provides production-oriented, reproducible Tofu + GitOps patterns for infrastructure and application delivery.

## Repository layout

- [app.py](Projects/tofu-configs/app.py) - example Python app used by the container image.
- [Dockerfile](Projects/tofu-configs/Dockerfile) - container image specification for the app.
- [main.tf](Projects/tofu-configs/main.tf) - primary Terraform configuration.
- [provider.tf](Projects/tofu-configs/provider.tf) - Terraform provider definitions.
- [variables.tf](Projects/tofu-configs/variables.tf) - Terraform variables.
- [backend.tf](Projects/tofu-configs/backend.tf) - optional Terraform backend configuration.
- [argocd-app.yaml](Projects/tofu-configs/argocd-app.yaml) - ArgoCD Application manifest for GitOps.
- [argocd.tf](Projects/tofu-configs/argocd.tf) - Terraform resources for ArgoCD (if used).
- [villaja-project/](Projects/tofu-configs/villaja-project) - a Helm chart with templates used for the Kubernetes deployment.
- [.github/workflows/ci.yaml](Projects/tofu-configs/.github/workflows/ci.yaml) - CI pipeline (build/test/publish) configuration.

> Note: paths above are shown as links into the repo for quick reference.

## Goals and scope

- Provide Tofu examples to provision cluster/cloud resources and supporting infra.
- Build a Docker image for the `villaja` app and publish it to a container registry.
- Package the app into a Helm chart (`villaja-project`) for Kubernetes deployment.
- Demonstrate GitOps deployment via ArgoCD manifest and optional Terraform-managed ArgoCD.
- Provide CI pipeline to validate, build, and optionally publish artifacts.

## Prerequisites

- `docker` (build and test local images)
- `tofu` (compatible with the included lockfile)
- `kubectl` (interact with Kubernetes cluster)
- `helm` (install or test charts)
- `argocd` CLI (optional, for managing ArgoCD)

Install tools via your platform package manager, or use the official downloads.

## Quick workflow

1. Build the Docker image locally.

```bash
# from repository root
docker build -t villaja:local -f Projects/tofu-configs/Dockerfile .
```

2. Inspect or run the container locally for smoke tests:

```bash
docker run --rm -p 8080:8080 villaja:local
# then visit http://localhost:8080
```


3. Initialize Tofu and apply infrastructure changes:

```bash
cd Projects/tofu-configs
tofu init
tofu plan -out=tfplan
tofu apply tfplan
```

If you use a remote backend, ensure credentials and backend config are set in `backend.tf`.


4. Package and install the Helm chart to your Kubernetes cluster:

```bash
helm repo add local-chart https://example.com/placeholder || true
helm dependency update Projects/tofu-configs/villaja-project || true
helm install villaja-release Projects/tofu-configs/villaja-project --namespace villaja --create-namespace
```

5. (Optional) Apply the ArgoCD Application manifest to let ArgoCD manage the chart:

```bash
kubectl apply -f Projects/tofu-configs/argocd-app.yaml
```

## Dockerfile notes

See [Projects/tofu-configs/Dockerfile](Projects/tofu-configs/Dockerfile).

- The container builds the `app.py` example; ensure `requirements.txt` is present when building for production.
- Keep your image small by using multi-stage builds and a minimal runtime image.

Recommended build command for publishing (tag and push to your registry):

```bash
docker build -t <registry>/villaja:<tag> -f Projects/tofu-configs/Dockerfile .
docker push <registry>/villaja:<tag>
```

## Tofu notes

- Tofu configuration files are at the repository root: [main.tf](Projects/tofu-configs/main.tf), [provider.tf](Projects/tofu-configs/provider.tf), [variables.tf](Projects/tofu-configs/variables.tf).
- `backend.tf` controls where state is stored. If you plan to collaborate, configure a remote backend (S3/GCS/remote state).
- The repository includes a lockfile (`.terraform.lock.hcl`) to lock provider versions; this is compatible with Tofu.

Common Tofu commands:

```bash
tofu init
tofu fmt
tofu validate
tofu plan -out=tfplan
tofu apply tfplan
```

## Helm chart (villaja-project)

The `villaja-project` chart contains templated Kubernetes manifests to deploy the app. Key files:

- [Projects/tofu-configs/villaja-project/Chart.yaml](Projects/tofu-configs/villaja-project/Chart.yaml)
- [Projects/tofu-configs/villaja-project/values.yaml](Projects/tofu-configs/villaja-project/values.yaml)
- [Projects/tofu-configs/villaja-project/templates/deployment.yaml](Projects/tofu-configs/villaja-project/templates/deployment.yaml)

Edit `values.yaml` to point image repository and tag, then install with `helm install`.

## ArgoCD GitOps

- Use [Projects/tofu-configs/argocd-app.yaml](Projects/tofu-configs/argocd-app.yaml) to register the repo/chart with ArgoCD.
- When using ArgoCD, ensure the ArgoCD instance has access to the Kubernetes cluster and to the Git repository.

## CI (GitHub Actions)

- The repository includes a CI workflow at [.github/workflows/ci.yaml](Projects/tofu-configs/.github/workflows/ci.yaml).
- Typical CI steps include linting, building the Docker image, running tests, and optionally pushing images or publishing charts.

If you want the workflow to publish images, add the required secrets (`CR_PAT`, `DOCKER_USERNAME`, `DOCKER_PASSWORD`, etc.) in the repository settings.

## Secrets and sensitive data

- Do NOT commit secrets or cloud credentials to Git. Use environment variables, Secrets Manager, or CI secret stores.
- For Terraform remote state, protect access with IAM policies and encryption.

## Troubleshooting

- Tofu errors: run `tofu init -reconfigure` and check provider versions in `.terraform.lock.hcl`.
- Kubernetes deployments fail: `kubectl describe pod <pod>` and `kubectl logs <pod>` are first-stop diagnostics.

## Contributing

1. Fork the repository.
2. Create a feature branch and open a PR with a clear description.
3. Run CI and ensure linting/tests pass.

## License

Specify your preferred license here. If none is present, add a `LICENSE` file to the repository root.

## Contact / Support

Open an issue or reach out via the repository discussion page for questions or improvements.

---

If you'd like, I can also:
- add a small `README-DEV.md` with step-by-step local dev instructions,
- update the GitHub Actions workflow to push built images to a specific registry,
- or add an opinionated `Makefile` to simplify the commands above.

Please tell me which follow-up you'd like next.

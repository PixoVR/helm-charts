# Using Crossplane to provision a GKE cluster

## Tutorial

For the full tutorial on how to use Crossplane to create a GKE cluster, check out our [blog post on Medium](https://medium.com/@dee_zero/cf5374d765ee?source=friends_link&sk=6654b27051a58815073b0613c8127def).

Be sure to also check out our post on [Shifting from Infrastructure as Code to Infrastructure as Data](https://medium.com/@dee_zero/bdb1ae1840e3?source=friends_link&sk=4416407624889f0139bcb1d5b15ec1bb).

## Quickstart

This code creates installs Crossplane on an existing GKE cluster, and provisions a new GKE cluster using Crossplane.

Feel free to skip running `1-gcp_config.sh` if you're installing Crossplane elsewhere.
### Pre-requisites

* A Google Cloud project
* `glcoud` CLI
* An existing GKE cluster (Crossplane will be installed here)
* The [`envsubst`](https://kb.novaordis.com/index.php/Envsubst) tool installed on your local machine


### 1- Update the env_vars.sh file

Replace the values in `<...>` with your own values, and save.

### 2- Run the scripts

Run the following script files to:

* Install Crossplane on an existing Kubernetes cluster in Google Cloud or locally with Rancher Desktop
* Create configure the Crossplane GCP Provider
* Provision a new GKE Cluster and Node Pool using Crossplane

```
./bin/1-gcp_config.sh
./bin/2-install_crossplane.sh
./bin/3-configure_gcp_provider.sh

helm install ./chart --create-namespace -n walker-crossplane
```

## References

* [Crossplane Getting Started Docs (for v1.2.0)](https://crossplane.io/docs/v1.2/getting-started/install-configure.html)
* [Crossplane GKECluster API docs for GCP](https://doc.crds.dev/github.com/crossplane/provider-gcp/container.gcp.crossplane.io/GKECluster/v1beta1@v0.16.0)
* [Crossplane NodePool API docs for GCP](https://doc.crds.dev/github.com/crossplane/provider-gcp/container.gcp.crossplane.io/NodePool/v1alpha1@v0.16.0)
* [Crossplane provider-gcp on Github (contains examples)](https://github.com/crossplane/provider-gcp/blob/master/examples/gke/gke.yaml)

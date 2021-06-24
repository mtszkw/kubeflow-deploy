Following tutorial is based on official [Kubeflow Deployment with kfctl_k8s_istio](https://www.kubeflow.org/docs/started/k8s/kfctl-k8s-istio/) guide, but in case that site  modified in future, I'm writing down the instructions that worked out for me.


### Prerequisites (aka My local setup)
- WSL 2 on Windows 10
- Docker Desktop using WSL 2
- `minikube` installed on WSL (my version: v1.18.1)

### Creating environment

After starting minikube single-node cluster (`minikube start`), create the directory for Kubeflow environment and download Kubeflow:

```bash
mkdir kubeflow-local
cd kubeflow-local
```

```bash
curl -L -o kfctl_v1.2.0-0_linux.tar.gz https://github.com/kubeflow/kfctl/releases/download/v1.2.0/kfctl_v1.2.0-0-gbc038f9_linux.tar.gz
tar -xvf kfctl_v1.2.0-0_linux.tar.gz
```

After downloading and unpacking kfctl, make sure it works:

```bash
kfctl version
```

then create a directory for Kubeflow deployment and run kfctl apply using config file from Kubeflow manifests repo:
```bash
mkdir kf-local
cd kf-local
../kfctl apply -V -f https://raw.githubusercontent.com/kubeflow/manifests/v1.2-branch/kfdef/kfctl_k8s_istio.v1.2.0.yaml
```

Now it takes a couple of minutes to download and deploy all of Kubeflow internals. You may see several errors, but Kubeflow should get pass them eventually (after few retries). If after few minutes you see your prompt back and there are no errors at the end of the log, it should be fine.

### Accessing Kubeflow dashboard

As stated in Kubeflow docs: _After Kubeflow is deployed, the Kubeflow Dashboard can be accessed via istio-ingressgateway service. If loadbalancer is not available in your environment, NodePort or Port forwarding can be used to access the Kubeflow Dashboard._ So let's check if istio-ingressgateway service is up and running:

```bash
kubectl get svc istio-ingressgateway -n istio-system
```

Finally, let's follow the documentation and use port-forwarding to expose Kubeflow Dashboard.

```bash
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80
```

After that, the dashboard should be accessible at http://127.0.0.1:8080

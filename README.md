# scramble

## K6 on EKS fargate

How to access eks cluster using kubectl.
```shell
aws eks update-kubeconfig --region region-code --name my-cluster --profile my-profile
```

### Argo CD

ArgoCD initial username is `admin`.

How to get initial password

```shell
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Grafana

How to get initial password

```shell
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```
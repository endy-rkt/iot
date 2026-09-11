to launch it:
1. run "sudo ./scripts/init.sh"
2. run "sudo ./scripts/setup-cluster.sh"
3. "kubectl port-forward svc/argocd-server -n argocd port:443" to forward port for argocd

to stop it: "make fclean"

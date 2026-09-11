to launch it:
1. run "sudo ./scripts/init.sh"
2. run "sudo ./scripts/setup-cluster.sh"
3. "kubectl port-forward svc/argocd-server -n argocd port:443 &" to forward port for argocd 
4. create an user in the local gitlab (we have already template in app folder with user:gituser conf/app)
5. then add the app content in a repo (template name: gitops)
6. apply the secret.yaml to add the cred for the git user in argocd namespace (conf/argocd/secret.yaml)
7. apply the application.yaml to add the git repo in argocd app (conf/app/application.yaml) 

to stop it: "sudo ./scripts/destroy.sh"

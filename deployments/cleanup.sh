kubectl delete ksvc blue-green-demo
kubectl delete pr build-and-deploy
git reset --hard 42824d26c186e74f8700fbde778d2661c831da09
git push -f

# elafros-route-demo

Your map to Elafros routs. Simple blue/green-like app deployment pattern demo using routes. 

## Setup 

Stand up an instance of Elafros using latest [build](https://github.com/elafros/elafros/blob/master/README.md)

## Demo

> For this demo I'm gonna use `thingz.io` domain defined in [Google Domains](https://domains.google/#/). Edit data.domainSuffix element in [elaconfig.yaml](https://github.com/elafros/elafros/blob/master/config/elaconfig.yaml) to use a different domain. 

### Deploy app (blue)

`kubectl apply -f deployments/stage1.yaml`

Check for external IP being assigned in k8s ingress service

`kubectl get ing`

When route created and IP assigned, navigate to http://route-demo.default.thingz.io to show deployed app. Let's call this blue (aka v1) version of the app. 

### Deploy new (green) version of the app

`kubectl apply -f deployments/stage2.yaml`

This will only stage v2. That means:

* Won't route any of v1 (blue) traffic to that new (green) version, and
* Create new named route (`v2`) for testing of new the newlly deployed version

Refresh v1 (http://route-demo.default.thingz.io) to show our v2 takes no traffic, 
and navigate to http://v2.route-demo.default.thingz.io to show the new `v2` named route.

### Migrate portion of v1 (blew) traffic to v2 (green)

`kubectl apply -f deployments/stage3.yaml`

Refersh (a few times) the original route http://route-demo.default.thingz.io to show part of traffic going to v2

> Note, demo uses 50/50 split to assure you don't have to refresh too much, normally you would start with 1-2% maybe

### Re-route 100% of traffic to v2 (green)

`kubectl apply -f deployments/stage4.yaml`

This will complete the deployment by sending all traffic to the new (green) version.

Refresh original route http://route-demo.default.thingz.io bunch of times to show that all traffic goes to v2 (green) and v1 (blue) no longer takes traffic.

Optionally, I like to pointing out that:

* I kept v1 (blue) entry with 0% traffic for speed of reverting, if ever necessary
* I added named route `v1` to the old (blue) version of the app to allow access for comp reasons 

Navigate to http://v1.route-demo.default.thingz.io to show the old version accessable by `v1` named route


## Rebuilding Images 

Install app on the Elafros service first you have to create an image of the app. You can build the image using GCP image build service by executing `make push` command. If successful, the `IMAGES` column from the results will include the URI of your image. If you need to update the image change `containerSpec` portion of the `stage1.yaml` and `stage2.yaml` manifest to your new image URI.

```
serviceType: container
      containerSpec:
        image: gcr.io/elafros-samples/elafros-route-demo:blue
```

## Configuring DNS

Wait for the ingress to obtain a public IP, sometime takes up to 30sec. 

```
kubectl get ing
```

Then capture that IP using below command and configure an `A` entry with `*` in your DNS server to point your that IP

## Cleanup

```
kubectl delete -f deployments/stage4.yaml --ignore-not-found=true
kubectl delete -f deployments/stage3.yaml --ignore-not-found=true
kubectl delete -f deployments/stage2.yaml --ignore-not-found=true
kubectl delete -f deployments/stage1.yaml --ignore-not-found=true
```

# vi:syntax=python
def kaniko(git, image, context="", dockerfile="Dockerfile"):
    name = "build-{}".format(image)

    destination = pipeline.resources[image].params["url"]

    task(name, inputs = [git], outputs = [image], steps = [v1.Container(
        name = "build-and-push",
        image = "chhsiao/kaniko-executor",
        args = [
            "--destination={}".format(destination),
            "--context=/workspace/{}/{}".format(git, context),
            "--oci-layout-path=/builder/home/image-outputs/{}".format(image),
            "--dockerfile=/workspace/{}/{}".format(git, dockerfile)
        ])])

    return name

def gotest(image, deps):
    name = "test-{}".format(image)

    url = pipeline.resources[image].params["url"]
    digest = pipeline.resources[image].params["digest"]

    task(name, inputs = [image], deps = deps, steps = [v1.Container(
        name = "run-test",
        image = "{}@{}".format(url, digest),
        command = ["/knative-route-demo.test"],
        workingDir = "/")])

    return name

gitResource("knative-demo-git",
    url="https://github.com/chhsia0/knative-route-demo.git",
    revision="master")

imageResource("knative-demo-image",
    url="docker.io/chhsiao/knative-route-demo",
    digest="$(inputs.resources.knative-demo-image.digest)")

build = kaniko("knative-demo-git", "knative-demo-image")
test = gotest("knative-demo-image", [build])

action(tasks = [test], on = push(branches=["master"]))
action(tasks = [test], on = pullRequest(comment="^/run-test$"))

def test_pipeline(ctx):
    ctx.assert(len(pipeline.tasks) > 0)

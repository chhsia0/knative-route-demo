resource "knative-demo-git": {
  type: "git"
  param url: "https://github.com/chhsia0/knative-route-demo.git"
  param revision: "master"
}

resource "knative-demo-image": {
  type: "image"
  param url: "docker.io/chhsiao/knative-route-demo"
  // TODO(chhsiao): The interpolation syntax should be auto-injected.
  param digest: "$(inputs.resources.knative-demo-image.digest)"
}


task "source-to-image": {
  inputs: ["knative-demo-git"]
  outputs: ["knative-demo-image"]

  steps: [
    {
      name: "build-and-push"
      image: "chhsiao/kaniko-executor"
      args: [
        "--destination=\(resource["knative-demo-image"].param.url)",
        "--context=/workspace/knative-demo-git",
        "--oci-layout-path=/builder/home/image-outputs/knative-demo-image"
      ]
    }
  ]
}

task "run-test-binary": {
  inputs: ["knative-demo-image"]

  steps: [
    {
      name: "run-test"
      image: "\(resource["knative-demo-image"].param.url)@\(resource["knative-demo-image"].param.digest)"
      workingDir: "/"
      command: ["/knative-route-demo.test"]
    }
  ]
}

actions: [
  {
    tasks: ["run-test-binary"]
    on push branches: ["master"]
  },
  {
    tasks: ["run-test-binary"]
    on pull_request branch: ["master"]
  }
]
# Runner Setup

This project uses self-hosted runners defind and scaled via docker compose and a direct passthrough to minikube or microk8s on the host system. 

## Install microk8s

It's recommended to use microk8s directly on the host (assuming Ubuntu 22+). 

```bash
# Install microk8s 
snap install microk8s --classic
# Add the nvidia-operator
microk8s enable nvidia
# Add the private Docker registry. Runs on port 32000
microk8s enable registry 
# (Optional) If coredns and ingress is required
micro8s enable ingress
```

This will install a single node microk8s cluster, install the nvidia-operator, and enable a docker registry on the host.

# Self-Hosted Runners

Below outlines thte steps to create containerized, self-hosted runners to run on the host. 

## Create Github Org App

Create an app, private key, export the `APP_ID` and `APP_PRIVATE_KEY` values to bash profile

[Instructions](https://github.com/myoung34/docker-github-actions-runner/wiki/Usage#org-runner-as-a-github-app)


Example:
```bash
echo "export APP_PRIVATE_KEY=$(cat <your key downloaded from the gh app>.pem)" ~/.bashrc
echo "export APP_ID=<your gh app id>" >> ~/.bashrc
source ~/.bashrc
``` 

## Compose

Example github runner compose yaml on the host machine. This might not require running in privileged.. 

```yaml
services:
  runner:
    image: myoung34/github-runner:latest
    environment:
      APP_ID: ${APP_ID}
      APP_PRIVATE_KEY: ${APP_PRIVATE_KEY}
      RUNNER_GROUP: default
      RUNNER_SCOPE: org
      RUNNER_NAME_PREFIX: runner
      RUNNER_WORKDIR: /tmp/github-runner-workdir
      LABELS: gpu,cuda,self-hosted
      ORG_NAME: vllm
      EPHEMERAL: false
      DISABLE_RUNNER_UPDATE: false
      RUN_AS_ROOT: true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./cache:/cache # Persistent runner cache
      - /var/snap/microk8s/8148/credentials/:/home/<user>/.kube/config/:ro # Passing kube context for minikube into runner containers
    tmpfs:
      - /tmp/github-runner-workdir
    restart: unless-stopped
    privileged: true
    networks:
      - github-runners
    extra_hosts:
      - "host.docker.internal:host-gateway" # To push to microk8s registry
networks:
  github-runners:
    driver: bridge
```

## Running and Scaling 

Assuming all was setup correctly, this command will create 5
self-hosted runners that are registered the the org that will run
in the background. 


```bash
docker compose up --scale github-runner-gpu=5 -d
```


> Reference: [reverse shell](https://xebia.com/blog/how-to-login-to-a-google-cloud-run-container/)

- Change accounts/project:

```bash
gcloud auth list
gcloud config set account ACCOUNT_EMAIL
gcloud projects list
gcloud config set project proupsa
```

- Public instance to reverse shell

```bash
gcloud compute instances create proupsavm01 \
    --zone=europe-southwest1-a \
    --machine-type=e2-medium \
    --network-interface=network-tier=STANDARD,stack-type=IPV4_ONLY,subnet=proupsasubnet \
    --service-account=saproupsa@proupsa.iam.gserviceaccount.com \
    --create-disk=auto-delete=yes,boot=yes,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20241219,mode=rw,size=10,type=pd-balanced

gcloud compute firewall-rules create reverse-shell \
  --direction=INGRESS \
  --priority=1000 \
  --network=proupsavpc \
  --action=ALLOW \
  --rules=tcp:1234 \
  --source-ranges=0.0.0.0/0 \
  --description="Allow reverse shell"
```

- Open SSH and listen port (shell-ssh)

```bash
gcloud compute ssh "proupsavm01"
nc -n -v -l -p 1234
```

- Build and publish cloud run (from cloud-run-shell directory)

```bash
PUBLIC_IP=$(gcloud compute instances \
    describe --zone europe-southwest1-a \
    proupsavm01 \
    --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')

PROJECT=$(gcloud config get-value project)

gcloud builds submit -t gcr.io/$PROJECT/cloudshell:v1 .

gcloud run deploy cloudshell \
  --set-env-vars=PUBLIC_IP=${PUBLIC_IP},PUBLIC_PORT=1234 \
  --image gcr.io/$PROJECT/cloudshell:v1 \
  --allow-unauthenticated \
  --platform managed \
  --region europe-southwest1 \
  --service-min-instances=1 \
  --max-instances=1 \
  --timeout=900 \
  --network=proupsavpc \
  --subnet=proupsasubnet \
  --vpc-egress=all-traffic
```

- Execute command in shell-ssh

```bash
# Example log when client connects
Connection received on 34.0.206.138 1216

# Uses python’s pty module to spawn yet another shell. This time it gives bash the notion of a controlling terminal, making it behave more terminal-like, and it will even provide you with a PS1 prompt.
python -c 'import pty; pty.spawn("/bin/bash")'
```

#!/usr/bin/env bash
set -euo pipefail
trap 'echo -e "\e[31m✗  Failed on line ${LINENO}"; exit 1' ERR
shopt -s inherit_errexit

GREEN='\033[0;32m'; NC='\033[0m'
info(){ printf "${GREEN}==> %s${NC}\n" "$*"; }
have(){ command -v "$1" &>/dev/null; }

usage(){
  cat <<'EOF'
Usage: setup_devops.sh [OPTION]

Installs Docker, AWS CLI, Terraform, Helm, kubectl, Minikube and
Ansible on Ubuntu-based systems.

  -h, --help   Show this help message and exit
EOF
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

############################################################
# 0. Prep & legacy-repo cleanup
############################################################
info "House-keeping & legacy-repo cleanup …"
sudo rm -f /etc/apt/sources.list.d/kubernetes.list || true
sudo sed -i '/apt\.kubernetes\.io/d' /etc/apt/sources.list || true
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release \
                        unzip apt-transport-https software-properties-common

############################################################
# 1. Docker Engine + Compose
############################################################
if ! have docker; then
  info "Installing Docker …"
  sudo install -d -m0755 /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
                          docker-buildx-plugin docker-compose-plugin
  sudo usermod -aG docker "$USER"
else info "Docker already present – skipping."; fi

############################################################
# 2. AWS CLI v2
############################################################
if ! have aws; then
  info "Installing AWS CLI v2 …"
  curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscli.zip
  unzip -qq /tmp/awscli.zip -d /tmp && sudo /tmp/aws/install --update
  rm -rf /tmp/aws /tmp/awscli.zip
else info "AWS CLI already present – skipping."; fi

############################################################
# 3. Terraform
############################################################
if ! have terraform; then
  info "Installing Terraform …"
  sudo install -d -m0755 /etc/apt/keyrings
  curl -fsSL https://apt.releases.hashicorp.com/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/hashicorp.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/hashicorp.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
  sudo apt-get update -y && sudo apt-get install -y terraform
else info "Terraform already present – skipping."; fi

############################################################
# 4. Helm 3
############################################################
if ! have helm; then
  info "Installing Helm …"
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else info "Helm already present – skipping."; fi

############################################################
# 5. kubectl (new pkgs.k8s.io repo, falls back to static binary)
############################################################
if ! have kubectl; then
  info "Installing kubectl (pkgs.k8s.io) …"
  sudo install -d -m0755 /etc/apt/keyrings
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key \
    | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null
  if sudo apt-get update -y && sudo apt-get install -y kubectl; then
    info "kubectl installed via APT."
  else
    info "APT failed – using standalone binary …"
    curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl && sudo mv kubectl /usr/local/bin/
  fi
else info "kubectl already present – skipping."; fi

############################################################
# 6. Minikube (local K8s cluster)
############################################################
if ! have minikube; then
  info "Installing Minikube …"
  curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  chmod +x minikube && sudo mv minikube /usr/local/bin/
else info "Minikube already present – skipping."; fi

############################################################
# 7. Ansible (Launchpad PPA)
############################################################
if ! have ansible; then
  info "Installing Ansible …"
  sudo add-apt-repository --yes --update ppa:ansible/ansible
  sudo apt-get install -y ansible
else info "Ansible already present – skipping."; fi

############################################################
# Done
############################################################
info "✅  All tools present!  Run:  exec \$SHELL  or reopen terminal for Docker group changes."
info "   Next steps:"
echo   "   • minikube start --driver=docker      # spin up a local K8s cluster"
echo   "   • aws configure                       # add your AWS credentials"
echo   "   • ansible --version                   # verify Ansible install"


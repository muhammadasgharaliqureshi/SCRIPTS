# DevOps Scripts Collection

This repository contains handy shell scripts for setting up and managing
common DevOps tools on Ubuntu-based systems.  Each script lives in the
`scripts/` directory and can be run individually depending on your needs.

## Available Scripts

- **setup_devops.sh** – Installs Docker, AWS CLI, Terraform, Helm, kubectl,
  Minikube and Ansible.  It also performs some housekeeping of old
  repositories.

## Usage

Clone the repository and run the script you want.  For example:

```bash
./scripts/setup_devops.sh
```

Most scripts require root privileges for installing packages.  The
`setup_devops.sh` script also adds the current user to the Docker group –
log out and back in (or run `exec $SHELL`) afterwards.

Feel free to copy or modify these scripts for your own projects.
Contributions and suggestions are welcome!

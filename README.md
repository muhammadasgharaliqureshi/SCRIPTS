# DevOps Scripts Collection

This repository provides handy shell scripts for installing and configuring
popular DevOps tools on Ubuntu-based systems. Each script lives in the
`scripts/` directory so you can easily add more utilities over time.

## Available Scripts

- **setup_devops.sh** – Installs Docker, AWS CLI, Terraform, Helm, kubectl,
  Minikube and Ansible.  It also removes obsolete package entries so apt does
  not complain during installation.

### setup_devops.sh details

This script performs the heavy lifting for a local DevOps workstation. It will
install the tools listed above using the official package repositories where
possible, falling back to standalone binaries if needed. The script is idempotent
and skips tools that are already present on the system.

## Usage

Clone the repository and run the script you want. For example:

```bash
./scripts/setup_devops.sh
```

Run `./scripts/setup_devops.sh --help` to see the available options and a
short description of what the script does.

Most scripts require root privileges for installing packages.  The
`setup_devops.sh` script also adds the current user to the Docker group –
log out and back in (or run `exec $SHELL`) afterwards.

Feel free to copy or modify these scripts for your own projects.
Contributions and suggestions are welcome!

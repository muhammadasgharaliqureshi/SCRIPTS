# DevOps Scripts Collection

This repository provides handy shell scripts for installing and configuring
popular DevOps tools on Ubuntu-based systems. Each script lives in the
`scripts/` directory so you can easily add more utilities over time.

## Available Scripts

- **setup_devops.sh** – Installs Docker, AWS CLI, Terraform, Helm, kubectl,
  Minikube and Ansible. It also removes obsolete package entries so apt does
  not complain during installation.
- **multi_tab_browser.py** – Launches several URLs in Chromium and cycles
  through the pages while scrolling like a human user.

### setup_devops.sh details

This script performs the heavy lifting for a local DevOps workstation. It
installs the tools listed above using the official package repositories where
possible, falling back to standalone binaries if needed. The script is
idempotent and skips tools that are already present on the system.

### multi_tab_browser.py details

This Python script relies on Selenium, ChromeDriver and pyautogui. It opens a
set of predefined URLs in separate Chromium tabs, scrolls each page like a real
user, and cycles through the tabs indefinitely. Press `Ctrl+C` in the terminal
to close the browser and exit.

## Usage

Clone the repository and run the script you want. For example:

```bash
./scripts/setup_devops.sh
python3 scripts/multi_tab_browser.py
```

Run `./scripts/setup_devops.sh --help` to see the available options and a
short description of what the script does.

The Python script depends on `selenium`, `pyautogui` and a working
Chromium/ChromeDriver setup. Install the Python packages with:

```bash
pip install selenium pyautogui
```

Most scripts require root privileges for installing packages.  The
`setup_devops.sh` script also adds the current user to the Docker group –
log out and back in (or run `exec $SHELL`) afterwards.

Feel free to copy or modify these scripts for your own projects.
Contributions and suggestions are welcome!

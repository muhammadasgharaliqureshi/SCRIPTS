#!/usr/bin/env python3
import os

# ── Set up X display for WSL before any Xlib/pyautogui imports ──
os.environ['DISPLAY']   = ':0'
os.environ['XAUTHORITY'] = '/dev/null'

import time
import signal
import sys
import random

import pyautogui  # pip install pyautogui
pyautogui.FAILSAFE = False   # disable corner-triggered fail‑safe

from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import MoveTargetOutOfBoundsException

# ── Graceful shutdown on Ctrl‑C ────────────────────────────

def handle_interrupt(sig, frame):
    print("\nInterrupted—closing browser.")
    driver.quit()
    sys.exit(0)

signal.signal(signal.SIGINT, handle_interrupt)

# ── Selenium + ChromeDriver setup ───────────────────────────────
options = Options()
options.binary_location = "/usr/bin/chromium-browser"
options.add_argument("--start-maximized")
service = Service("/usr/bin/chromedriver")
driver  = webdriver.Chrome(service=service, options=options)

# ── URLs to open ───────────────────────────────
urls = [
    "https://developer.hashicorp.com/terraform/docs",
    "https://github.com/search?q=terraform",
    "https://github.com/search?q=WordPress+on+EC2",
    "https://github.com/search?q=CloudFront+S3+static+website",
    "https://github.com/search?q=AWS+architecture+S3+static+site"
]

# Open the first URL immediately
driver.get(urls[0])

# Stagger opening remaining tabs with 2–5 s delays
for url in urls[1:]:
    time.sleep(random.uniform(2, 5))
    driver.execute_script(f"window.open('{url}', '_blank');")

# ── Helper: Smooth OS cursor movement with clamping & failsafe catch

def move_cursor_to(x, y, duration=0.8):
    screen_w, screen_h = pyautogui.size()
    margin = 50  # keep 50px away from edges
    tx = max(margin, min(x, screen_w - margin))
    ty = max(margin, min(y, screen_h - margin))
    try:
        pyautogui.moveTo(tx, ty, duration=duration)
    except Exception:
        pass

# ── Helper: Read page paragraphs then scroll ────────────────────

def human_read_and_scroll(driver):
    url, title = driver.current_url.lower(), (driver.title or "").lower()
    if "login" in url or "sign in" in title:
        driver.close()
        return

    paras = driver.find_elements("tag name", "p")
    for p in paras:
        try:
            driver.execute_script(
                "arguments[0].scrollIntoView({block: 'center'});", p
            )
            time.sleep(random.uniform(0.3, 0.7))
            loc = p.location_once_scrolled_into_view
            size = p.size
            cx = loc["x"] + size["width"]  / 2
            cy = loc["y"] + size["height"] / 2
            move_cursor_to(cx, cy, duration=random.uniform(0.5, 1.0))
            time.sleep(random.uniform(0.8, 1.5))
        except MoveTargetOutOfBoundsException:
            continue

    driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")

# ── Main loop: cycle through tabs every 2 minutes ────────────────────────
while True:
    for handle in list(driver.window_handles):
        try:
            driver.switch_to.window(handle)
        except Exception:
            continue
        human_read_and_scroll(driver)
        time.sleep(random.uniform(1, 3))
    time.sleep(120)

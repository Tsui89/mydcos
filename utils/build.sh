#!/usr/bin/env bash
pyinstaller bash_container.py --onefile -F --hidden-import docker --path ./venn/lib/python2.7/site-packages -n bash-appM

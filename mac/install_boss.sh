#!/bin/bash


sudo -i
chmod +x boss.command
chmod -R 777 jre1.8.0_221.jre
spctl --master-disable
chmod -R 777 JavaAppletPlugin
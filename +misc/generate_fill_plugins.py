#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Oct 31 18:43:22 2026

@author: Nick Kozlov
"""
import os
import sys
import re

workdir = "../+plugins/"
file_format = [".m"]
excludefiles = ["fill_plugins.m"]
excludedirs = [".git"]

if len(sys.argv) > 1:
    workdir = sys.argv[1]

filedict = {}

with open(os.path.join(workdir, "fill_plugins.m"), 'w') as fw:
    fw.writelines(["function fill_plugins(item)\n", "% This function populates Plugins menu with programs\n", 
                   "% corresponding to *.m files found in +plugins folder\n"])
    for root, dirs, files in os.walk(workdir, topdown=True):
        dirs[:] = [d for d in dirs if d not in excludedirs]
        files[:] = [f for f in files if f not in excludefiles]
        for file in files:
            filenamebase = os.path.splitext(file)[0]
            if os.path.splitext(file)[-1] in file_format:
                # TODO: arguments of function
                string = f"uimenu(item,'Label','{filenamebase.replace('_', ' ')}','Callback',@(~,~) plugins.{filenamebase}(''));\n"
                fw.write(string)
    fw.write("end")

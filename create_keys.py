#! python 3
# -*- coding:utf-8 -*-
import os
import time
import pexpect

filename_pre = 'client-vpn'
for num in range(113,114):
    newfile = filename_pre+str(num)
    print(newfile)
    child = pexpect.spawn('/bin/sh build-key '+newfile)
    time.sleep(0.1)
'''
    child.sendline()
    time.sleep(0.1)
    print(newfile+"+1")
    child.sendline()
    time.sleep(0.1)
    print(newfile + "+2")
    child.sendline()
    time.sleep(0.1)
    print(newfile + "+3")
    child.sendline()
    time.sleep(0.1)
    print(newfile + "+4")
    child.sendline()
    time.sleep(0.1)
    print(newfile + "+5")
    child.sendline()
    time.sleep(0.1)
    print(newfile + "+6")
    child.sendline()
    time.sleep(0.1)
    print(newfile + "+7")
    child.sendline()
    time.sleep(0.1)
    print(newfile + "+8")
    child.sendline()
    time.sleep(0.1)
    print(newfile + "+9")
    child.sendline('y')
    time.sleep(0.1)
    print(newfile + "+y1")
    child.sendline('y')
    time.sleep(0.1)
    print(newfile + "+y2")
'''
    for i in range(9):
    	child.sendline()
   	time.sleep(0.1)
   	print(newfile + i)
    child.sendline('y')
    time.sleep(0.1)
    print(newfile + "+y1")
    child.sendline('y')
    time.sleep(0.1)
    print(newfile + "+y2")

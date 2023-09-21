#!/usr/bin/env python3
"""
two functions:
(1) remove modules
(2) extract moudules
"""
import argparse
import os
import sys
import re
import logging
import json
bin = os.path.abspath(os.path.dirname(__file__))
__author__='Ren Xue'
__mail__= 'xueren@genome.cn'
__date__= '2021年03月17日 星期三 17时12分12秒'

def read_config(tmp):
	config_dict={}
	config_dict["smalltools"]={}
	with open(tmp,"r") as file:
		for line in file:
			tmp=line.rstrip("\n").split("\t")
			config_dict["smalltools"][tmp[0]]={}
			config_dict["smalltools"][tmp[0]]["alias"]=tmp[1]
			config_dict["smalltools"][tmp[0]]["input_name"]=tmp[2]
	return config_dict

def main():
	parser=argparse.ArgumentParser(description=__doc__,formatter_class=argparse.RawDescriptionHelpFormatter,epilog='author:\t{0}\nmail:\t{1}\ndate:\t{2}\n'.format(__author__,__mail__,__date__))
	parser.add_argument('-i','--config',help='input_template',dest='config',type=str,required=True)
	parser.add_argument('-o','--json',help='input_template',dest='json',type=str,required=True)
	args=parser.parse_args()

	config_dict = read_config(args.config)
	outjson = open(args.json,"w",encoding='utf8')
	json.dump(config_dict, outjson,indent=4, separators=(',', ':'), ensure_ascii=False)
	outjson.close()

if __name__=="__main__":
	main()

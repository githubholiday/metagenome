#!/usr/bin/env python3
"""
substitute something 
"""
import argparse
import os
import sys
import re
import logging
import json
import subprocess

pat1=re.compile('^\s+$')
bin = os.path.abspath(os.path.dirname(__file__))
__author__='Ren Xue'
__mail__= 'xueren@genome.cn'
__date__= '2019年01月03日 星期四 13时57分56秒'


def read_template(template):
	##读取文件
	module_dict={}
	title="NA"
	module_list=[]
	with open(template,"r") as file:
		for line in file:
			if line.strip().startswith("@@@@"):
				title=line.strip().lstrip("@@@@")
				if title in module_dict:
					sys.stderr.write("{0} already exists, please make sure")
					sys.exit(1)
				else:
					module_dict[title]=line
					module_list.append(title)
			else:
				module_dict[title]+=line
	return module_dict, module_list
def read_all_json(file):
	##读取json
	config={}
	config_dir={}
	with open(file,'r') as load_f:
		config = json.load(load_f)
	## 后边要通过模块路径定位json所属模块
	for m in config:
		config_dir[m]=[]
		for k in config[m]:
			value = config[m][k]
			dir = os.path.dirname(value)
			config_dir[m].append(dir)
	return config_dir

def read_json(file):
	##读取json
	config={}
	config_dir={}
	with open(file,'r') as load_f:
		config = json.load(load_f)
	return config

def get_json(upload):
	## 为保证 replace.json 最终都能删除， 所以必须扫描这个路径下所有replace.json，
	replace_file = "{0}/replace.json.path".format(upload)
	os.system("find {0}/upload -name replace.json >{0}/replace.json.path".format(upload))
	all_dir={}
	all=[]
	if os.path.exists(replace_file):
		with open(replace_file,"r") as file:
			for line in file:
				all.append(line.rstrip("\n"))
	for i in all:
		dir = os.path.dirname(i).replace(upload,"").strip("/")
		all_dir[dir]=1
	return all_dir
def rm_json(file):
	a = os.system('rm -rf {0}'.format(file))
	if a!=0:
		sys.stderr.write("{} delete  failed, pl make sure\n".format(file))


def replace_template(name,name_new,repalce_cofnig,template_dict):
	for k in repalce_cofnig[name]:
		## 如果json 有，template 没有
		if not name_new in template_dict: continue
		else:
			template_dict[name_new]=template_dict[name_new].replace("$({0})".format(k),repalce_cofnig[name][k])

def deal_replace(input_json, template_dict, replace_dir, upload):
	##按顺序扫描
	for d in replace_dir:
		json_file = '{0}/{1}/replace.json'.format(upload,d)
		repalce_cofnig=read_json(json_file)
		if len(repalce_cofnig)==0:
			rm_json(json_file)
		else:
			name = list(repalce_cofnig.keys())[0]
			## 如果模块名称一致
			if name in input_json:
				name_new = name
				print(repalce_cofnig)
				replace_template(name,name_new,repalce_cofnig,template_dict)
			else:
			## 如果模块名称不一致
				for m in input_json:
					if d in input_json[m]:
						name_new = m
						replace_template(name,name_new,repalce_cofnig,template_dict)
			rm_json(json_file)

def write_out(outfile,template_dict,template_list ):
	out = open(outfile,"w")
	for i in template_list:
		out.write(template_dict[i])
	out.close()


def main():
	parser=argparse.ArgumentParser(description=__doc__,formatter_class=argparse.RawDescriptionHelpFormatter,epilog='author:\t{0}\nmail:\t{1}\ndate:\t{2}\n'.format(__author__,__mail__,__date__))
	parser.add_argument('-o','--outfile',help='outfile name',dest='outfile',type=str,required=True)
	parser.add_argument('-i','--indir',help='dir has upload',dest='indir',type=str,required=True)
	parser.add_argument('-j','--json',help='input.json',dest='json',type=str,required=True)
	parser.add_argument('-t','--template',help='template.md',dest='template',type=str,required=True)

	args=parser.parse_args()
	## 
	template_dict, template_list = read_template(args.template)
	input_dict = read_all_json(args.json)
	replace_dict = get_json(args.indir)
	deal_replace(input_dict, template_dict, replace_dict, args.indir)
	write_out(args.outfile,template_dict, template_list )






if __name__=="__main__":
	main()



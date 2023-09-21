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
import glob
bin = os.path.abspath(os.path.dirname(__file__))
__author__='Ren Xue'
__mail__= 'xueren@genome.cn'
__date__= '2021年03月17日 星期三 17时12分12秒'

def read_tmp(tmp):
	template={}
	order=[]
	with open(tmp,"r") as file:
		title=""
		for line in file:
			if line.strip().startswith("@@@@"):
				 title=line.strip().lstrip("@@@@")
				 template[title]=line
				 order.append(title)
			else:
				if title!="":
					template[title]+=line
	return template,order

def check_json(json_dict,indir):
	rmdict={}
	for m in json_dict:
		for f in json_dict[m]:
			if re.search(r'_must$',f):
				if f.startswith("string"):continue
				if f.startswith("smalltool"):continue
				if f.startswith("href") and json_dict[m][f].startswith("http"):continue
				new='{0}/{1}'.format(indir,json_dict[m][f])
				files=glob.glob(new)
				if not files:
					if m in rmdict:
						rmdict[m].append(json_dict[m][f])
					else:
						rmdict[m]=[json_dict[m][f]]
	return rmdict

def read_json(file):
	config={}
	with open(file,'r') as load_f:
		config = json.load(load_f)
	return config	


def main():
	parser=argparse.ArgumentParser(description=__doc__,formatter_class=argparse.RawDescriptionHelpFormatter,epilog='author:\t{0}\nmail:\t{1}\ndate:\t{2}\n'.format(__author__,__mail__,__date__))
	parser.add_argument('-it','--input_template',help='input_template',dest='intmp',type=str,required=True)
	parser.add_argument('-ij','--input_json',help='input_json',dest='injson',type=str,required=True)
	parser.add_argument('-ot','--output_template',help='output_template',dest='outmp',type=str,required=True)
	parser.add_argument('-oj','--output_json',help='output_json',dest='outjson',type=str,required=True)
	parser.add_argument('-r','--remove',help='remove moudles, split by ,',dest='remove',type=str)
	parser.add_argument('-e','--extract',help='extract moudles, split by ,',dest='extract',type=str)
	parser.add_argument('-u','--upload',help='upload dir',dest='upload',type=str)
	args=parser.parse_args()

	template,order = read_tmp(args.intmp)
	config = read_json(args.injson)

	outmp = open(args.outmp,"w")
	outjson = open(args.outjson,"w")

	rmlist2={}
	if args.upload:
		rmlist2=check_json(config,args.upload)
	if args.remove and args.extract:
		sys.stderr.write("[Error] -r and -e can't exist at the same time\n")
		sys.exit(1)
	elif args.remove and not args.extract:
		rmlist=args.remove.split(",")
		for j in rmlist:
			rmlist2[j]=[]
		for i in order:
			if not i in rmlist2:
				outmp.write(template[i])
			else:
				print("DEL\t{0}\t{1}".format(i,"\t".join(rmlist2[i])))
				del config[i]
	elif not args.remove and args.extract:
		getlist=args.extract.split(",")
		newconfig={}
		for i in order:
			if i in getlist:
				if not i in rmlist2:
					outmp.write(template[i])
				else:
					print("DEL\t{0}\t{1}".format(i,"\t".join(rmlist2[i])))
					del config[i]
			else:
				print("DEL\t{0}\t{1}".format(i,"\t".join(rmlist2[i])))
				del config[i]
	else:
		sys.stderr.write("[Warning] -r and -e don't exist, template change based on whether file exists\n")
		for i in order:
			if not i in rmlist2:
				outmp.write(template[i])
			else:
				print("DEL\t{0}\t{1}".format(i,"\t".join(rmlist2[i])))
				del config[i]
	json.dump(config, outjson,indent=4, separators=(',', ':'))
	outmp.close()
	outjson.close()

if __name__=="__main__":
	main()

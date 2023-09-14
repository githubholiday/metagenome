#!/usr/bin/env python3
"""
indir：下面必须有input.json 和 upload文件夹
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
__date__= '2021年05月07日 星期五 17时55分31秒'



def main():
	parser=argparse.ArgumentParser(description=__doc__,formatter_class=argparse.RawDescriptionHelpFormatter,epilog='author:\t{0}\nmail:\t{1}\ndate:\t{2}\n'.format(__author__,__mail__,__date__))
	parser.add_argument('-o','--outfile',help='outfile name',dest='outfile',type=str,required=True)
	parser.add_argument('-i','--indir',help='indir',dest='indir',type=str,required=True)
	args=parser.parse_args()
	input_json='{0}/input.json'.format(args.indir)
	out=open(args.outfile,"w")
	#out.write("Module\titem\tfile_not_exist\n")
	if not os.path.exists(input_json):
		sys.stderr.write("{0}路径下没有input.json".format(args.indir))
		sys.exit(1)
	json_config={}
	with open(input_json,'r') as load_f:
		json_config = json.load(load_f)
	for m in json_config:
		for i in json_config[m]:
			if i.startswith("string"):continue
			if i.startswith("smalltool"):continue
			if i.startswith("href") and json_config[m][i].startswith("http"):continue
			new='{0}/{1}'.format(args.indir,json_config[m][i])
			files=glob.glob(new)
			if not files:
				out.write("{0}\t{1}\t{2}\n".format(m,i,json_config[m][i]))
	out.close()


if __name__=="__main__":
	main()

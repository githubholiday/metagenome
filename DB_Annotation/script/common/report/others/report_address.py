#!/usr/bin/env python3
"""
do something
"""
import argparse
import os
import sys
import re
import logging
import uuid
bin = os.path.abspath(os.path.dirname(__file__))
__author__='Ren Xue'
__mail__= 'xueren@genome.cn'
__date__= '2021年07月07日 星期三 14时25分30秒'


def main():
	parser=argparse.ArgumentParser(description=__doc__,formatter_class=argparse.RawDescriptionHelpFormatter,epilog='author:\t{0}\nmail:\t{1}\ndate:\t{2}\n'.format(__author__,__mail__,__date__))
	parser.add_argument('-p','--project',help='project id',dest='project',type=str,required=True)
	parser.add_argument('-o','--outfile',help='outfile name',dest='outfile',type=str,required=True)
	parser.add_argument('-t','--test',help='whether or not',dest='test',action='store_true')
	parser.add_argument('-a','--analysis',help='analysis type eg:Transcriptome',dest='analysis',default='analysis')
	args=parser.parse_args()
	uid_value = uuid.uuid4()
	if not args.test:
		address='https://c.solargenomics.com/final-report/index.html?idCode={0}&external={1}&internal=dev&annoroad={2}'.format(args.project,uid_value,args.analysis)
	else:
		address='https://test-c.solargenomics.com/final-report/index.html?idCode={0}&external={1}&internal=dev&annoroad={2}'.format(args.project,uid_value,args.analysis)
	
	out=open(args.outfile,"w")
	out.write("报告交付地址如下：\n{0}\n".format(address))
	print("报告交付地址如下：\n{0}\n".format(address))
	out.close
	
	


if __name__=="__main__":
	main()

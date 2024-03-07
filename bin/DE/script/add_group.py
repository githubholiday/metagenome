'''

解析Kegg pathway页面信息，获取KEGG的层级关系
输入：
html文件
'''


#! /usr/bin/env python3
import argparse
import sys
import os
import re
import datetime
import glob
import json
import configparser

bindir = os.path.abspath(os.path.dirname(__file__))
filename=os.path.basename(__file__)

__author__='tu chengfang '
__mail__= 'chengfangtu@genome.cn'

# ====== 公共模块 =================================
class Log():
	def __init__( self, filename, funcname = '' ):
		self.filename = filename 
		self.funcname = funcname
	def format( self, level, message ) :
		date_now = datetime.datetime.now().strftime('%Y%m%d %H:%M:%S')
		formatter = ''
		if self.funcname == '' :
			formatter = '\n{0} - {1} - {2} - {3} \n'.format( date_now, self.filename, level, message )
		else :
			
			formatter = '\n{0} - {1} - {2} -  {3} - {4}\n'.format( date_now, self.filename, self.funcname, level, message )
		return formatter
	def info( self, message ):
		formatter = self.format( 'INFO', message )
		sys.stdout.write( formatter )
	def debug( self, message ) :
		formatter = self.format( 'DEBUG', message )
		sys.stdout.write( formatter )
	def warning( self, message ) :
		formatter = self.format( 'WARNING', message )
		sys.stdout.write( formatter )
	def error( self, message ) :
		formatter = self.format( 'ERROR', message )
		sys.stderr.write( formatter )
	def critical( self, message ) :
		formatter = self.format( 'CRITICAL', message )
		sys.stderr.write( formatter )
		
def get_group( sample_file ):
	sample_dict = {}
	with open( sample_file, 'r' ) as input:
		for line in input:
			if line.startswith( 'Sample' ): continue
			tmp = line.rstrip().split('\t')
			sample = tmp[0]
			group = tmp[1]
			if sample not in sample_dict:
				sample_dict[sample] = group
			else:
				my_log.error("样本信息重复:{0} 在 {1}重复出现".format( sample, sample_file))
				sys.exit(1)
	return sample_dict
	
def get_group_list( sample_list, sample_dict):
	group_list = []
	for sample in sample_list :
		if sample not in sample_dict:
			my_log.error("样本信息不对应,{0} 不在-s参数文件中".format( sample))
			sys.exit(1)
		group = sample_dict[sample]
		group_list.append(group)
	return group_list 

def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--infile',help='infile',dest='infile',required=True)
	parser.add_argument('-s','--sample_file',help='outdir',dest='sample_file',required=True)
	parser.add_argument('-o','--outfile',help='outfile',dest='outfile',required=True)
	args=parser.parse_args()
	
	sample_dict = get_group(args.sample_file)
	group_list = []
	with open( args.infile, 'r') as input, open( args.outfile, 'w') as output:
		for line in input:
			if line.startswith('species'):
				tmp = line.rstrip().split('\t')
				sample_list = tmp[1:]
				group_list = get_group_list(sample_list, sample_dict)
				tmp[0] = 'Sample'
				output.write('\t'.join(tmp)+'\n')
				output.write('Sample\t'+'\t'.join(group_list)+'\n')
				continue
			output.write(line)
				
				
				
				
		 
if __name__ == '__main__':
	my_log = Log(filename)
	main()
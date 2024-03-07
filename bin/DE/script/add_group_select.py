'''
给文件增加group信息，并挑选本次分析使用的比较组，输出到文件中
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
		
def get_group( sample_file, group_list ):
	'''
    根据样本信息表获取样本和组对应关系，并只获取group_list中包含的group信息
    sample_dict  key:sample, value:group
    '''
	sample_dict = {}
	with open( sample_file, 'r' ) as input:
		for line in input:
			tmp = line.rstrip().split('\t')
			sample = tmp[0]
			group = tmp[1]
			if sample == 'Sample' : continue
			if group not in group_list : continue
			if sample not in sample_dict:
				sample_dict[sample] = group
			else:
				my_log.error("样本信息重复:{0} 在 {1}重复出现".format( sample, sample_file))
				sys.exit(1)
	my_log.info("处理的样本和组为:")
	my_log.info(sample_dict)
	return sample_dict
	
def get_group_list( sample_list, sample_dict):
	group_list = []
	sample_index_list = []
	for sample_index, sample in enumerate(sample_list) :
		if sample not in sample_dict:
			continue
		sample_index_list.append(sample_index)
		group = sample_dict[sample]
		
		group_list.append(group)
	return group_list,sample_index_list

def get_list8index( index_list, in_list):
	out_list = [ in_list[i] for i in index_list]
	return out_list

def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--infile',help='infile',dest='infile',required=True)
	parser.add_argument('-s','--sample_file',help='outdir',dest='sample_file',required=True)
	parser.add_argument('-o','--outfile',help='outfile',dest='outfile',required=True)
	parser.add_argument('-cmp','--cmp',help='cmp',dest='cmp',required=True,nargs='+')
	args=parser.parse_args()
	
	sample_dict = get_group(args.sample_file,args.cmp)
	group_list = []
	with open( args.infile, 'r') as input, open( args.outfile, 'w') as output:
		sample_index_list = []
		for line in input:
			if line.startswith('Sample'):
				tmp = line.rstrip().split('\t')
				sample_list = tmp[1:]
				group_list, sample_index_list = get_group_list(sample_list, sample_dict)
				tmp_t = get_list8index( sample_index_list, sample_list)
			
				tt = ['Sample']+tmp_t
				output.write('\t'.join(tt)+'\n')
				output.write('Sample\t'+'\t'.join(group_list)+'\n')
				continue
			else:
				tmp = line.rstrip().split('\t')
				sample_list = tmp[1:]
				tmp_t = get_list8index( sample_index_list, sample_list)
				if tmp_t == ['0','0']: continue
				tt = [tmp[0]]+tmp_t
				output.write('\t'.join(tt)+'\n')
			#output.write(line)
if __name__ == '__main__':
	my_log = Log(filename)
	main()

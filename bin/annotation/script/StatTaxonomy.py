'''
功能：
    从物种注释结果文件中提取特定一个水平的物种分类，并且统计各个分类的频数

参数：
'-i','--input', 输入文件
'-t','--taxonomy', 分类水平，像genus，species
'-o','--output', 输出文件

'''
#! /usr/bin/env python3
import argparse
import sys
import os
import re
import time
import logging
import gzip
import configparser
bindir = os.path.abspath(os.path.dirname(__file__))
# sys.path.append('{0}/../lib'.format(bindir))
# from readconfig import *

__author__='zhang yue'
__mail__= 'yuezhang@genome.cn'

pat1=re.compile('^\s+$')
now = time.strftime("%Y-%m-%d %H:%M:%S")
LOG = os.path.basename(__file__)

def my_log( level, message ) :
	logging.basicConfig(level = logging.INFO,format = '%(asctime)s - %(filename)s - %(levelname)s - %(message)s')
	logger = logging.getLogger(__name__)
	if level == 'info' :
		return logger.info( message )
	if level == 'warning' :
		return logger.warning( message )
	if level == 'debug' :
		return logger.debug( message )
	if level == 'error' :
		return logger.error( message )

def check_file_exists( *file_list ) :
	for file in file_list :
		if os.path.exists( file ) :
			my_log( 'info', 'file : {0}'.format( file ) )
		else :
			my_log( 'error', 'file is not exists : {0}'.format( file ) )

def make_dir( dir ) :
	if not os.path.exists( dir ) :
		try :
			os.makedirs( dir )
			time.sleep(1)
			my_log( 'info', 'mkdir {0} sucessful!'.format( dir) )
		except :
			my_log( 'error', 'mkdir {0} failed!'.format( dir) )
	else :
		my_log( 'info', '{0} is exist'.format( dir ) )

def myrun( cmd ) :
	if os.system( cmd ) == 0 :
		my_log( 'info', '{0} run sucessfully !'.format( cmd ) )
	else :
		my_log( 'error', '{0} run failed !'.format( cmd ) )

def read_input( input, level ) :
	dict = {}
	all_line = 0
	with open ( input, 'r' ) as IN :
		for line in IN :
			if line.startswith('Gene_ID') : continue
			all_line += 1
			all_taxonomy = line.split('\t')[1]
			tmp = all_taxonomy.split('|')
			for i in tmp :
				l, n = i.split(':', 1)
				if l == level :
					if not n in dict :
						dict[n] = 1
					else :
						dict[n] += 1
				#else :
				#	dict['undetermined'] += 1
	return dict, all_line

def output( output, dict ) :
	with open( output, 'w' ) as OUT :
		OUT.write('taxonomy\tabundance\n')
		for i in dict :
			OUT.write('{0}\t{1}\n'.format(i, dict[i]))

def stat( top_list, all_line, output ) :
	sum = 0
	with open ( output, 'w' ) as OUT :
		OUT.write( 'taxonomy\tpercentage\n' )
		for i in top_list :
			k, v = i
			p = '{0:.2f}'.format( (v/all_line)*100 )
			OUT.write( '{0}\t{1}\n'.format( k, p ) )
			sum += v
		other = '{0:.2f}'.format( ((all_line-sum)/all_line)*100 )
		OUT.write( '{0}\t{1}\n'.format( 'other', other ) )

def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--input',help='input file',dest='input',required=True)
	parser.add_argument('-t','--taxonomy',help='taxonomy level',dest='taxonomy',required=True)
	parser.add_argument('-o','--output',help='output dir',dest='output',required=True)
	args=parser.parse_args()

	check_file_exists( args.input )
	dict, all_line = read_input( args.input, args.taxonomy )
	output( args.output, dict )
	# top = sorted(dict.items(), key = lambda kv:(kv[1], kv[0]))[-20:]
	# stat( top, all_line, args.output )

if __name__ == '__main__':
	main()

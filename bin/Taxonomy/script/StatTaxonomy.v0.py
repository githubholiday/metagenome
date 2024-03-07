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

def read_input( input ) :
	dict = {}
	all_line = 0
	with open ( input, 'r' ) as IN :
		for line in IN :
			if line.startswith('Gene_ID') : continue
			taxonomy = line.split('\t')[1]
			if not taxonomy in dict :
				dict[taxonomy] = 1
			else :
				dict[taxonomy] += 1
			all_line += 1
	return dict, all_line

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
	parser.add_argument('-o','--output',help='output dir',dest='output',required=True)
	args=parser.parse_args()

	check_file_exists( args.input )
	dict, all_line = read_input( args.input )
	
	top10 = sorted(dict.items(), key = lambda kv:(kv[1], kv[0]))[-10:]
	stat( top10, all_line, args.output )

if __name__ == '__main__':
	main()

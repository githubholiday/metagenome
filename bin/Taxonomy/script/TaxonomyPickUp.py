'''
功能：
    根据NR比对结果获取物种，输出2列结果，第一列为gene，第二列为各个水平的分类信息
    
参数：
'-i','--input', NR注释结果文件，包含gene和accession信息
'-a','--accession2taxid', NCBI中下载的prot.accession2taxid文件，包含accession和taxid信息
'-t','--taxinfo', NCBI中下载的TaxInfo.txt文件，包含taxid和物种分类信息
'-o','--output', 结果输出文件
    
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

def read_accession2taxid( file ) :
	my_log( 'info', 'start reading file {0}'.format(file) )
	accession2taxid_dict = {}
	with open( file, 'r' ) as IN :
		for line in IN :
			if line.startswith('accession') :continue
			accession_version, taxid = line.split('\t')[1:3]
			if not accession_version in accession2taxid_dict :
				accession2taxid_dict[accession_version] = taxid
			else :
				print ( accession_version )
	my_log( 'info', 'finish reading file {0}'.format(file) )
	return accession2taxid_dict

def read_taxinfo( file ) :
	my_log( 'info', 'start reading file {0}'.format(file) )
	tax_dict = {}
	with open( file, 'r' ) as IN :
		for line in IN :
			tmp = line.rstrip().split('\t')
			id = tmp[0]
			if not id in tax_dict :
				tax_dict[id] = tmp
			else :
				print ( id )
	my_log( 'info', 'finish reading file {0}'.format(file) )
	return tax_dict

def get_taxonomy( input, output, accession2taxid_dict, tax_dict ) :
	with open ( input, 'r' ) as IN, open( output, 'w' ) as OUT :
		OUT.write( 'Gene_ID\ttaxonomy\n' )
		for line in IN :
			if line.startswith('Gene_ID') :continue
			gene, accession = line.split('\t')[0:2]
			#accession = accession.split('|')[1]
			accession = accession.split('|')[0]
			taxid = accession2taxid_dict.get( accession, 'unknown' )
			if taxid == 'unknown' :
				print ( 'unknown accession id {0}'.format( accession ) )
				continue
			taxonomy = tax_dict.get( taxid, 'unknown' )
			if taxonomy == 'unknown' :
				print ( 'unknown tax id {0}'.format( taxid ) )
				continue
			tmp = taxonomy[-1].split('-')
			tax_info = '{0}:{1}'.format( tmp[0], taxonomy[1] )
			for i in tmp[1:] :
				id, tax = i.split(':')
				tax_info += '|{0}:{1}'.format( tax, tax_dict[id][1] )
			OUT.write( '{0}\t{1}\n'.format(gene, tax_info ) )

def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--input',help='input file',dest='input',required=True)
	parser.add_argument('-a','--accession2taxid',help='accession2taxid file',dest='accession2taxid',required=True)
	parser.add_argument('-t','--taxinfo',help='taxinfo file',dest='taxinfo',required=True)
	parser.add_argument('-o','--output',help='output file',dest='output',required=True)
	args=parser.parse_args()

	check_file_exists( args.input, args.accession2taxid, args.taxinfo )
	accession2taxid_dict = read_accession2taxid( args.accession2taxid )
	tax_dict = read_taxinfo( args.taxinfo )
	get_taxonomy( args.input, args.output, accession2taxid_dict, tax_dict )

if __name__ == '__main__':
	main()

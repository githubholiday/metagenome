#! /usr/bin/env python3
import argparse
import sys
import os
import re
import time
import logging
import configparser

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

def read_file( file ) :
    gene_dict = {}
    with open ( file, 'r' ) as IN :
        for line in IN :
            if line.startswith('#') or re.search(pat1,line):continue
            gene, num = line.strip().split('\t')[0:2]
            gene = gene.split('|')[0]
            gene_dict[gene] = num
    return gene_dict

def main():
    parser=argparse.ArgumentParser(description=__doc__,
            formatter_class=argparse.RawDescriptionHelpFormatter,
            epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
    parser.add_argument('-i','--intput',help='input file',dest='input',required=True)
    parser.add_argument('-o','--output',help='output file',dest='output',type=argparse.FileType('w'),required=True)
    parser.add_argument('-a','--antation',help='gene antation file',dest='antation',type=argparse.FileType('r'),required=True)
    args=parser.parse_args()

    gene_dict = read_file( args.input )
    
    for n,line in enumerate(args.antation) :
        if n == 0 :
            args.output.write( line )
        else :
            tmp = line.strip().split('\t')
            gene_id = tmp[0].split("|")[0] #2021年8月20日08:58:13 李华云修复输出为空的bug
            if gene_id in gene_dict: #同上
            #if tmp[0] in gene_dict : #原代码
                args.output.write( line )

if __name__ == '__main__':
    main()

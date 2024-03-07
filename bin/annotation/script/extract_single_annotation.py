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

def myrun( cmd ) :
    if os.system( cmd ) == 0 :
        my_log( 'info', '{0} run sucessfully !'.format( cmd ) )
    else :
        my_log( 'error', '{0} run failed !'.format( cmd ) )

def read_file( file ) :
    gene_list = []
    with open ( file, 'r' ) as IN :
        for line in IN :
            if line.startswith('#') or re.search(pat1,line):continue
            tmp = line.strip().split('\t')
            gene = tmp[0]
            gene_name = gene.split('|')[0]
            if gene_name not in gene_list :
                gene_list.append(gene_name)
    return gene_list

def main():
    parser=argparse.ArgumentParser(description=__doc__,
            formatter_class=argparse.RawDescriptionHelpFormatter,
            epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
    parser.add_argument('-i','--intput',help='input file',dest='input',required=True)
    parser.add_argument('-a','--antation',help='gene antation file',dest='annotation',required=True)
    parser.add_argument('-o','--output',help='output file',dest='output')
    args=parser.parse_args()
    #print("读取 {0}".format(args.annotation))
    #anno_gene_list = read_file( args.annotation )
    #print("读取完成 {0}".format( args.annotation ))
    final_matain_list = []
    with open( args.input, 'r') as infile:
        for line in infile:
            tmp = line.rstrip().split('\t')
            gene_name = tmp[0]
            if gene_name not in final_matain_list :
                final_matain_list.append(gene_name)
    print("读取完成:{0}".format( args.input ))
    with open( args.annotation, 'r') as annotation_file, open( args.output, 'w') as outfile :
        for line in annotation_file :
            if line.startswith("Gene_ID") :
                outfile.write( line )
            else :
                tmp = line.rstrip().split('\t')
                gene_id = tmp[0]
                if gene_id in final_matain_list:
                    outfile.write( line )

if __name__ == '__main__':
    main()

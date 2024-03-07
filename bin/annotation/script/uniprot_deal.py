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
    pro_dic = {}
    repeat_list = []
    with open ( file, 'r' ) as IN :
        for line in IN :
            if line.startswith('#') or re.search(pat1,line):continue
            tmp = line.strip().split('\t')
            pro = tmp[0]
            ko = tmp[2]
            if pro not in pro_dic:
                pro_dic[pro] = ko
            else:
                repeat_list.append( pro )

    return pro_dic,repeat_list

def main():
    parser=argparse.ArgumentParser(description=__doc__,
            formatter_class=argparse.RawDescriptionHelpFormatter,
            epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
    parser.add_argument('-k','--ko',help='ko list',dest='ko',required=True)
    parser.add_argument('-a','--antation',help='uniprot annotation file',dest='annotation',required=True)
    parser.add_argument('-o','--output',help='output file',dest='output')
    args=parser.parse_args()
    print("读取 {0}".format(args.ko))
    pro_dic, repeat_list = read_file( args.ko )
    print("读取完成 {0}".format( args.ko ))

    with open( args.annotation, 'r') as infile, open( args.output, 'w') as outfile :
        for line in infile:
            tmp = line.rstrip().split('\t')
            pro_name = tmp[0]
            if pro_name not in pro_dic:
                outfile.write( line )
            else:
                tmp[3] = pro_dic[pro_name]
                outfile.write( '\t'.join( tmp) + '\n' )
            if pro_name in repeat_list :
                print(pro_name)

if __name__ == '__main__':
    main()

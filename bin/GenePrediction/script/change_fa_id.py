'''
对MetaGeneMark的结果，修改fa文件的id
>gene_1|GeneMark.hmm|363_nt|-|3|365     >k141_84084 flag=1 multi=5.0000 len=367 修改为 >gene_1
'''
#! /usr/bin/env python3
import argparse
import sys
import os
import re
import time
import logging
import configparser
#import matplotlib
#matplotlib.use('Agg')
#import matplotlib.pyplot as plt

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

def main():
    parser=argparse.ArgumentParser(description=__doc__,
            formatter_class=argparse.RawDescriptionHelpFormatter,
            epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
    parser.add_argument('-i','--intput',help='input fasta file',dest='input',type=argparse.FileType('r'),required=True)
    parser.add_argument('-o','--output',help='output file',dest='output',type=argparse.FileType('w'),required=True)
    parser.add_argument('-n','--numout',help='numout',dest='numout',type=argparse.FileType('w'),required=False)
    parser.add_argument('-s','--sample',help='sample name',dest='sample',required=True)
    args=parser.parse_args()

    orf_num = 0
    for line in args.input :
        if line.startswith('#') or re.search(pat1,line):continue
        if line.startswith('>') :
            tmp = line.split('|')
            id = tmp[0] + '_' + args.sample + '|' + tmp[2]
            args.output.write(id+'\n')
            orf_num += 1
        else :
            args.output.write(line)
    if args.numout:
        args.numout.write("{0}\t{1}".format(args.sample,orf_num))
    
if __name__ == '__main__':
    main()

#! /usr/bin/env python3
import argparse
import sys
import os
import re
import time
import logging
import math
import configparser
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

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
    parser.add_argument('-i','--intput',help='input fasta file',dest='input',required=True)
    parser.add_argument('-n','--number',help='interval number',dest='number',type=int,required=True)
    parser.add_argument('-p','--output',help='output pdf file',dest='output',required=True)
    args=parser.parse_args()

    make_dir( os.path.dirname(args.output) )
    
    gene_length_dict = {}
    check_file_exists( args.input )
    with open( args.input, 'r' ) as IN :
        for line in IN :
            if line.startswith('#') or re.search(pat1,line):continue
            if line.startswith('>') :
                id = line.split(' ')[0]
                gene_length_dict[id] = 0
            else :
                gene_length_dict[id] += len(line)

    length_count_dict = {}
    for i in gene_length_dict.values() :
        tmp = math.floor(i/args.number)
        left = str( args.number*tmp + 1 )
        right = str( args.number*(tmp+1) )
        # key = str(left + '-' + right)
        key = right
        if key in length_count_dict :
            length_count_dict[key] += 1
        else :
            length_count_dict[key] = 1

    bar_width = 100
    bar_color = 'green'
    plt.title( 'distribution' )
    plt.xlabel( 'contig length' )
    plt.ylabel( 'contig number' )
    # plt.axis([ 0.9*min(length_count_dict.keys()), 1.1*max(length_count_dict.keys()), 0.9*min(length_count_dict.values()), 1.1*max(length_count_dict.values()) ])
    # plt.axis([ 0, 1.1*len(length_count_dict.keys()), 0.9*min(length_count_dict.values()), 1.1*max(length_count_dict.values()) ])
    plt.bar( length_count_dict.keys(), length_count_dict.values(), width = bar_width, color = bar_color, linewidth = 0 )
    plt.savefig( args.output )

if __name__ == '__main__':
    main()

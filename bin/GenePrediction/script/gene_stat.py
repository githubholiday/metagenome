#! /usr/bin/env python3
import argparse
import sys
import os
import re
import time
import logging
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
    parser.add_argument('-i','--intput',help='input fasta file',nargs = '+',dest='input',required=True)
    parser.add_argument('-o','--outstat',help='output stat file',dest='outstat',required=True)
    parser.add_argument('-p','--output',help='output pdf file',dest='output',required=True)
    args=parser.parse_args()

    make_dir( os.path.dirname(args.output) )
    
    gene_length_dict = {}
    for file in args.input :
        check_file_exists( file )
        with open( file, 'r' ) as IN :
            for line in IN :
                if line.startswith('#') or re.search(pat1,line):continue
                if line.startswith('>') :
                    id = line.split('|')[0]
                    gene_length_dict[id] = 0
                else :
                    gene_length_dict[id] += len(line)

    
    genes_num = len( gene_length_dict )
    max_length = max( gene_length_dict.values() )
    min_length = min( gene_length_dict.values() )
    total_length = sum( gene_length_dict.values() )
    average_length = '{0:.2f}'.format( total_length/genes_num )

    with open(args.outstat, 'w') as OUT :
        title = 'Genes\tTotal length(bp)\tAverage length(bp)\tMax(bp)\tMin(bp)\n'
        OUT.write( title)
        out = '{0}\t{1}\t{2}\t{3}\t{4}\n'.format( genes_num, total_length, average_length, max_length, min_length )
        OUT.write( out )
    #print( genes_num, total_length, average_length )

    length_count_dict = {}
    for i in gene_length_dict.values() :
        if i in length_count_dict :
            length_count_dict[i] += 1
        else :
            length_count_dict[i] = 1

    bar_width = 10
    bar_color = 'green'
    plt.title( 'distribution' )
    plt.xlabel( 'ORF length' )
    plt.ylabel( 'count' )
    plt.axis([ 0.9*min(length_count_dict.keys()), 1.1*max(length_count_dict.keys()), 0.9*min(length_count_dict.values()), 1.1*max(length_count_dict.values()) ])
    plt.bar( length_count_dict.keys(), length_count_dict.values(), width = bar_width, color = bar_color, linewidth = 0 )
    plt.savefig( args.output )

if __name__ == '__main__':
    main()

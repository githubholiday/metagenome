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
    dict = {}
    for line in file :
        if line.startswith('Gene_ID') or re.search(pat1,line):continue
        anno = line.strip().split('\t')[2].split('__')[0]
#        if not anno in dict : dict[anno] = 0
#        dict[anno] += 1
        if not anno in dict : dict[anno] = []
        dict[anno].append(line.strip().split('\t')[0])
    return dict

def main():
    parser=argparse.ArgumentParser(description=__doc__,
            formatter_class=argparse.RawDescriptionHelpFormatter,
            epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
    parser.add_argument('-i','--intput',help='input file',dest='input',type=argparse.FileType('r'),required=True)
    parser.add_argument('-o','--output',help='output file',dest='output',type=argparse.FileType('w'),required=True)
    args=parser.parse_args()

    dict = read_file( args.input )
    
    title = sorted(dict.keys())
#    values = [ str(dict[i]) for i in title]
#    args.output.write( '\t'.join(title) + '\n' + '\t'.join( values ) )
    name = list(dict.keys())
    args.output.write("Class\tAnnotation\tNumber\tGene\n")
    for i in range(65,65+len(name)):
        args.output.write("\t".join([chr(i),name[i-65],str(len(set(dict[name[i-65]]))),",".join(set(dict[name[i-65]]))])+"\n")


if __name__ == '__main__':
    main()

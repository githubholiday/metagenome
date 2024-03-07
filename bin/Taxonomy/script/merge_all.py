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

def read_file( file, list ) :
    anno_dict = {}
    with open ( file, 'r' ) as IN :
        for line in IN :
            if line.startswith('#') or re.search(pat1,line):continue
            anno, num = line.strip().split('\t')[0:2]
            anno_dict[anno] = num
            if not anno in list :
                list.append( anno )
    return anno_dict, list

def main():
    parser=argparse.ArgumentParser(description=__doc__,
            formatter_class=argparse.RawDescriptionHelpFormatter,
            epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
    parser.add_argument('-i','--intput',help='input fasta file',dest='input',nargs='+',required=True)
    parser.add_argument('-o','--output',help='output file',dest='output',type=argparse.FileType('w'),required=True)
    args=parser.parse_args()

    # make_dir( os.path.dirname(args.output) )
    
    info_dict = {}
    sample_list = []
    species_list = []
    for file in args.input :
        check_file_exists( file )
        sample = os.path.basename(file).split('.')[0]
        sample_list.append( sample )
        dict, species_list = read_file( file, species_list )
        info_dict[sample] = dict
        # print (gene_dict)
    
    title = '\t'.join(['Tax'] + sample_list)
    args.output.write( title + '\n' )
    
    tax_dict = {}
    for s in species_list :
        out = [ info_dict[sample].get(s, '0') for sample in sample_list ]
        all = sum([int(i) for i in out])
        if not all in tax_dict :
            tax_dict[all] = {}
        tax_dict[all][s] = out

    for a in sorted( tax_dict )[::-1] :
        for i in tax_dict[a] :
            out = [i] + tax_dict[a][i]
            out = [ str(i) for i in out ]
            args.output.write( '\t'.join(out) + '\n' )

if __name__ == '__main__':
    main()

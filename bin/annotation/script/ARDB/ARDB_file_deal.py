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
    ardb_dic = {}
    with open ( file, 'r' ) as IN :
        for line in IN :
            if line.startswith('#') or re.search(pat1,line):continue
            tmp = line.strip().split('\t')
            subject_id = tmp[0]
            if len(tmp) <= 2 :
                antibiotic = "-"
            else:
                antibiotic = tmp[2].rstrip(";")
                Type = tmp[1]
            if subject_id not in ardb_dic :
                ardb_dic[subject_id] = [Type,antibiotic]
    return ardb_dic

def main():
    parser=argparse.ArgumentParser(description=__doc__,
            formatter_class=argparse.RawDescriptionHelpFormatter,
            epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
    parser.add_argument('-a','--antation',help='gene antation file',dest='annotation',required=True)
    parser.add_argument('-d','--db',help='ardb file',dest='db')
    parser.add_argument('-o','--output',help='output file',dest='output')
    args=parser.parse_args()
    print("读取 {0}".format(args.db))
    ardb_dic = read_file( args.db )
    print("读取完成 {0}".format( args.db ))
    final_matain_list = []
    with open( args.annotation, 'r') as infile,open( args.output, 'w') as outfile :
        for line in infile:
            tmp = line.rstrip().split('\t')
            if line.startswith("Gene_ID") : 
                tmp.append('ARDB_type')
                tmp.append('ARDB_Antibiotic')
                outfile.write('\t'.join(tmp)+'\n')
                continue
            tmp = line.rstrip().split('\t')
            gene_id  = tmp[0]
            subject_id = tmp[1]
            annotation = tmp[2]
            annotation = annotation.replace("{0} ".format( subject_id),"")
            sub_name = subject_id.split("|")[0]
            if sub_name in ardb_dic :
                Type,antibiotic = ardb_dic[sub_name]
            else :
                Type,antibiotic = '-','-'
            out_value = [gene_id, sub_name, annotation, Type, antibiotic ]
            outfile.write("\t".join( out_value) + '\n')


if __name__ == '__main__':
    main()

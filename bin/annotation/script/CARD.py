#!/usr/bin/env python3
import pandas as pd 
import os
import sys 
import re
import argparse
bindir = os.path.abspath(os.path.dirname(__file__))

__author__='Yang Zhang'
__mail__= 'yangzhang@genome.cn'
__doc__='card database analysis' 


def main():
        parser=argparse.ArgumentParser(description=__doc__,
                        formatter_class=argparse.RawDescriptionHelpFormatter,
                        epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
        parser.add_argument('-l','--ARO_level',help='ARO_level.tsv',dest='ARO_level',required=True)
        parser.add_argument('-i','--infile',help='diamond_out.tsv',dest='infile',required=True)
        parser.add_argument('-o','--outfile',help='output file',dest='outfile',required=True)
        args=parser.parse_args()
        CARD_level = pd.read_csv(args.ARO_level , sep='\t')
        CARD_level = CARD_level.drop('protein',axis=1)
        GENE_CARD = pd.read_csv(args.infile , sep='\t' , header=None)
        GENE_CARD = GENE_CARD.iloc[:,[0,1]]
        GENE_CARD.columns=['Gene_ID','ARO_accession']
        CARD_annotation = pd.merge(GENE_CARD,CARD_level,on='ARO_accession',how='inner')
        CARD_annotation.to_csv(args.outfile , sep='\t' , index=0)

if __name__=="__main__":
        main()

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
        parser.add_argument('-i','--infile',help='diamond_out.tsv',dest='infile',required=True,nargs='+')
        parser.add_argument('-o','--outfile',help='output file',dest='outfile',required=True)
        args=parser.parse_args()






if __name__=="__main__":
        main()
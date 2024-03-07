#!/usr/bin/env python3
import pandas as pd 
import os
import sys 
import re
import argparse
bindir = os.path.abspath(os.path.dirname(__file__))

__author__='Yang Zhang'
__mail__= 'yangzhang@genome.cn'
__doc__='vfdb database analysis A/B' 


def main():
        parser=argparse.ArgumentParser(description=__doc__,
                        formatter_class=argparse.RawDescriptionHelpFormatter,
                        epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
        parser.add_argument('-v','--VFs',help='VFs.txt',dest='VFs',required=True)
        parser.add_argument('-a','--blastA',help='Gene_All.vfdbA/B.aln',dest='blastA',required=True)
        parser.add_argument('-A','--infoA',help='SetA/B_info.tsv',dest='infoA',required=True)
        parser.add_argument('-o','--outfile',help='VFDB_anno_SetA.tsv',dest='outfile',required=True)
        args=parser.parse_args()

        VFs = args.VFs
        blastA = args.blastA
        infoA = args.infoA
        outfile = args.outfile
        VF_anno = pd.read_csv( VFs , encoding='unicode_escape' , sep='\t')
        VF_anno = VF_anno.loc[:,['VFID','VF_FullName','Structure','Function','Mechanism']]
        VF_anno.columns=['VF_id','VF_FullName','Structure','Function','Mechanism']
        # VFDB_Set_A/B_anno
        alig = pd.read_csv( blastA , sep='\t',header=None)
        fasta_anno = pd.read_csv( infoA ,sep='\t')
        alig = alig.iloc[:,[0,1]]
        alig.columns = ['Gene_ID','VF_gene_id']
        alig['VF_gene_id'] = alig['VF_gene_id'].map(lambda x :x.split('(')[0])
        VFDB_anno=pd.merge(alig,fasta_anno,on='VF_gene_id',how='inner')
        VFDB_anno = pd.merge(VFDB_anno,VF_anno,on='VF_id',how='left')
        VFDB_anno = VFDB_anno.fillna("-")
        print(VFDB_anno)
        VFDB_anno.to_csv( outfile , sep='\t',index=0)

if __name__=="__main__":
        main()

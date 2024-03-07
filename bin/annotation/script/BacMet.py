#!/usr/bin/env python3
import pandas as pd 
import os
import sys 
import re
import argparse
bindir = os.path.abspath(os.path.dirname(__file__))

__author__='Yang Zhang'
__mail__= 'yangzhang@genome.cn'
__doc__='bacmet database analysis A/B' 


def main():
        parser=argparse.ArgumentParser(description=__doc__,
                        formatter_class=argparse.RawDescriptionHelpFormatter,
                        epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
        parser.add_argument('-e','--blastE',help='Gene_All.bacmetEXP.aln',dest='blastE',required=True)
        parser.add_argument('-E','--infoE',help='BacMet2_EXP.753.mapping.txt',dest='infoE',required=True)
        parser.add_argument('-p','--blastP',help='Gene_All.bacmetPRE.aln',dest='blastP',required=True)
        parser.add_argument('-P','--infoP',help='PBacMet2_PRE.155512.mapping.txt',dest='infoP',required=True)
        parser.add_argument('-oe','--outfileE',help='Gene_All.bacmetEXP.xls',dest='outfileE',required=True)
        parser.add_argument('-op','--outfileP',help='Gene_All.bacmetPRE.xls',dest='outfileP',required=True)
        args=parser.parse_args()

        blastE = args.blastE
        infoE = args.infoE
        outfileE = args.outfileE

        # EXP
        alig = pd.read_csv(blastE,sep='\t',header=0)
        anno = pd.read_csv(infoE,sep='\t')
        alig=alig.iloc[:,[0,1]]
        alig.columns=['Gene_ID','BacMet_ID']
        alig['BacMet_ID']= alig['BacMet_ID'].map(lambda x: x.split('|')[0])
        BacMet_anno = pd.merge(alig,anno,on='BacMet_ID',how='inner')
        
        BacMet_anno['Compound']=BacMet_anno['Compound'].map(lambda x : x.split(','))
        BacMet_anno = BacMet_anno.explode('Compound', ignore_index=True)
        BacMet_anno.to_csv(outfileE,sep='\t',index=0)

        blastP = args.blastP
        infoP = args.infoP
        outfileP = args.outfileP

        # PRE
        alig = pd.read_csv(blastP,sep='\t',header=0)
        anno = pd.read_csv(infoP,sep='\t')
        alig=alig.iloc[:,[0,1]]
        alig.columns=['Gene_ID','GI_number']
        alig['GI_number']= alig['GI_number'].map(lambda x: x.split('|')[1])
        anno['GI_number'] = anno['GI_number'].map(lambda x:str(x))
        BacMet_anno = pd.merge(alig,anno,on='GI_number',how='inner')
        BacMet_anno['Compound']=BacMet_anno['Compound'].map(lambda x : x.split(','))
        BacMet_anno = BacMet_anno.explode('Compound', ignore_index=True)
        BacMet_anno.to_csv(outfileP,sep='\t',index=0)


if __name__=="__main__":
        main()

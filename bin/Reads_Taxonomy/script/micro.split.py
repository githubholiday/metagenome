#!/usr/bin/env python3
import os
import sys 
import re
import argparse
bindir = os.path.abspath(os.path.dirname(__file__))

__author__='Yang Zhang'
__mail__= 'yangzhang@genome.cn'
__doc__='split merge.qiime.xls to different level files' 

def main():
        parser=argparse.ArgumentParser(description=__doc__,
                        formatter_class=argparse.RawDescriptionHelpFormatter,
                        epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
        parser.add_argument('-i','--infile',help='infile ',dest='infile',required=True)
        parser.add_argument('-o','--outdir',help='outdir for output file',dest='outdir',required=True)
        args=parser.parse_args()
        l = ["d","p","c","o","f","g","s"]
        real = ["Domain","Phylum","Class","Order","Family","Genus","Species"]
        for i in range(len(real)):
            locals()["OUT_" + l[i]] = open(args.outdir+"/merge.qiime_{}.xls".format(real[i]) , 'w')
        InFile = open(args.infile , 'r')
        for line in InFile:
            if line.startswith("Sample"):
                header = line
                for i in l:
                    locals()["OUT_" + i].write(header)

            else:
                tmp = line.strip().split("\t")
                species = tmp[0]
                count = tmp[1:len(tmp)]
                specie = species.strip().split("|")[-1]
                content = specie+"\t"+"\t".join(count)+"\n"
                prefix = specie.split("_")[0]
                index = l.index(prefix)
                locals()["OUT_" + prefix].write(content)
        for i in l:
            locals()["OUT_" + i].close()
        InFile.close()

if __name__=="__main__":
        main()

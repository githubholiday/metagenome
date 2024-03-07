import argparse
import os
import sys
def get_args():
    """
    Get arguments from command line with argparse.
    """
    parser = argparse.ArgumentParser(
        prog='CheckM-to-batch-GTDB.py',
        description="""Screen o2 format from CheckM to provide batch input file to GTDB.""")

    parser.add_argument("-i", "--infile",
                        required=True,
                        help="The o2 format summary file from CheckM.")
    parser.add_argument("-c", "--completeness",
                        required=False,
                        type=float,
                        default=60.0,
                        help="The minimum threshold for completeness (integer; a percent).")
    parser.add_argument("-m", "--contamination",
                        required=False,
                        type=float,
                        default=10.0,
                        help="The maximum threshold for contamination (integer; a percent).")
    parser.add_argument("-g", "--contigs",
                        required=False,
                        type=float,
                        default=10.0,
                        help="The maximum number of contigs allowed in a genome bin (integer).")
    parser.add_argument("-p", "--binpath",
                        required=True,
                        help="The path to the bins (do not include final / in path).")
    parser.add_argument("-o", "--outfile",
                        required=True,
                        help="The name of the output file.")
    parser.add_argument("-l", "--logfile",
                        required=True,
                        help="The name of the log file.")

    return parser.parse_args()

def parse_summary(infile, completeness_threshold, contamination_threshold, contigs_threshold, binpath, outfile):
    """
    Screens summary file to identify bins with particular thresholds
    of completeness, contamination, and contigs.
    :param infile: full path to o2 format summary file from CheckM
    :param completeness: minimum threshold for completeness
    :param contamination: maximum threshold for contamination
    :param contigs: maximum number of contigs allowed in a genome bin
    :return:
    """
    failed, passed = [], []
    with open(infile, 'r') as fhin, open(outfile, 'a') as fhout:
        next(fhin)
        for line in fhin:
            tmp = line.rstrip().split('\t')
            if len(tmp ) <=  12 :
                print("文件列数少于13，程序退出")
                sys.exit(1)
            binid = tmp[0]
            completeness_value = tmp[5]
            contamination_value = tmp[6]
            strain_hterogenetity = tmp[7]
            genome_size = tmp[8]
            conting_no = tmp[11]
            list_out= [binid, completeness_value, contamination_value, strain_hterogenetity, genome_size, conting_no]
            if float(completeness_value) >= completeness_threshold and float(contamination_value) <= contamination_threshold and float(conting_no) <= contigs_threshold :
                fpath = os.path.join(os.getcwd(), binpath, binid+'.fa')
                if not os.path.isfile(fpath):
                    raise ValueError("{} is NOT valid!".format(fpath))
                else:
                    print("{} is valid!".format(fpath))
                    fhout.write("{0}\t{1}\n".format(fpath,tmp[0]))
                pass_value = ["PASSED"]+list_out
                passed.append('\t'.join(pass_value))
            else:
                fail_value = ["FAILED"]+list_out
                failed.append('\t'.join(fail_value))
    return passed, failed

def write_log(logfile, passed, failed):
    if len(passed) == 0 :
        print("\n [WARNING]-passed filter is zero,you can change the parameter")
    if len(failed) == 0 :
        print("\n [WARNING]-failed filter is zero")
    with open(logfile, 'a') as fh:
        fh.write("Filter\tBin\tCompleteness\tContamination\tStrainHeterogeneity\tGenomeSize\tContigs\n")
        for p in passed:
            fh.write(p+'\n')
        for f in failed:
            fh.write(f+'\n')

def main():
    args = get_args()
    passed, failed = parse_summary(args.infile, args.completeness, args.contamination,
                  args.contigs, args.binpath, args.outfile)
    write_log(args.logfile, passed, failed)

if __name__ == '__main__':
    main()

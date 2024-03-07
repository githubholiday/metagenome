
import os,sys,argparse
import time

__author__ = 'Tu chengfang'
__mail__ = 'chengfangtu@genome.cn'
def main():
	parser=argparse.ArgumentParser(description=__doc__,
		formatter_class=argparse.RawDescriptionHelpFormatter,
		epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument( '-d', '--deal_dir', help = 'outdir', dest = 'dealdir', required=True )
	args = parser.parse_args()
	if os.path.exists( args.dealdir):
		rm_cmd = 'rm -r {0}'.format( args.dealdir)
		if os.system( rm_cmd ) == 0 :
			print("{0} 已经删除".format( args.dealdir))
		else:
			print("{0} 删除失败".format( args.dealdir))
	else:
		print("{0} 不存在，不需要处理".format( args.dealdir))

if __name__ == '__main__':
	main()

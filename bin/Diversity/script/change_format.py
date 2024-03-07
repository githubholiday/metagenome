import sys

num = 1
with open(sys.argv[1]) as infile:
	with open(sys.argv[2],'w') as out:
		for line in infile:
			tmp = line.strip().split("\t")
			if line.startswith("Sample"):
				tmp[0] = 'name'
				out.write("\t".join(tmp)+"\n")
			else:
				tmp[0] = tmp[0].split()[0][0:5]+'_'+str(num)
				out.write("\t".join(tmp)+"\n")
				num += 1

conditions = [ "1", "3", "5" ]
num_stars = [ "0100", "0600", "1100" ]

for cond in conditions:
	for num in num_stars:
		#clusteringCondition + "-" + numStarCondition + "-hiScore.txt";
		f = open("{0}-{1}-hiScore.txt".format(cond, num), 'w')
		f.write("BEK 1\nBEK 1\nBEK 1\nBEK 1\nBEK 1\nBEK 1\nBEK 1\nBEK 1\nBEK 1\nBEK 1")
		f.close()
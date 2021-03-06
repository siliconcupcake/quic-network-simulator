import sys
import pandas as pd

rlog = open('reno/window.log', 'w')
clog = open('cubic/window.log', 'w')
vlog = open('vivace/window.log', 'w')

offset = int(sys.argv[1])
step = int(sys.argv[2])
count = int(sys.argv[3]) + 1

for i in range(1, count):
	reno = pd.read_csv('reno/server/s%d/window.log' % i, sep=' ', header=None)
	speed = offset + (i * step)
	window = reno[0].mean()
	rlog.write('{0} {1}\n'.format(speed, window))

for i in range(1, count):
	cubic = pd.read_csv('cubic/server/s%d/window.log' % i, sep=' ', header=None)
	speed = offset + (i * step)
	window = cubic[0].mean()
	clog.write('{0} {1}\n'.format(speed, window))

for i in range(1, count):
	vivace = pd.read_csv('vivace/server/s%d/window.log' % i, sep=' ', header=None)
	speed = offset + (i * step)
	window = vivace[0].mean()
	vlog.write('{0} {1}\n'.format(speed, window))

rlog.close()
clog.close()
vlog.close()

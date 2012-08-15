#! /usr/bin/env python

import os, sys
rel = {}

def traverseFile(f):
	global path
	if not rel.has_key(f): rel[f] = []
	txt = open(path+f,'r')
	for l in txt.readlines():
		if l.startswith('import '):
			rel[f].append(l.split(' ')[-1].strip()[:-1])
	txt.close()

def traverseDir(d):
	global path
	for f in os.listdir(path+d):
		if os.path.isdir(path+d+'/'+f): traverseDir(d+'/'+f)
		elif not f.endswith('.class'):  traverseFile(d+'/'+f)

if __name__ == '__main__':
	path = sys.argv[1]+'/'
	traverseDir('org')
	print 'digraph Relation { node [shape=box]'
	for k in rel.keys():
		print '"%s" [shape=ellipse]' % (k.split('.')[0].replace('/','.'))
		for v in rel[k]:
			print '"%s" -> "%s"' % (k.split('.')[0].replace('/','.'),v)
	print '}'

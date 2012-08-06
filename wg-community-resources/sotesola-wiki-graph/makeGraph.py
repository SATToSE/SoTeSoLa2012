#! /usr/bin/env python

import os, glob, sys
rel = []
for mw in glob.glob( os.path.join(sys.argv[1], '*.mediawiki') ):
	f = open(mw,'r')
	m = mw.split('/')[-1].split('.')[0]
	m = '-'.join(map(lambda w:w[0].lower()+w[1:],m.split('-')))
	m = m[0].upper()+m[1:]
	for l in f.read().split('[[')[1:]:
		r = l.split(']]')[0].split('|')[0].replace(' ','-')
		if r.startswith('https://'): continue
		r = r[0].upper()+r[1:]
		if (m,r) not in rel: rel.append((m,r))
	f.close()
print 'digraph Relation { node [shape=box]'+'\n'.join('"%s" -> "%s"' % (m,v) for (m,v) in rel)+'}'

#! /usr/bin/env python

import sys
import os.path
import os
import fnmatch
from compiler.visitor import ASTVisitor
import compiler
from chdir import chdir


class Stats( object ):
	
	def __init__( self, title ):
		self.title = title
		self.classes = []
		self.functions = []
		self.complexity = 1
	
	@property
	def sum_complexity( self ):
		complexity = self.complexity
		for stats in self.functions:
			complexity += stats.sum_complexity
		for stats in self.classes:
			complexity += stats.sum_complexity
		return complexity
	
	def __str__(self):
		return 'Stats: title=%r, classes=%r, functions=%r, complexity=%r, sum_complexity=%r' \
			% ( self.title, self.classes, self.functions, self.complexity, self.sum_complexity, )
	
	__repr__ = __str__


class CCVisitor( ASTVisitor ):
	# This class was more or less taken from
	# https://github.com/mattjmorrison/Python-Cyclomatic-Complexity
	
	def __init__( self, ast, stats=None, title=None ):
		ASTVisitor.__init__(self)
		
		if isinstance( ast, basestring ):
			ast = compiler.parse( ast )
		
		self.stats = stats or Stats( title or '<unnamed>' )
		
		for child in ast.getChildNodes():
			compiler.walk( child, self, walker=self )
	
	def dispatchChildren( self, node ):
		for child in node.getChildNodes():
			self.dispatch( child )
	
	def visitFunction( self, node ):
		if not hasattr( node, 'name' ):  # lambdas
			node.name = '<lambda>'
		stats = Stats( node.name )
		stats = CCVisitor( node, stats ).stats
		self.stats.functions.append( stats )
	
	visitLambda = visitFunction
	
	def visitClass( self, node ):
		stats = Stats( node.name )
		stats = CCVisitor( node, stats ).stats
		self.stats.classes.append( stats )
	
	def visitIf( self, node ):
		self.stats.complexity += len( node.tests )
		self.dispatchChildren( node )
	
	def __processDecisionPoint( self, node ):
		self.stats.complexity += 1
		self.dispatchChildren( node )
	
	visitFor = \
	visitGenExprFor = \
	visitGenExprIf = \
	visitListCompFor = \
	visitWhile = \
	_visitWith = \
		__processDecisionPoint
	
	def visitAnd( self, node ):
		self.dispatchChildren( node )
		self.stats.complexity += 1
	
	def visitOr( self, node ):
		self.dispatchChildren( node )
		self.stats.complexity += 1


def measure_complexity( ast, title=None ):
	return CCVisitor( ast, title=title ).stats


def get_files( file_or_dir ):
	files = []
	
	if os.path.isdir( file_or_dir ):
		base_dir = file_or_dir
		with chdir( base_dir ):
			for root, dirnames, filenames in os.walk( '.' ):
				for filename in fnmatch.filter( filenames, '*.py' ):
					files.append( os.path.join( root, filename ))
	
	elif os.path.isfile( file_or_dir ):
		base_dir = os.path.dirname( file_or_dir )
		files.append( os.path.relpath( file_or_dir, base_dir ))
	
	return ( files, base_dir, )

def measure_complexity_for_files( files ):
	ret = {
		'files': {},
		'num_files': 0,
		'total_complexity': 0,
		'avg_complexity_per_file': 0,
	}
	
	for filename in files:
		code = open( filename ).read()
		stats = measure_complexity( code, filename )
		ret['files'][filename] = stats.sum_complexity
		ret['total_complexity'] += stats.sum_complexity
	
	ret['num_files'] = len( files )
	
	if ret['num_files'] > 0:
		ret['avg_complexity_per_file'] = (float(ret['total_complexity'] ) / float(ret['num_files']))
	else:
		ret['avg_complexity_per_file'] = 0.0
	
	return ret


def main():
	if len( sys.argv ) != 2:
		print >> sys.stderr, "Usage: {name} directory-or-file".format(
			name = sys.argv[0],
		)
		exit(1)
	
	file_or_dir = sys.argv[1]
	if not os.path.exists( file_or_dir ):
		print >> sys.stderr, "No such file or directory: {f!r}".format(
			f = file_or_dir,
		)
		exit(1)
	
	( files, base_dir, ) = get_files( file_or_dir )
	
	with chdir( base_dir ):
		ret = measure_complexity_for_files( files )
		for f in ret['files']:
			sum_complexity = ret['files'][f]
			print "FILE: {f}\t{c}".format(
				f = os.path.relpath( f, '.' ),
				c = sum_complexity,
			)
		
		print "TOTAL_COMPLEXITY: {c}".format( c = ret['total_complexity'] )
		print "NUM_FILES: {n}".format( n = ret['num_files'] )
		print "AVG_COMPLEXITY_PER_FILE: {c:.3f}".format( c = ret['avg_complexity_per_file'] )


if __name__ == '__main__':
	main()



# vim:noexpandtab:


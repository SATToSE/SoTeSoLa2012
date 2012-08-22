#! /usr/bin/env python

import sys
import os.path
from subprocess import call, Popen, PIPE, STDOUT
from chdir import chdir
from cc import measure_complexity_for_files, get_files

#def git_repo_has_local_changes():
#	err = call(
#		[ 'git', 'diff-index', '--quiet', 'HEAD', '--' ],
#		stdout = sys.stdout,
#		stderr = sys.stderr,
#	)
#	return err != 0


def git_checkout_previous( branch, prev ):
	if prev:
		spec = str( branch ) + '~' + str(prev)
	else:
		spec = str( branch )
	
	err = call(
		[ 'git', 'checkout', '-f', spec ],
		stdout = sys.stdout,
		stderr = sys.stderr,
	)
	if err != 0:
		return False
	
	return git_get_info()


def git_get_info():
	pipe = Popen(
		[ 'git', 'log', '-1', '--format=%H\t%at\t%ai' ],
		stdout = PIPE,
	).stdout
	out = pipe.read()
	if out:
		return out.strip().split( "\t" )  # ( sha, unix_time, iso_time, )
	
	return False


def main():
	if len( sys.argv ) != 2:
		print >> sys.stderr, "Usage: {name} directory".format(
			name = sys.argv[0],
		)
		exit(1)
	
	dir = sys.argv[1]
	if not os.path.exists( dir ):
		print >> sys.stderr, "No such directory: {f!r}".format(
			f = dir,
		)
		exit(1)
	
	new_dir = '/tmp/metrics-cc-git-repo'
	print "Copying Git repo {d0} to {d1!r} ...".format(
		d0 = dir,
		d1 = new_dir,
	)
	err = call(
		[ 'rm', '-rf', new_dir ],
		stdout = sys.stdout,
		stderr = sys.stderr,
	)
	
	exc = None
	try:
		err = call(
			[ 'cp', '-a', os.path.abspath( dir ), new_dir ],
			stdout = sys.stdout,
			stderr = sys.stderr,
		)
		
		branch = 'master'
		revisions = {}
		previous = 0
		
		while True:
			with chdir( new_dir ):
				info = git_checkout_previous( branch, previous )
				if not info:
					break
				
				( sha, unix_time, iso_time, ) = info
				
				( files, base_dir, ) = get_files( new_dir )
				with chdir( base_dir ):
					ret = measure_complexity_for_files( files )
					revisions[previous] = ret
					
					revisions[previous]['sha'       ] = sha
					revisions[previous]['unix_time' ] = unix_time
					revisions[previous]['iso_time'  ] = iso_time
			
			previous += 1
			
			#if previous > 50:  #FIXME REMOVEME
			#	break
		
		metrics = (
			'num_files',
			'total_complexity',
			'avg_complexity_per_file',
		)
		max = {}
		for metric in metrics:
			max[metric] = 0.0
		
		metrics_titles = {
			'num_files': "{value:d} Python files",
			'total_complexity': "{value:.2f} total Python codebase complexity",
			'avg_complexity_per_file': "{value:.2f} avg. complexity per Python file",
		}
		metrics_value_formats = {
			'num_files': "{value:d}",
			'total_complexity': "{value:.2f}",
			'avg_complexity_per_file': "{value:.2f}",
		}
		metrics_labels = {
			'num_files': "number of Python files",
			'total_complexity': "total Python codebase complexity",
			'avg_complexity_per_file': "avg. complexity per Python file",
		}
		
		for previous in reversed(sorted( revisions )):
			rev = revisions[previous]
			for metric in metrics:
				if rev[metric] > max[metric]:
					max[metric] = rev[metric]
		
		w = 900
		h = 400
		
		for metric in metrics:
			with open( os.path.basename(dir)+'-'+metric+'.svg', 'wb' ) as fh:
				print >> fh, '<?xml version="1.0" encoding="UTF-8"?>'
				print >> fh, '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">'
				print >> fh, '<svg'
				print >> fh, '  xmlns="http://www.w3.org/2000/svg"'
				print >> fh, '  xmlns:xlink="http://www.w3.org/1999/xlink"'
				print >> fh, '  xmlns:ev="http://www.w3.org/2001/xml-events"'
				print >> fh, '  version="1.1"'
				print >> fh, '  baseProfile="full"'
				print >> fh, '  width="'+ str(w+3*2) +'"'
				print >> fh, '  height="'+ str(h+3*2) +'"'
				print >> fh, '  viewBox="-5 -5 '+ str(w+3*2+5) +' '+ str(h+3*2+5) +'"'
				print >> fh, '>'
				
				print >> fh, '<style>'
				print >> fh, '  circle.p { stroke: green; stroke-width: 2; fill: none; opacity: 0.8; }'
				print >> fh, '  circle.p:hover { stroke-width: 4; fill: yellow; fill-opacity: 0.6; opacity: 1; }'
				print >> fh, '</style>'
				
				print >> fh, '<rect x="'+ str(3) +'" y="'+ str(3) +'" width="'+ str(w) +'" height="'+ str(h) +'" fill="white" stroke="black" stroke-width="1px"/>'
				
				print >> fh, '<path '
				print >> fh, '  fill="none" stroke="blue" stroke-width="2"'
				print >> fh, '  d="M 5 '+ str(h)
				
				i = 0
				for previous in reversed(sorted( revisions )):
					rev = revisions[previous]
					x = 5 + (float(w-10) / float(len(revisions))) * float(i)
					y = h - (float(rev[metric]) / float(max[metric])) * (h-10)
					
					print >> fh, '    L '+ str(x) +' '+ str(y)
					
					i += 1
				
				print >> fh, '"/>'
				
				i = 0
				for previous in reversed(sorted( revisions )):
					rev = revisions[previous]
					x = 5 + (float(w-10) / float(len(revisions))) * float(i)
					y = h - (float(rev[metric]) / float(max[metric])) * (h-10)
					
					#title = str(rev[metric]) +' files @' + str(rev['sha'][0:6]) +' ('+ str(rev['iso_time']) +')'
					title = (metrics_titles[metric] +' @ {sha} as of {date}').format(
						value  = rev[metric],
						sha    = rev['sha'][0:6],
						date   = rev['iso_time'],
					)
					
					print >> fh, '<circle class="p" cx="'+ str(x) +'" cy="'+ str(y) +'" r="6" title="'+ str(title) +'" />'
					
					i += 1
				
				print >> fh, '</svg>'
			
			with open( os.path.basename(dir)+'-'+metric+'.html', 'wb' ) as fh:
				print >> fh, '<!DOCTYPE html>'
				print >> fh, '<html>'
				print >> fh, '	<head>'
				print >> fh, '		<title>Metrics</title>'
				print >> fh, '		<script type="text/javascript" src="https://www.google.com/jsapi"></script>'
				print >> fh, '		<script type="text/javascript">'
				print >> fh, '			google.load( "visualization", "1", { packages: ["corechart"]});'
				print >> fh, '			google.setOnLoadCallback( drawChart );'
				print >> fh, '			function drawChart()'
				print >> fh, '			{'
				print >> fh, '				var data = google.visualization.DataTable();'
				print >> fh, '				var data = new google.visualization.DataTable();'
				print >> fh, '				data.addColumn( "string", "SHA" );  // implicit domain label col.'
				print >> fh, '				data.addColumn( "number", '+repr(str( metrics_labels[metric] ))+' );  // implicit series 1 data col.'
				print >> fh, '				data.addColumn({ type:"string", role:"tooltip" });  // annotation role col.'
				print >> fh, '				data.addRows(['
				
				for previous in reversed(sorted( revisions )):
					rev = revisions[previous]
					
					title = ('{value}\n@ {sha} as of {date}').format(
						value  = rev[metric],
						sha    = rev['sha'][0:6],
						date   = rev['iso_time'],
					)
					
					print >> fh, '[ {sha!r}, {value!r}, {title!r} ],'.format(
						sha    = rev['sha'][0:6],
						value  = rev[metric],
						title  = title,
					)
				
				print >> fh, '			]);'
				print >> fh, '			var options = {'
				print >> fh, '				title: "Metrics",'
				print >> fh, '			};'
				print >> fh, '			var chart = new google.visualization.LineChart('
				print >> fh, '				document.getElementById( "chart-1" ));'
				print >> fh, '			chart.draw( data, options );'
				print >> fh, '		}'
				print >> fh, '		</script>'
				print >> fh, '	</head>'
				print >> fh, '	<body>'
				print >> fh, '		<div id="chart-1" style="width:99%; min-width:40em; height:99%; min-height:30em;"></div>'
				print >> fh, '	</body>'
				print >> fh, '</html>'
	
		with open( 'index.html', 'wb' ) as fh:
			print >> fh, '<!DOCTYPE html>'
			print >> fh, '<html>'
			print >> fh, '	<head>'
			print >> fh, '		<title>Metrics</title>'
			print >> fh, '		<script type="text/javascript" src="https://www.google.com/jsapi"></script>'
			print >> fh, '		<script type="text/javascript">'
			print >> fh, '			google.load( "visualization", "1", { packages: ["corechart"]});'
			print >> fh, '			google.setOnLoadCallback( drawChart );'
			print >> fh, '			function drawChart()'
			print >> fh, '			{'
			
			for metric in metrics:
				print >> fh, '				var data_'+metric+' = google.visualization.DataTable();'
				print >> fh, '				var data_'+metric+' = new google.visualization.DataTable();'
				print >> fh, '				data_'+metric+'.addColumn( "string", "SHA" );  // implicit domain label col.'
				print >> fh, '				data_'+metric+'.addColumn( "number", '+repr(str( metrics_labels[metric] ))+' );  // implicit series 1 data col.'
				print >> fh, '				data_'+metric+'.addColumn({ type:"string", role:"tooltip" });  // annotation role col.'
				print >> fh, '				data_'+metric+'.addRows(['
				
				for previous in reversed(sorted( revisions )):
					rev = revisions[previous]
					
					title = (metrics_value_formats[metric]+'\n@ {sha} as of {date}').format(
						value  = rev[metric],
						sha    = rev['sha'][0:6],
						date   = rev['iso_time'],
					)
					
					print >> fh, '[ {sha!r}, {value!r}, {title!r} ],'.format(
						sha    = rev['sha'][0:6],
						value  = rev[metric],
						title  = title,
					)
				
				print >> fh, '			]);'
				print >> fh, '			var options_'+metric+' = {'
				print >> fh, '				title: '+ repr(str( metrics_labels[metric] )) +','
				print >> fh, '			};'
				print >> fh, '			var chart_'+metric+' = new google.visualization.LineChart('
				print >> fh, '				document.getElementById( "chart-'+metric+'" ));'
				print >> fh, '			chart_'+metric+'.draw( data_'+metric+', options_'+metric+' );'
			
			print >> fh, '		}'
			print >> fh, '		</script>'
			print >> fh, '	</head>'
			print >> fh, '	<body>'
			for metric in metrics:
				print >> fh, '		<div id="chart-'+metric+'" style="width:99%; min-width:40em; height:20em;"></div>'
			print >> fh, '	</body>'
			print >> fh, '</html>'
	
	except (KeyboardInterrupt, Exception,) as e:
		exc = e
	
	print "Cleaning up ..."
	err = call(
		[ 'rm', '-rf', new_dir ],
		stdout = sys.stdout,
		stderr = sys.stderr,
	)
	
	if exc:
		if isinstance( exc, KeyboardInterrupt ):
			print >> sys.stderr, "Keyboard interrupt."
			exit(1)
		
		raise exc


if __name__ == '__main__':
	main()



# vim:noexpandtab:


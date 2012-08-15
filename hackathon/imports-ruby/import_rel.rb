#! /usr/bin/env ruby

def traverse_file( f )
	File.open( f, 'r', & :readlines ).map{|l|
		$1 if l =~ /^import +(?:[^ ]+ +)?([^ ]+) *;/ }.compact
end

def traverse_dir( path )
	Hash[ Dir.new( path ).reject{|f| ['.','..'].include?(f)}.map{|f|
		f = path+'/'+f
		File.directory?( f ) ? traverse_dir( f ) :
			(f.end_with?('.java') ? {f => traverse_file( f )} : nil)
	}.compact.map(& :to_a).flatten(1)]
end

if $0 == __FILE__
	path = ARGV[0] || (raise "Need directory argument.")
	rel = Dir.chdir( path ){ traverse_dir( 'org' )}
	fmt = lambda{|s| s.split('.')[0..-2].join('.').gsub('/','.')}
	puts 'digraph Relation { node [shape=box]'
	rel.each{|k,a|
		puts '"%s" [shape=ellipse]' % [fmt[k]]
		a.each{|v| puts '"%s" -> "%s"' % [fmt[k], v] }
	}
	puts '}'
end

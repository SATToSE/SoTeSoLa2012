# 361 chars, optimized for readability and maintainability:
t=lambda{|p|Hash[(Dir.new(p).entries-%w[. ..]).map{|f|f=p+'/'+f
File.directory?(f)?t[f]:f[/\.java$/]?{f=>open(f).map{|l|l=~/^import +([^ ]+ +)?([^ ]+) *;/&&$2}.compact}:[]}.map(&:to_a).flatten(1)]}
p=$*[0];r=Dir.chdir(p){t['org']}
m=lambda{|s|s.split(/[.\/]/)[0..-2].join'.'}
puts ['digraph{node[]',r.map{|k,a|["<#{m[k]}>[]",a.map{|v|"<#{m[k]}>-><#{v}>"}]},'}']

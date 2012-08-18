# 206 chars, optimized for readability and maintainability:
m=->s{"<#{s[0..-6].tr '/','.'}>"}
puts 'digraph{node[]',Hash[Dir.chdir($*[0]){Dir['**/*.java'].map{|f|[f,open(f).grep(/^import /){|l|l[/\w+\.[^ ;]+/]}]}}].map{|k,a|[m[k]+'[]',a.map{|v|m[k]+"-><#{v}>"}]},'}'

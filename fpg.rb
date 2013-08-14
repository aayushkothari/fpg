'''Ruby implementation of FP-Graph Data Mining Algorithm to determine Frequent Item Sets
	From A Given Dataset of Transaction=>Items Form. It has been inspired by an IEEE paper. 
'''

#Input Dataset

i=0
dataset={}
a=('A'..'G').to_a
100000.times do 
	i=i+1
dataset[i]=a[rand(7)..rand(7)] #generating a random dataset
end
for key in dataset.keys
	if dataset[key]==[]
		dataset[key]=['A','B','C'] #making sure there aren't any blank transactions.
	end
end
#puts dataset
#Implementation Of make_graph algorithm.
def make_graph(dataset)	
	@G={} #graph to be returned.
	@Count={}
	for key in dataset.keys #iterating through all transactions.

		for item in dataset[key] #iterating through all items in each transaction.
			if item==dataset[key].first
				previous=nil
				first=item
				node_count=1
			else
				node_count=node_count+1
			end

			if @G.has_key?(item)==false #if item does not exist in Graph, make a node of it.
				@G[item]=[]
				@Count[item]=1 #assign Count=1.
				if previous!=nil
					@G[previous].push([item,1,first,node_count])
					#if there is a previous node, make an edge with that and current node.
				end
			else 
				#updating edge-frequency. 
				@Count[item]+=1
				if previous!=nil
					for src in @G.keys
						if src==previous
							i=0
							for edge in @G[src] 
								if edge[0]==item && edge[2]==first && edge[3]==node_count
									edge[1]+=1
								else 
									i+=1
								end
							end
							if i==@G[src].length
								@G[src].push([item,1,first,node_count])
							end
						end
					end
				end
			end
				previous=item
		end
				first=nil
				previous=nil

	end
	return @G,@Count
end

#function to find the edge with maximum node_count.
def find_max(graph)
	maxedge=graph[graph.keys[0]].first
	for node in graph.keys
		for edge in graph[node]
			if edge[3]>maxedge[3]
				maxedge=edge
			end
		end
	end
	return maxedge
end

#find edges with a particular node_count.
def findedge(graph,count)
       flag,edges,nodes=0,[],[]
       for key in graph.keys
       	for edge in graph[key]
        	if edge[3]==count
        		edges.push(edge)
        		nodes.push(key)
        	end 
        end
      end
      if edges.length!=0
      	return edges,nodes,true
      else 
      	return nil,nil,false
      end
end

#function to go traverse back on a path. 
def goback(g,e,prev)
	pr=nil
	for key in g.keys
		for edge in g[key]
			if edge[0]==prev && edge[2]==e[2] && (edge[3]==(e[3]-1))
				ed=edge
				pr=key
				break
			end
		end
	end
	return ed,pr
end

#function to find the complete path by going back from the final node to the first_node.
def traverse(g,e,prev)
	ef=[] #contains edge-frequency of each edge along the path.
	node_count=e[3]
	path=[]
	path.unshift(e[0])
	while node_count>=2
		ef.push(e[1])
		path.unshift(prev)
		e,prev=goback(g,e,prev)
		node_count-=1
	end
	minfreq=ef.sort[0] #find minimum of all edge-frequencies of edges in 'path'.
	return path,minfreq
end

#the mining algorithm.
def mine(graph,dataset)
	edge=find_max(graph) #we begin with the edge with maximum node_count in graph.
	j=edge[3] #j=max. edge-freuncy.
	sets={} #has all paths in decreasing order of node_count. 
	while j!=1
		@FI=nil
		result,prev,bool=findedge(graph,j)
		if bool
			for i in 0..result.length-1
			@FI,@min=traverse(graph,result[i],prev[i])
			sets[@FI]=@min #find all main paths and assign min. frequency to each.
			end
		end
		j=j-1
	end
	
	subpaths=[]
 	for key in sets.keys #traversing through all main paths.
 		k=key.to_a
 		for i in 2..k.length
 			@path=k.combination(i).to_a #finding all combinations of elements of array k.
 			@path.keep_if{|item| item.last==k.last} #using only those ending with last node.
 			for sub in @path
 				sub<<sets[key]
 			end
 			subpaths.push(@path)
 		end
 	end
 	final={}

 	subpaths=subpaths.flatten(1)
 	
 	samples=[]

 	for path in subpaths
 		sample=subpaths.find_all{|edge| edge[0..-2]==path[0..-2] }
 		samples.push(sample) #finding all duplicate occurences of subpaths. 
	end
	#final[samples]="asdasd"
	#puts final
	samples=samples.uniq #keep only one set of duplicates of each edge.

	for x in samples
		i=1
		while i!=x.length
			x[0][-1]+=x[i][-1] #adding edge-frequency of all.
			i=i+1
		end
	end
	answers=[]
	min_support=(dataset.keys.length)/5
	for y in samples
		if y[0][-1]>=min_support
			answers.push(y[0]) #collecting only those edges wit edge-frequency>minimum support.
		end
	end
	return answers,min_support
end

def printgraph(graph)
	for key in graph.keys
		for edge in graph[key]
			printf key+"->"+edge[0].to_s+" = "+edge[1..-1].join(' , ').to_s
			puts
		end
	end
end

puts 
puts "Dataset:"
puts 
printf "Transaction"+"   "+"Items"
puts

#printing input dataset.
for key in dataset.keys
	printf key.to_s+"\t\t"+dataset[key].to_s
	puts
end
puts

#printing graph fromed from dataset.
graph,count=make_graph(dataset)
puts
puts "Graph Initially Formed From The Dataset"
puts 
printgraph(graph)

result, support=mine(graph,dataset)
puts
puts "Minimum Support For Dataset - "+support.to_s
puts "Frequent Item Sets After Mining The Above Graph: "
puts 

#listing frequent item sets. 
for set in result
	puts "Item Set: "+set[0..-2].join
	puts "Frequency -> "+set[-1].to_s
	puts 
end

puts 
puts "Single-Item Frequent-Item Sets:"
puts
for key in count.keys
	if count[key]>=(dataset.keys.length)/5
		printf key.to_s+" -> "+count[key].to_s
		puts
	end
end

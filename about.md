# twitterMapper

twitterMapper is an exploratory data mining tool for streaming Twitter data. 
It produces a graph using the Mapper algorithm designed by Carlsson, Mémoli, 
and Singh. 

Nodes in the graph represent sets of tweets by various users, and are by default 
sized by the number of tweets they represent. They are colored according to a 
filter chosen by the user, and colorings represent an average over users 
represented in each node. Hovering over a node will show the list of hashtags 
used by all tweets in that node.

Edges indicate nodes share one or more tweets. Following the graph from node to 
node along the edges gives a sense of the continuum of hashtag use in Twitter 
according to the filter used to construct the graph.

### Graph Construction

For the more technically minded, a rough outline of the construction of 
the graph is as follows. 

First, the tweets are gathered into overlapping groups according to some filter, 
such as number of followers. In this example, tweets by users with similar 
numbers of followers will fall in the same or perhaps adjacent groups. The 
number of such groups is controlled by the Number of intervals parameter, and 
the degree to which adjacent groups overlap is controlled by the Percent overlap 
of intervals parameter. 

Next, a clustering algorithm is performed on each group according to distance 
between tweets. In this case the distance between tweets can be chosen by the 
user. One choice is the Jaccard similarity, which measure the proportion of 
hashtags tweets have in common. All notions of distance depend only on hashtags 
used in the tweets. A histogram of lengths between tweets in the hierarchical 
clustering is produced whose number of bins is equal to the Number of bins for 
clustering parameter. If there is an empty bin in the histogram, the clustering 
algorithm is cut off at that point leaving a partial clustering, otherwise all 
points end up in one cluster together.

The union of all of the clusters from all of the groups comprise the nodes of 
the graph. Edges are drawn between nodes in different groupings which share 
one or more tweets.

### Motivation

Shape matters. Many models for data make underlying assumptions about the shape 
of the data. Linear regression assumes the data is "flat". K nearest neighbors 
assumes the data will naturally cluster into a fixed number of generally round 
clusters. Decision trees assume planes parallel to the feature axes will separate 
the data into useful pieces.

Mapper makes no assumptions on shape. Instead, it attempts to display it to the 
user. Its output is independent of the coordinates used to represent the data 
because it depends only upon interpoint distances, not the coordinates of the 
data points themselves. It gives a compressed way to view the data, turning 
many thousands of points into a few nodes and edges which succinctly 
communicates the shape of the data in a way a human can understand.

The ideas behind Mapper are very similar to those behind Morse Theory, a set of 
mathematical tools for understanding the topology (shape) of high-dimensional 
manifolds by studying real-valued functions (filters) on the manifold. Morse Theory 
is an integral part of Smale's proof of the h-cobordism theorem, for which he won 
a Fields medal.

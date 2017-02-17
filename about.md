# twitterMapper

twitterMapper is an exploratory data mining tool for streaming Twitter data. 
It produces a graph using the Mapper algorithm designed by Carlsson, Mémoli, 
and Singh. It uses Paul Pearson's TDAmapper package for R to create the graphs. 
Under the hood are some custom-built tools for dealing with and analyzing tweets 
in particular.

One challenge in mining streaming tweets is finding useful visualizations. They contain 
very limited information, and most of it is extremely sparse. In particular, we have only 
numeric information on friends and followers, not the connections themselves, so the usual 
network representations are not possible. twitterMapper overcomes this difficulty with a 
novel clustering technique.

### Local to global clustering

Mapper is a "local to global" clustering algorithm. It breaks the data, in this 
case tweets, into overlapping chunks according a filter such as number of 
followers. Next it partially clusters these chunks into nodes using a notion 
of distance between tweets, in this case basically a proportion of common hashtag 
use among all hashtags used by a given pair of tweets. Finally, it stitches the 
nodes back together, joining nodes with an edge if they share common tweets.

Why should this be better than just clustering all the data from the get-go? Take 
a look at the K-medioids clustering tab. Like all clustering methods, it clusters 
the entire data set at once. This is a difficult task. Try generating some plots 
yourself to see if you can extract insight from these pictures. This is but one 
example. A more philosophical answer is that mathematics, especially geometry and topology, 
has created many tools for expressing shape purely in terms of local information.

In a sense the comparison with other clustering algorithms is unfair. By clustering on 
smaller chunks of the data and keeping track of overlaps of chunks, Mapper has a better 
chance to find significant patterns becaues it works on smaller pieces of the data, making 
it less sensitive to outliers and odd cluster shapes. Because it keeps track of the relationships 
between clusters, it is able to express the shape of the entire data set in the form of a graph.

### The shape of data

Shape matters. Many models for data make underlying assumptions about the shape 
of the data. Linear regression assumes the data is "flat". K-nearest neighbors 
assumes the data will naturally cluster into a fixed number of generally round 
clusters. Decision trees assume planes parallel to the feature axes will separate 
the data into useful pieces. All of these methods are extremely useful and powerful, 
but their goals are different. In fact, they are put to better use once Mapper has 
helped identify useful features.

Mapper makes no assumptions on shape. Instead, it shows it to you.

The ideas behind Mapper are very similar to those behind Morse Theory, a set of 
mathematical tools for understanding the topology (aka "shape") of high-dimensional 
manifolds (aka "shapes") by studying real-valued functions (filters) on the manifold. 
Morse Theory is an integral part of S. Smale's proof of the h-cobordism theorem, for which 
he won a Fields medal.

### Quick and dirty graph interpretation/user inputs

Each node in the graph represents a set of tweets, and are sized according to the 
number of tweets they contain. Edges are drawn between nodes which share tweets. Hovering over 
a node will show the hashtags used by tweets in that node.Tweets also represent the users that made 
them. The color of each node corresponds with the relative density of the trait in the "color filter" 
option. For example, using the "Spectral" coloring option with "friends" as the color filter, warmer 
colors represent users with a higher average friend count as compared to other users in the data set.

The graph is highly interactive and customizable. You can zoom and drag the graph, and move nodes 
around as you please. There are three main tabs of choices for altering the graph or its appearance.

The first, labeled "Data", allows the user to choose a data set of interest, pick a metric for 
measuring tweet distance, and a filter to break the data into chunks. Changing any of these will 
result in a new graph.

The second tab, labeled "Mapper", is for setting the parameters the algorithm uses to create the graph. 
The number of intervals sets the number of chunks to break the data into according to the filter. The 
percent overlap controls amount of overlap between adjacent chunks. The number of bins for clustering 
sets a threshhold to control the cutoff for the partial clustering done to each chunk. Single-linkage 
clustering is used here. Changes to these parameters produce a new graph. 

The third tab, "Nodes", has choices which only alter the appearance of the graph. All node sizing 
methods except "uniform" make larger nodes for more tweets. The color palette choices are present for 
aesthetic reasons. The most useful choice here is the color filter, as it can give a sense of both how 
the graph was formed (if the color filter is the same as the filter), and also gives a sense of how 
various attributes change throughout the graph. The Viridis and Magma choices, from the viridis package, 
are colorblind friendly choices.

### About the app

The app reads its data from .csv files on an Amazon S3 bucket. A Python script, hosted on Heroku, 
periodically gets U.S. Twitter trends, opens a stream following those trends, and then writes the resulting 
data to a .csv on that same bucket so it can be read by the twitterMapper app. Most of these files are deleted 
after one week, however, some data, such as the election data, has been preserved beyond this timeframe.

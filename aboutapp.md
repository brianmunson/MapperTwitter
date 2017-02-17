# twitterMapper

twitterMapper is an exploratory data mining tool for streaming Twitter data.
It produces a graph using the Mapper algorithm designed by Carlsson, Mémoli,
and Singh. It uses Paul Pearson's TDAmapper package for R to create the graphs.
Under the hood are some custom-built tools for dealing with and analyzing tweets
in particular.

One challenge in mining streaming tweets is finding useful visualizations. They contain
very limited information, and most of it is extremely sparse. The most reliable data we get 
from Twitter's Streaming API is the tweets, screen names of the users, and their number of 
friends/followers. Other data like geolocation I have found so rarely given that it is useless. 
twitterMapper overcomes the difficulty of minimal useful data with a novel clustering method, 
which you can read more about in the Math tab if you are interested in how these visualizations are 
built. The technique is not unique to Twitter data; it can and should be a part of any exploratory 
analysis, and can be used to extract features and inform model selection before machine learning 
algorithms are used.

### Data

The app reads its data from an Amazon S3 bucket. A separate Python script hosted elsewhere queries 
Twitter for current U.S. trends, opens a stream following those trends, and writes the resulting data 
to the S3 bucket in a form readable by this app. Most of these files are deleted after one week, but a 
few, such as the Election 2016 data have been preserved for other reasons. I encourage you to read 
about the Election 2016 data under the relevant tab under "About", where you can discover just as I did a 
Russian bot network tweeting support for Trump during the election.

### Graph interpretation and user inputs

Each node in the graph represents a set of tweets, and are sized according to the
number of tweets they contain. Edges are drawn between nodes which share tweets. Hovering over
a node will show the hashtags used by tweets in that node.Tweets also represent the users that made
them. The color of each node corresponds with the relative density of the trait in the "color filter"
option. For example, using the "Spectral" coloring option with "friends" as the color filter, warmer
colors represent users with a higher average friend count as compared to other users in the data set.

Each node in the graph represents a set of tweets, and are sized according to the
number of tweets they contain. Edges are drawn between nodes which share tweets. Hovering over
a node will show the hashtags used by tweets in that node. Tweets also represent the users that made
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
clustering is used here, although other clustering methods can be used as well. Changes to any of these 
parameters produce a new graph.

The third tab, "Nodes", has choices which only alter the appearance of the graph. All node sizing
methods except "uniform" make larger nodes for more tweets. The color palette choices are present for
aesthetic reasons. The most useful choice here is the color filter, as it can give a sense of both how
the graph was formed (if the color filter is the same as the filter), and also gives insight into how
various attributes change throughout the graph. The Viridis and Magma choices, from the viridis package,
are colorblind friendly choices.


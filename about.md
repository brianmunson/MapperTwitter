# twitterMapper

twitterMapper is an exploratory data mining tool for streaming Twitter data. 
It produces a graph using the Mapper algorithm designed by Carlsson, Mémoli, 
and Singh. 

### The basic idea

Mapper is a "local to global" clustering algorithm. It breaks the data, in this 
case tweets, into overlapping chunks according a filter such as number of 
followers. Next it partially clusters these chunks into nodes using a notion 
of distance between tweets; here distance is basically the proportion of common 
hashtag use. Finally it stitches the nodes back together by joining nodes with 
common data using edges.

Why should this be better than just clustering all the data from the get-go? Take 
a look at the K-medioids clustering tab. You can generate plots for yourself 
of followers versus friends and cluster according to the same distance used to 
produce the graphs that twitterMapper createse. You will notice that the visualizations 
that K-medioids produces look like a mess. Can you extract insight from them?

In contrast, twitterMapper gives a clearer picture of the continuum of hashtag 
use by creating a graph which more closely resembles the shape of the Twitter 
data.

Even more remarkable is that twitterMapper produces its graph from less 
data than the k-medioids clustering visualization. Both use the interpoint distances, 
but twitterMapper only uses one filter, such as the number of followers, whereas 
K-medioids clustering uses both followers and friends to produce its visualization.

Shape matters. Many models for data make underlying assumptions about the shape 
of the data. Linear regression assumes the data is "flat". K nearest neighbors 
assumes the data will naturally cluster into a fixed number of generally round 
clusters. Decision trees assume planes parallel to the feature axes will separate 
the data into useful pieces. All of these are extremely useful, but their goal is 
different.

Mapper makes no assumptions on shape. Instead, it shows it to you.

The ideas behind Mapper are very similar to those behind Morse Theory, a set of 
mathematical tools for understanding the topology (aka "shape") of high-dimensional 
manifolds (aka "shapes") by studying real-valued functions (filters) on the manifold. 
Morse Theory is an integral part of S. Smale's proof of the h-cobordism theorem, for which 
he won a Fields medal.

mapperTwitter uses Paul Pearson's TDAmapper package to create the graphs.

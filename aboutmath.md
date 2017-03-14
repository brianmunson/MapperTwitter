# Mapper

twitterMapper uses the Mapper algorithm designed by Carlsson, Mémoli,
and Singh. This algorithm is inspired by ideas from algebraic topology, the area of 
mathematics concerned with shape.

### Local to global clustering

Mapper is a "local to global" clustering algorithm. It breaks the data, in this
case tweets, into overlapping chunks according a filter, such as number of
followers. Next it partially clusters these chunks into nodes using a notion
of distance between tweets, in this case basically a proportion of common hashtag
use among all hashtags used by a given pair of tweets. Finally, it stitches the
nodes back together, joining nodes with an edge if they share common tweets.

Why should this be better than just clustering all the data from the get-go? Take
a look at the K-medioids clustering tab. Like all clustering methods, it clusters
the entire data set at once. This is a difficult task that makes assumptions about 
the shape of the data. Generate some plots yourself to see if you can extract insight 
from these pictures. A more philosophical answer is that mathematics, especially geometry 
and topology, has created many tools for expressing shape purely in terms of *local* 
information.

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

Mapper makes no assumptions about shape. Instead, it shows it to you.

The ideas behind Mapper are very similar to those behind Morse Theory, a set of
mathematical tools for understanding the topology (aka "shape") of high-dimensional
manifolds (aka "shapes") by studying real-valued functions (filters) on the manifold.
Morse Theory is an integral part of S. Smale's proof of the h-cobordism theorem, for which
he won a Fields medal.

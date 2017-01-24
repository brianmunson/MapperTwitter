# Partial clustering of whole data set notebook
# load 2016 Election data fram as "elec"
require(cluster) # for pam "partitioning around medioids"
require(ggplot2)
elec_data <- tweetsData(elec)
dist_obj <- distMatrix(twoDist, elec_data$hashvec)
km3 <- pam(dist_obj,3) # takes a non-trivial amount of time to compute
plot(km3)
# Error in princomp.default(x, scores = TRUE, cor = ncol(x) > 2) : 
#     covariance matrix is not non-negative definite
# that's not good.
km3vec <- pam(dist_obj, 3, cluster.only=TRUE)
# returns a vector with one entry for each row in the dist_obj, and an
# integer indicating the cluster number.
# idea: do a d3 network with no edges, just nodes sized by number of 
# tweets in a cluster and with hovering giving hashtags used in those tweets
# vector km3vec can be fed to d3network as "group"
# can we also offer a measure of "goodness" of clustering? this may be too
# expensive for what we are already computing.
# or possibly take this plus a plot of the data on a followers/friends plane
# and use these groups to color the data. 

qplot(log(followers_count +1), log(friends_count + 1), data=elec_data$df, 
      color= factor(km3vec, levels=unique(km3vec)), xlab="Followers (log-scaled)", ylab="Friends (log-scaled)",
      main="Followers vs. friends, colored by k-medioids clustering by hashtag distance")

# seems to work reasonably well.



wordSetDistance <- function(a,b){
    n <- length(a) + length(b)
    I <- intersect(a,b)
    if(n==0){
        distance <- 0
    }
    else{
        aInvComp <- a[!a %in% I]
        bInvComp <- b[!b %in% I]
        tablea <- table(a[a %in% I])
        tableb <- table(b[b %in% I])
        distance <- (length(aInvComp) + length(bInvComp) + sum(abs(tablea-tableb)))/n
    }
    return(distance)
}
# Computes a distance between two vectors, treated as sets.
# Args:
#   Two vectors a and b, not necessarily of the same length
# Returns:
#   A distance between 0 and 1 between the vectors.

# Warning: it is used in measure difference between possibly
# distinct users who may have same word vectors associated with
# them. This leads to them being distance zero apart even though
# they may be distinguishable in some other way.

# Warning: using this makes computing a distance matrix run very slow.
# It's unclear whether it really improves the Jaccard distance upon
# which it is based given slow runtime.

# Notes to self:

# aInvComp is all of those elements of a which are not in I, the
# intersection of a and b. if an element appears multiply in
# a and it appears in I, then it will not appear in aInvComp. If
# it does not appear in I, then it will appear in aInvComp with
# the original multiplicity.

# tablea gives the multiplicity of the elements of a# which appear
# in I. the abs(tablea - tableb) gives the difference in multiplicities
# between the two tables, and the sum adds up these differences.

# This is a distance function on the set of functions f whose
# codomain is a fixed space X and whose domain is some finite
# set S. Notation in pseudo-code, LaTeX, and suggestive notation:
# Let f:S -> X, g:T -> X be two such functions, and let
# I = intersect(f(S), g(T)). The definition given above defines
# the distance between f and g, d(f,g), to be
# |(f^{-1}(I))^c| + |(g^{-1}(I))^c| + \sum_{i\in I}||f^{-1}(i)| - |g^{-1}(i)||
# divided by |S| + |T|.

# Trivially 0 <= d(f,g) <= 1. d(f,g) = 1 if and only if the sets
# are disjoint and not both empty.
# Trivially d(f,g) = d(g,f). 

# It is easy to prove that d(f,g) = 0 if and only if there exists
# an isomorphism h:S -> T such that g(h(s))=f(s) for all s in S. 
# In particular, d(f,f)=0.
# Proof sketch: If such h exists, then f(S)=g(T)=I, so the first
# two terms in the numerator of the fraction defining the distance
# are zero. For i in I, h carries f^{-1}(i) isomorphically onto
# g^{-1}(i), so the sum in the numerator is also zero.
# If d(f,g)=0, then f(S)=g(T) again since the complement of the
# inverse image of I by f and g are empty. Since f^{-1}(i) and
# g^{-1}(i) have the same cardinality for each i, they are isomorphic.
# partition S and T into |I| blocks defined by these inverse images.
# The disjoin union of isomorphisms f^{-1}(i) -> g^{-1}(i) defines
# an isomorphism from S to T because it is an isomorphism on each 
# partition block.

# In simple terms, this says that if f and g differ by a permutation
# of their images, then the distance between them is zero, but it also
# keeps track of multiple points of S,T mapping to the same point in
# X. From another perspective, it deals with the multiset issue.

# I haven't thought about whether the triangle inequality holds.
# This could be called a multi-set version of the Jaccard metric
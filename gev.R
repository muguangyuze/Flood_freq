## All this code is slightly adapted from fExtremes, to remove the
## log=FALSE bug in dgev, and so I can distribute gev code without the
## many dependencies of fExtremes

dgev<-function(x, location=0, scale=1, shape = 1, log = FALSE){
    # Adapted from .devd in fExtremes
    stopifnot(min(scale) > 0)
    stopifnot(length(shape) == 1)
    x = (x - location)/scale
    if (shape == 0) {
        d = log(1/scale) - x - exp(-x)
    }
    else {
        nn = length(x)
        xx = 1 + shape * x
        xxpos = xx[xx > 0 | is.na(xx)]
        scale = rep(scale, length.out = nn)[xx > 0 | is.na(xx)]
        d = numeric(nn)
        d[xx > 0 | is.na(xx)] = log(1/scale) - xxpos^(-1/shape) - 
            (1/shape + 1) * log(xxpos)
        d[xx <= 0 & !is.na(xx)] = -Inf
    }
    if (!log) {
        d = exp(d)
    }
    #attr(d, "control") = data.frame(location = location[1], scale = scale[1], 
    #    shape = shape[1], log = log, row.names = "")
    return(d)
}

pgev<-function (q, location = 0, scale = 1, shape = 0, lower.tail = TRUE){
    # Adapted from .pevd in fExtremes
    stopifnot(min(scale) > 0)
    stopifnot(length(shape) == 1)
    q = (q - location)/scale
    if (shape == 0) {
        p = exp(-exp(-q))
    }
    else {
        p = exp(-pmax(1 + shape * q, 0)^(-1/shape))
    }
    if (!lower.tail) {
        p = 1 - p
    }
    return(p)
}

qgev<-function (p, location = 0, scale = 1, shape = 0, lower.tail = TRUE){
    # Adapted directly from .qevd in fExtremes
    stopifnot(min(scale) > 0)
    stopifnot(length(shape) == 1)
    stopifnot(min(p, na.rm = TRUE) >= 0)
    stopifnot(max(p, na.rm = TRUE) <= 1)
    if (!lower.tail) 
        p = 1 - p
    if (shape == 0) {
        q = location - scale * log(-log(p))
    }
    else {
        q = location + scale * ((-log(p))^(-shape) - 1)/shape
    }
    #attr(q, "control") = data.frame(location = location[1], scale = scale[1], 
    #    shape = shape[1], lower.tail, row.names = "")
    return(q)
}

rgev<-function (n, location = 0, scale = 1, shape = 0){ 
    # Adapted from .revd in fExtremes package
    stopifnot(min(scale) > 0)
    stopifnot(length(shape) == 1)
    if (shape == 0) {
        r = location - scale * log(rexp(n))
    }
    else {
        r = location + scale * (rexp(n)^(-shape) - 1)/shape
    }
    #attr(r, "control") = data.frame(location = location[1], scale = scale[1], 
    #    shape = shape[1], row.names = "")
    return(r)
}


#############################
test_gev_code<-function(){
    x=seq(0,1000,len=100)
    p=seq(0,1,len=101)
    #library(fExtremes) # Should be identical to this
    
    xd=dgev(x, shape=0.2, location=200,scale=100)
    xq=qgev(p, shape=0.2, location=200,scale=100)
    xp=pgev(x, shape=0.2, location=200,scale=100)
    set.seed(1) 
    xr=rgev(100, shape=0.2, location=200,scale=100)


    library(fExtremes)
    yd=fExtremes::dgev(x,xi=0.2,mu=200,beta=100)
    
    stopifnot(all(xd==yd))
    print('PASS - same as dgev fExtremes')

    yq=fExtremes::qgev(p,xi=0.2,mu=200,beta=100)
    stopifnot(all(xq==yq))
    print('PASS - same as qgev fExtremes')

    yp=fExtremes::pgev(x,xi=0.2,mu=200,beta=100)
    stopifnot(all(xp==yp))
    print('PASS - same as pgev fExtremes')
   
    set.seed(1) 
    yr=fExtremes::rgev(100,xi=0.2,mu=200,beta=100)
    stopifnot(all(xr==yr))
    print('PASS - same as rgev fExtremes')

}

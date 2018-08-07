


GeoResiduals<-function(fit)

{
if(class(fit)!="GeoFit") stop("A GeoFit object is needed as input\n")
######
num_betas=fit$numbetas #number of mean parameters
model=fit$model        #type of model

## extracting mean parameters
namescorr <- CorrParam(fit$corrmodel) 
namesnuis <- NuisParam(fit$model,fit$bivariate,num_betas)
param <- c(fit$param, fit$fixed)
namesparam<- names(param)
paramcorr <- param[namescorr]
nuisance <- param[namesnuis]
sel=substr(names(nuisance),1,4)=="mean"
beta2=as.numeric(nuisance[sel])
## names of estimated and fixed parameters
nm=names(fit$param)
nf=names(fit$fixed)
 

#################################
#### computing mean ########
#################################
mu=fit$X%*%beta2  
#################################
#### computing residuals ########
#################################
if(is.list(fit$coordx_dyn)) dd=unlist(fit$data)
else dd=c(t(fit$data))
### 
if(model %in% c("Gamma","Weibull","LogLogistic","LogGaussian"))
res1=dd/exp(mu)  
### 
if(model %in% c("Gaussian","Logistic","TwoPieceGaussian",
         "StudentT","TwoPieceGauss","TwoPieceStudentT"))
res1=(dd-mu)/sqrt(as.numeric(param['sill']))
###
if(model %in% c("SkewGaussian"))  res1=(dd-mu)/sqrt( as.numeric(param['sill']) +
                                      as.numeric(param['skew'])^2)
#if(binomial or binomialneg or geom or bernoulli)
#
#............

fit$X=as.matrix(rep(1,length(dd)))




#### updating  object
mm=0
names(mm)="mean"
nuis_update=c(mm,nuisance[!sel])
fit$param=c(nuis_update,paramcorr)
fit$numbetas=1
fit$X=as.matrix(rep(1,length(c(fit$data))))

param=param[names(fit$param)]

if(model %in% c("Gaussian","Logistic","TwoPieceGaussian",
         "StudentT","TwoPieceGauss","TwoPieceStudentT"))
{param['sill']=1;param['mean']=0}

if(model %in% c("SkewGaussian")) 
{param['mean']=0;param['skew']=0.5;param['sill']=0.5}#param['sill']=1;}


fit$param=param[nm]
fit$fixed=param[nf]

fit$param=fit$param[!is.na(fit$param)]
fit$fixed=fit$fixed[!is.na(fit$fixed)]
### formatting data
if(fit$spacetime) 
{if(!is.list(fit$coordx_dyn)) 
          data_res=matrix(res1,nrow=nrow(fit$data),ncol=ncol(fit$data),byrow=TRUE)
 else{ 
     ns=unlist(lapply(fit$coordx_dyn,nrow))
     sim_temp=list()
                    for(k in 1:length(fit$coordt))
                       { if(k==1) {indx=1:(sum(ns[1:k]))}
                         if(k>1)    {indx=(sum(ns[1:(k-1)])+1):(sum(ns[1:k]))}
                         sim_temp[[k]]=c(res1)[indx] }
    data_res=sim_temp  
 }
}   
else   data_res=as.vector(res1)

fit$data=data_res
#if(fit$bivariate.....)


### geofit object
GeoFit <- list(bivariate=fit$bivariate,
                         claic = fit$claic,
                         clbic = fit$clbic,
                         coordx = fit$coordx,
                         coordy = fit$coordy,
                         coordt = fit$coordt,
                         coordx_dyn=fit$coordx_dyn,
                         convergence = fit$convergence,
                         corrmodel = fit$corrmodel,
                         data= fit$data,
                         distance = fit$distance,
                         fixed = fit$fixed,
                         grid = fit$grid,
                         iterations = fit$counts,
                         likelihood = fit$likelihood,
                         logCompLik = fit$logCompLik,
                         message = fit$message,
                         model = fit$model,
                         n=fit$n,
                         numbetas=fit$numbetas,
                         numcoord=fit$numcoord,
                         numtime=fit$numtime,
                         param = fit$param,
                         nozero = fit$setup$nozero,
                         score = fit$score,
                         maxdist =fit$maxdist,
                         maxtime = fit$maxtime,
                         radius = fit$radius,
                         spacetime = fit$spacetime,
                         stderr = fit$stderr,
                         sensmat = fit$sensmat,
                         varcov = fit$varcov,
                         varimat = fit$varimat,
                         vartype = fit$vartype,
                         type = fit$type,
                         weighted=fit$weighted,
                         winconst = fit$winconst,
                         winstp = fit$winstp,
                         winconst_t = fit$winconst_t,
                         winstp_t = fit$winstp_t,
                         X = fit$X)
    structure(c(GeoFit, call = call), class = c("GeoFit"))
#########################
}

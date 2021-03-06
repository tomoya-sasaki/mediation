#' Significance Test for Treatment-Mediator Interaction in Causal Mediation 
#' Analysis
#' 
#' Function to test whether the average causal mediation effects and direct 
#' effects are significantly different between the treatment and control 
#' contitions.
#' 
#' @aliases test.TMint test.TMint.default test.TMint.mediate 
#'   test.TMint.mediate.order print.htest.order
#'   
#' @param x output from \code{mediate} function.
#' @param conf.level level of the returned two-sided confidence intervals for 
#'   the effect differences. By default it is set to the value used in the 
#'   original mediate call.
#' @param ...  additional arguments.
#' 
#' @return \code{test.TMint} returns an object of class "\code{htest}" when 
#'   applied to a \code{mediate} object. See \code{\link{t.test}} for more 
#'   explanations of the contents. The function returns an object of class 
#'   "\code{htest.order}" which has its own \code{print} method included in this
#'   package.
#'   
#' @author Teppei Yamamoto, Massachusetts Institute of Technology, 
#'   \email{teppei@@mit.edu}.
#'   
#' @seealso \code{\link{mediate}}
#' 
#' @references Tingley, D., Yamamoto, T., Hirose, K., Imai, K. and Keele, L. 
#'   (2014). "mediation: R package for Causal Mediation Analysis", Journal of 
#'   Statistical Software, Vol. 59, No. 5, pp. 1-38.
#'   
#'   Imai, K., Keele, L. and Tingley, D. (2010) A General Approach to Causal 
#'   Mediation Analysis, Psychological Methods, Vol. 15, No. 4 (December), pp. 
#'   309-334.
#'   
#'   Imai, K., Keele, L. and Yamamoto, T. (2010) Identification, Inference, and 
#'   Sensitivity Analysis for Causal Mediation Effects, Statistical Science,
#'   Vol. 25, No. 1 (February), pp. 51-71.
#'   
#'   Imai, K., Keele, L., Tingley, D. and Yamamoto, T. (2009) "Causal Mediation 
#'   Analysis Using R" in Advances in Social Science Research Using R, ed. H. D.
#'   Vinod New York: Springer.
#'   
#' @examples
#' # Examples with JOBS II Field Experiment
#' 
#' # **For illustration purposes a small number of simulations are used**
#' 
#' data(jobs)
#' 
#' # Fit mediator and outcome models allowing for treatment-mediator interaction
#' b <- lm(job_seek ~ treat + econ_hard + sex + age, data=jobs)
#' d <- lm(depress2 ~ treat*job_seek + econ_hard + sex + age, data=jobs)
#' 
#' # Test for significance of interaction
#' fit <- mediate(b, d, sims=50, treat="treat", mediator="job_seek")
#' test.TMint(fit)
#' 
#' @export
test.TMint <- function(x, ...){
  UseMethod("test.TMint")
}

#' @export
test.TMint.default <- function(x, ...){
  stop("currently no test.TMint method exists for the input object.")
}

#' @rdname test.TMint
#' @export
test.TMint.mediate <- function(x, conf.level = x$conf.level, ...){
  if(is.null(x$d0.sims) || is.null(x$d1.sims) || is.null(x$z0.sims) || is.null(x$z1.sims)){
    stop("simulation draws missing; rerun mediate with 'long' set to TRUE")
  }
  if(!x$INT){
    stop("outcome model must include interaction between treatment and mediator")
  }
  d.diff <- x$d1 - x$d0
  d.diff.sims <- x$d1.sims - x$d0.sims  
  
  # Format results in the htest format
  
  pv <- pval(d.diff.sims, d.diff)
  ci <- quantile(d.diff.sims, c((1 - conf.level)/2, (1 + conf.level)/2))
  
  null.value <- 0
  names(d.diff) <- names(null.value) <- "ACME(1) - ACME(0)"
  attr(ci, "conf.level") <- conf.level
  
  res <- list(statistic = d.diff, p.value = pv, conf.int = ci,
               null.value = null.value, alternative = "two.sided",
               method = "Test of ACME(1) - ACME(0) = 0",
               data.name = paste("estimates from", deparse(substitute(x))))
               
  class(res) <- "htest"
  return(res)
}

#' Significance Test for Moderated Mediation
#' 
#' Function to test whether the average causal mediation effects and direct 
#' effects are significantly different between two moderator strata.
#' 
#' @details The function takes the original call to \code{mediate} and reruns
#'   the algorithm twice with the two sets of \code{covariates} values. It
#'   assumes that the objects in the environment in which the original mediate
#'   call was made also exist in the current environment under the same variable
#'   names, i.e., it evaluates the updated call in the current environment.
#'   
#' @aliases test.modmed test.modmed.default test.modmed.mediate 
#'   test.modmed.mediate.order print.test.modmed.mediate 
#'   print.test.modmed.mediate.order
#'   
#' @param object output from \code{mediate} function.
#' @param covariates.1 first set of value(s) of covariates (moderators) included
#'   in the mediator and outcome models. See documentation for the 
#'   \code{covariates} argument for the \code{\link{mediate}} function.
#' @param covariates.2 second set of value(s) of covariates (moderators) 
#'   included in the mediator and outcome models.
#' @param sims number of simulation draws the test will be based on. Defaults to
#'   the number used in the original mediate fit.
#' @param conf.level level of the returned two-sided confidence intervals for 
#'   the effect differences. By default it is set to the value used in the 
#'   original mediate call.
#' @param x output from \code{test.modmed} function.
#' @param ...  additional arguments.
#' 
#' @return When applied to a \code{mediate} object, \code{test.modmed} returns 
#'   an object of class "\code{test.modmed.mediate}", a list composed of 
#'   "\code{htest}" objects. See \code{\link{t.test}} for more explanations of 
#'   \code{htest} objects. When applied to a \code{mediate.order} object, the 
#'   function returns an object of class "\code{test.modmed.mediate.order}" 
#'   which is a list composed of "\code{htest.order}" objects.
#'   
#' @author Teppei Yamamoto, Massachusetts Institute of Technology, 
#'   \email{teppei@@mit.edu}.
#'   
#' @seealso \code{\link{mediate}}, \code{\link{test.TMint}}
#' 
#' @references Tingley, D., Yamamoto, T., Hirose, K., Imai, K. and Keele, L. 
#'   (2014). "mediation: R package for Causal Mediation Analysis", Journal of 
#'   Statistical Software, Vol. 59, No. 5, pp. 1-38.
#'   
#'   Imai, K., Keele, L. and Tingley, D. (2010) A General Approach to Causal 
#'   Mediation Analysis, Psychological Methods, Vol. 15, No. 4 (December), pp. 
#'   309-334.
#'   
#'   Imai, K., Keele, L. and Yamamoto, T. (2010) Identification, Inference, and 
#'   Sensitivity Analysis for Causal Mediation Effects, Statistical Science, 
#'   Vol. 25, No. 1 (February), pp. 51-71.
#'   
#'   Imai, K., Keele, L., Tingley, D. and Yamamoto, T. (2009) "Causal Mediation 
#'   Analysis Using R" in Advances in Social Science Research Using R, ed. H. D.
#'   Vinod New York: Springer.
#'   
#' @examples
#' # Examples with JOBS II Field Experiment
#' 
#' # **For illustration purposes a small number of simulations are used**
#' 
#' data(jobs)
#' 
#' # Fit mediator and outcome models allowing for interaction with moderator
#' b.int <- lm(job_seek ~ treat*age + econ_hard + sex, data=jobs)
#' d.int <- lm(depress2 ~ treat*job_seek*age + econ_hard + sex, data=jobs)
#' 
#' # Initial mediate fit
#' fit <- mediate(b.int, d.int, sims=50, treat="treat", mediator="job_seek")
#' 
#' # Test for significance of moderated mediation
#' test.modmed(fit, list(age = 20), list(age = 70), sims = 100)
#' 
#' @export
test.modmed <- function(object, ...){
  UseMethod("test.modmed")
}

#' @export
test.modmed.default <- function(object, ...){
  stop("currently no test.modmed method exists for the input object.")
}

#' @rdname test.modmed
#' @export
test.modmed.mediate <- function(object, covariates.1, covariates.2,
                                sims = object$sims, conf.level = object$conf.level, ...){
  
  cl <- getCall(object)
  cl$long <- TRUE
  cl$sims <- sims
  
  seed <- .Random.seed
  cl$covariates <- covariates.1
  out.1 <- eval(cl, envir = parent.frame())
  
  .Random.seed <- seed
  cl$covariates <- covariates.2
  out.2 <- eval(cl, envir = parent.frame())
  
  d1.diff <- out.1$d1 - out.2$d1
  d1.diff.sims <- out.1$d1.sims - out.2$d1.sims

  z0.diff <- out.1$z0 - out.2$z0
  z0.diff.sims <- out.1$z0.sims - out.2$z0.sims
  
  if(object$INT){
  
    d0.diff <- out.1$d0 - out.2$d0
    d0.diff.sims <- out.1$d0.sims - out.2$d0.sims

    z1.diff <- out.1$z1 - out.2$z1
    z1.diff.sims <- out.1$z1.sims - out.2$z1.sims
    
  }
  
  # Format results
  
  null.value <- 0
  
  if(object$INT){
    
    pv <- pval(d1.diff.sims, d1.diff)
    ci <- quantile(d1.diff.sims, c((1 - conf.level)/2, (1 + conf.level)/2))
    names(d1.diff) <- names(null.value) <- "ACME(1|covariates.1) - ACME(1|covariates.2)"
    attr(ci, "conf.level") <- conf.level
    res.d1 <- list(statistic = d1.diff, p.value = pv, conf.int = ci,
                 null.value = null.value, alternative = "two.sided",
                 method = "Test of ACME(1|covariates.1) - ACME(1|covariates.2) = 0",
                 data.name = paste("estimates from", deparse(substitute(object))))
  
    pv <- pval(d0.diff.sims, d0.diff)
    ci <- quantile(d0.diff.sims, c((1 - conf.level)/2, (1 + conf.level)/2))
    names(d0.diff) <- names(null.value) <- "ACME(0|covariates.1) - ACME(0|covariates.2)"
    attr(ci, "conf.level") <- conf.level
    res.d0 <- list(statistic = d0.diff, p.value = pv, conf.int = ci,
                 null.value = null.value, alternative = "two.sided",
                 method = "Test of ACME(0|covariates.1) - ACME(0|covariates.2) = 0",
                 data.name = paste("estimates from", deparse(substitute(object))))

    pv <- pval(z1.diff.sims, z1.diff)
    ci <- quantile(z1.diff.sims, c((1 - conf.level)/2, (1 + conf.level)/2))
    names(z1.diff) <- names(null.value) <- "ADE(1|covariates.1) - ADE(1|covariates.2)"
    attr(ci, "conf.level") <- conf.level
    res.z1 <- list(statistic = z1.diff, p.value = pv, conf.int = ci,
                 null.value = null.value, alternative = "two.sided",
                 method = "Test of ADE(1|covariates.1) - ADE(1|covariates.2) = 0",
                 data.name = paste("estimates from", deparse(substitute(object))))
  
    pv <- pval(z0.diff.sims, z0.diff)
    ci <- quantile(z0.diff.sims, c((1 - conf.level)/2, (1 + conf.level)/2))
    names(z0.diff) <- names(null.value) <- "ADE(0|covariates.1) - ADE(0|covariates.2)"
    attr(ci, "conf.level") <- conf.level
    res.z0 <- list(statistic = z0.diff, p.value = pv, conf.int = ci,
                 null.value = null.value, alternative = "two.sided",
                 method = "Test of ADE(0|covariates.1) - ADE(0|covariates.2) = 0",
                 data.name = paste("estimates from", deparse(substitute(object))))
    
    class(res.d1) <- class(res.d0) <- class(res.z1) <- class(res.z0) <- "htest"
    res <- list(res.d1, res.d0, res.z1, res.z0)

  } else {
    
    pv <- pval(d1.diff.sims, d1.diff)
    ci <- quantile(d1.diff.sims, c((1 - conf.level)/2, (1 + conf.level)/2))
    names(d1.diff) <- names(null.value) <- "ACME(covariates.1) - ACME(covariates.2)"
    attr(ci, "conf.level") <- conf.level
    res.d1 <- list(statistic = d1.diff, p.value = pv, conf.int = ci,
                 null.value = null.value, alternative = "two.sided",
                 method = "Test of ACME(covariates.1) - ACME(covariates.2) = 0",
                 data.name = paste("estimates from", deparse(substitute(object))))

    pv <- pval(z0.diff.sims, z0.diff)
    ci <- quantile(z0.diff.sims, c((1 - conf.level)/2, (1 + conf.level)/2))
    names(z0.diff) <- names(null.value) <- "ADE(covariates.1) - ADE(covariates.2)"
    attr(ci, "conf.level") <- conf.level
    res.z0 <- list(statistic = z0.diff, p.value = pv, conf.int = ci,
                 null.value = null.value, alternative = "two.sided",
                 method = "Test of ADE(covariates.1) - ADE(covariates.2) = 0",
                 data.name = paste("estimates from", deparse(substitute(object))))
  
    class(res.d1) <- class(res.z0) <- "htest"
    res <- list(res.d1, res.z0)
    
  }
  
  class(res) <- "test.modmed.mediate"
  return(res)
  
}

#' @rdname test.modmed
#' @export
print.test.modmed.mediate <- function(x, ...){
  for(i in 1:length(x)){
    print(x[[i]], ...)
  }
}


##############################Order Functions##################################

#' @export
test.TMint.mediate.order <- function(x, conf.level = x$conf.level, ...){
  if(is.null(x$d0.sims) || is.null(x$d1.sims) || is.null(x$z0.sims) || is.null(x$z1.sims)){
    stop("simulation draws missing; rerun mediate with 'long' set to TRUE")
  }
  if(!x$INT){
    stop("outcome model must include interaction between treatment and mediator")
  }
  d.diff <- x$d1 - x$d0
  d.diff.sims <- x$d1.sims - x$d0.sims  
  
  # Format results in the htest.order format
  # p-values
  y.lab <- sort(unique(levels(model.frame(x$model.y)[,1])))
  n.ycat <- length(y.lab)
  int.p <- rep(NA, n.ycat)
  ci.lo <- rep(NA, n.ycat)
  ci.up <- rep(NA, n.ycat)
  for(i in 1:n.ycat){
   int.p[i] <- pval(d.diff.sims[,i], d.diff[i])
   ci.lo[i] <- quantile(d.diff.sims[,i], (1 - conf.level)/2)
   ci.up[i] <- quantile(d.diff.sims[,i], (1 + conf.level)/2)
  }
  null.value <- 0
  names(d.diff) <- rep("ACME(1) - ACME(0)", n.ycat)
  names(null.value) <- "ACME(1) - ACME(0)"
  res <- list(statistic = d.diff, p.value = int.p, conf.int = rbind(ci.lo, ci.up),
               null.value = null.value, alternative = "two.sided", 
               method = "Tests of ACME(1) - ACME(0) = 0",
               conf.level = conf.level, y.lab = y.lab)  
  class(res) <- "htest.order"
  res
}

#' @export
print.htest.order <- function(x, ...){
  
  clp <- 100 * x$conf.level
  tab.1 <- rbind(x$statistic, x$conf.int[1,], x$conf.int[2,], x$p.value)
  rownames(tab.1) <- c(names(x$statistic)[1], paste(clp, "% CI Lower", sep=""), paste(clp, "% CI Upper", sep=""), "p-value")
  
  out.names <- c()
  for(i in 1:length(x$y.lab)){
    out.names.tmp <- paste("Pr(Y=",x$y.lab[i],")",sep="")
    out.names <- c(out.names, out.names.tmp)
  }
  colnames(tab.1) <- out.names

  cat("\n")
  cat(x$method, "\n\n")
  print(tab.1, digits=3)
  cat("\n")
  
}

#' @export
test.modmed.mediate.order <- function(object, covariates.1, covariates.2,
                                sims = object$sims, conf.level = object$conf.level, ...){
  
  cl <- getCall(object)
  cl$long <- TRUE
  cl$sims <- sims
  
  seed <- .Random.seed
  cl$covariates <- covariates.1
  out.1 <- eval(cl)
  
  .Random.seed <- seed
  cl$covariates <- covariates.2
  out.2 <- eval(cl)
  
  d1.diff <- out.1$d1 - out.2$d1
  d1.diff.sims <- out.1$d1.sims - out.2$d1.sims

  z0.diff <- out.1$z0 - out.2$z0
  z0.diff.sims <- out.1$z0.sims - out.2$z0.sims
  
  if(object$INT){
  
    d0.diff <- out.1$d0 - out.2$d0
    d0.diff.sims <- out.1$d0.sims - out.2$d0.sims

    z1.diff <- out.1$z1 - out.2$z1
    z1.diff.sims <- out.1$z1.sims - out.2$z1.sims
    
  }
  
  # Format results	
  y.lab <- sort(unique(levels(model.frame(object$model.y)[,1])))
  n.ycat <- length(y.lab)
  out.names <- c()
  for(i in 1:length(y.lab)){
    out.names.tmp <- paste("Pr(Y=",y.lab[i],")",sep="")
    out.names <- c(out.names, out.names.tmp)
  }
    
  null.value <- 0
  clp <- 100 * conf.level
  
  if(object$INT){

    d1.int.p <- d1.ci.lo <- d1.ci.up <- d0.ci.lo <- d0.ci.up <- d0.int.p <- z1.int.p <- z0.int.p <- z1.ci.lo <- z1.ci.up <- z0.ci.lo <- z0.ci.up <- rep(NA, n.ycat)
    
    for(i in 1:n.ycat){
     d1.int.p[i] <- pval(d1.diff.sims[,i], d1.diff[i])
     d1.ci.lo[i] <- quantile(d1.diff.sims[,i], (1 - conf.level)/2)
     d1.ci.up[i] <- quantile(d1.diff.sims[,i], (1 + conf.level)/2)
     
     d0.int.p[i] <- pval(d0.diff.sims[,i], d0.diff[i])
     d0.ci.lo[i] <- quantile(d0.diff.sims[,i], (1 - conf.level)/2)
     d0.ci.up[i] <- quantile(d0.diff.sims[,i], (1 + conf.level)/2)
     
     z1.int.p[i] <- pval(z1.diff.sims[,i], z1.diff[i])
     z1.ci.lo[i] <- quantile(z1.diff.sims[,i], (1 - conf.level)/2)
     z1.ci.up[i] <- quantile(z1.diff.sims[,i], (1 + conf.level)/2)
     
     z0.int.p[i] <- pval(z0.diff.sims[,i], d0.diff[i])
     z0.ci.lo[i] <- quantile(z0.diff.sims[,i], (1 - conf.level)/2)
     z0.ci.up[i] <- quantile(z0.diff.sims[,i], (1 + conf.level)/2)
     
    }
    
    names(d1.diff) <- rep("ACME(1|covariates.1) - ACME(1|covariates.2)", n.ycat)
    names(d0.diff) <- rep("ACME(0|covariates.1) - ACME(0|covariates.2)", n.ycat)
    names(z1.diff) <- rep("ADE(1|covariates.1) - ADE(1|covariates.2)", n.ycat)
    names(z0.diff) <- rep("ADE(0|covariates.1) - ADE(0|covariates.2)", n.ycat)
    
    res.d1 <- list(statistic = d1.diff, p.value = d1.int.p, 
                    conf.int = rbind(d1.ci.lo, d1.ci.up),
                    null.value = null.value, alternative = "two.sided",
                    method = "Tests of ACME(1|covariates.1) - ACME(1|covariates.2) = 0",
                    conf.level = conf.level, y.lab = y.lab)
    res.d0 <- list(statistic = d0.diff, p.value = d0.int.p, 
                    conf.int = rbind(d0.ci.lo, d0.ci.up),
                    null.value = null.value, alternative = "two.sided",
                    method = "Tests of ACME(0|covariates.1) - ACME(0|covariates.2) = 0",
                    conf.level = conf.level, y.lab = y.lab)
    res.z1 <- list(statistic = z1.diff, p.value = z1.int.p, 
                    conf.int = rbind(z1.ci.lo, z1.ci.up),
                    null.value = null.value, alternative = "two.sided",
                    method = "Tests of ADE(1|covariates.1) - ADE(1|covariates.2) = 0",
                    conf.level = conf.level, y.lab = y.lab)
    res.z0 <- list(statistic = z0.diff, p.value = z0.int.p, 
                    conf.int = rbind(z0.ci.lo, z0.ci.up),
                    null.value = null.value, alternative = "two.sided",
                    method = "Tests of ADE(0|covariates.1) - ADE(0|covariates.2) = 0",
                    conf.level = conf.level, y.lab = y.lab)
                    
    class(res.d1) <- class(res.d0) <- class(res.z1) <- class(res.z0) <- "htest.order"
    res <- list(res.d1, res.d0, res.z1, res.z0)
  
  } else {
  
    d1.int.p <- d1.ci.lo <- d1.ci.up <- z0.int.p <- z0.ci.lo <- z0.ci.up <- rep(NA, n.ycat)
    
    for(i in 1:n.ycat){
     d1.int.p[i] <- pval(d1.diff.sims[,i], d1.diff[i])
     d1.ci.lo[i] <- quantile(d1.diff.sims[,i], (1 - conf.level)/2)
     d1.ci.up[i] <- quantile(d1.diff.sims[,i], (1 + conf.level)/2)
     
     z0.int.p[i] <- pval(z0.diff.sims[,i], d0.diff[i])
     z0.ci.lo[i] <- quantile(z0.diff.sims[,i], (1 - conf.level)/2)
     z0.ci.up[i] <- quantile(z0.diff.sims[,i], (1 + conf.level)/2)
    }
    
    names(d1.diff) <- rep("ACME(1|covariates.1) - ACME(1|covariates.2)", n.ycat)
    names(z0.diff) <- rep("ADE(0|covariates.1) - ADE(0|covariates.2)", n.ycat)
    
    res.d1 <- list(statistic = d1.diff, p.value = d1.int.p, 
                    conf.int = rbind(d1.ci.lo, d1.ci.up),
                    null.value = null.value, alternative = "two.sided",
                    method = "Tests of ACME(1|covariates.1) - ACME(1|covariates.2) = 0",
                    conf.level = conf.level, y.lab = y.lab)
    res.z0 <- list(statistic = z0.diff, p.value = z0.int.p, 
                    conf.int = rbind(z0.ci.lo, z0.ci.up),
                    null.value = null.value, alternative = "two.sided",
                    method = "Tests of ADE(0|covariates.1) - ADE(0|covariates.2) = 0",
                    conf.level = conf.level, y.lab = y.lab)
                    
    class(res.d1) <- class(res.z0) <- "htest.order"
    res <- list(res.d1, res.z0)
  }
  class(res) <- "test.modmed.mediate.order"
  return(res)
}

#' @export
print.test.modmed.mediate.order <- function(x, ...){
  for(i in 1:length(x)){
    print(x[[i]], ...)
  }
}


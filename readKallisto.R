.require <-
    function(pkg)
{
    withCallingHandlers({
        suppressPackageStartupMessages({
            require(pkg, character.only=TRUE, quietly=TRUE)
        })
    }, warning=function(w) {
        invokeRestart("muffleWarning")
    }) || {
        msg <- sprintf('install %s with
            source("http://bioconductor.org/biocLite.R"); biocLite("%s")',
            pkg, pkg)
        stop(paste(strwrap(msg, exdent=2), collapse="\n"))
    }
}

.open <- function(files, h5) {
    lapply(files, function(file) {
        if (h5 && H5Fis_hdf5(file))
            H5Fopen(file)
        else file(file, open="rt")
    })
}
    
.close <- function(cons)
    UseMethod(".close")

.close.list <- function(cons)
    for (con in cons)
        .close(con)

.close.connection <- function(cons)
    close(cons)

.close.H5IdComponent <- function(cons)
    H5Fclose(cons)

.colData <- function(jsonfile) {
    json <- fromJSON(jsonfile)
    do.call("data.frame", c(json, stringsAsFactors=FALSE))
}

.KALLISTO_COLCLASSES <-
    c("character", "integer" , "numeric", "numeric", "numeric")

.KALLISTO_ROWDATA <- "length"

KALLISTO_ASSAYS <- c("est_counts", "tpm", "eff_length")

.read <- function(con)
    UseMethod(".read")

.read.connection <- function(con)
    read.delim(con, header=TRUE, colClasses=.KALLISTO_COLCLASSES, row.names=1)
    
.read.H5IdComponent <- function(con) {
    eff_length <- h5read(con, "/aux/eff_lengths")
    est_counts <- h5read(con, "/est_counts")
    tpm0 <- est_counts / eff_length
    data.frame(row.names=h5read(con, "/aux/ids"),
               length=h5read(con, "/aux/lengths"),
               eff_length=eff_length,
               est_counts=est_counts,
               tpm=tpm0 / (sum(tpm0) / 1e6))
}

readKallisto <-
    function(files,
             json=file.path(dirname(files), "run_info.json"),
             h5=any(grepl("\\.h5$", files)),
             what=KALLISTO_ASSAYS,
             as=c("matrix", "list", "SummarizedExperiment"))
{
    as <- match.arg(as)
    if (missing(what))
        what <- what[1]
    else {
        whats <- eval(formals()[["what"]])
        if (!all(what %in% KALLISTO_ASSAYS))
            stop("'what' must be in ",
                 paste(sQuote(KALLISTO_ASSAYS), collapse=", "),
                 call.=FALSE)
    }
    stopifnot(is.character(files))
    test <- file.exists(files)
    if (!all(test))
        stop("file(s) do not exist:\n  ",
             paste(files[!test], collapse="\n  "))
    if (is.null(names(files)))
        names(files) <- basename(dirname(files))

    if (as != "matrix") {
        .require("jsonlite")
        stopifnot(length(files) == length(json))
        if (!is.null(names(json)))
            stopifnot(identical(names(json), names(files)))
        else
            names(json) <- names(files)
        test <- file.exists(json)
        if (!all(test))
            stop("json file(s) do not exist:\n  ",
                 paste(json[!test], collapse="\n  "))
    }

    if (h5)
        .require("rhdf5")

    if (as == "SummarizedExperiment") {
        if (BiocInstaller::biocVersion() >= '3.2')
            .require("SummarizedExperiment")
        else .require("GenomicRanges")
    }

    cons <- .open(files, h5)
    value <- .read(cons[[1]])
    rowData <- value[, .KALLISTO_ROWDATA, drop=FALSE]
    assay <- matrix(0, nrow(rowData), length(cons),
                    dimnames=list(rownames(rowData), names(cons)))
    assays <- setNames(replicate(length(what), assay, FALSE), what)
    for (w in what)
        assays[[w]][,1] <- value[[w]]
    for (i in seq_along(cons)[-1]) {
        value <- .read(cons[[i]])
        if (!identical(rowData, value[, .KALLISTO_ROWDATA, drop=FALSE]))
            stop("rowData differs between files:\n  ",
                 paste(files[c(1, i)], collapse="\n  "))
        for (w in what)
            assays[[w]][,i] <- value[[w]]
    }
    .close(cons)

    if (as != "matrix")
        colData <- do.call("rbind", lapply(json, .colData))

    switch(as, matrix={
        if (length(assays) == 1L)
            assays[[1]]
        else assays
    }, list={
        c(setNames(list(colData, rowData), c("colData", "rowData")), assays)
    }, SummarizedExperiment={
        partition <-
            PartitioningByEnd(integer(nrow(rowData)), names=rownames(rowData))
        rowRanges <- relist(GRanges(), partition)
        mcols(rowRanges) <- as(rowData, "DataFrame")
        SummarizedExperiment(assays=assays, rowRanges=rowRanges,
                             colData=as(colData, "DataFrame"))
    })
}

.readIds <- function(con, i) {
    if (!missing(i))
        h5read(con, "/aux/ids", list(i))
    else h5read(con, "/aux/ids")
}
    
readBootstrap <-
    function(file, i, j)
{
    .require("rhdf5")
    stopifnot(length(file) == 1L, is.character(file))
    stopifnot(file.exists(file))
    stopifnot(H5Fis_hdf5(file))
    con <- H5Fopen(file)
    on.exit(H5Fclose(con))
    nboot <- as.integer(h5read(con, "/aux/num_bootstrap"))
    if (nboot == 0L)
        stop("file contains no bootstraps:\n  ", file)

    if (!missing(i) && is.character(i)) {
        idx <- match(i, .readIds(con))
        if (anyNA(i))
            stop("unknown target id(s)", i[is.na(idx)])
        i <- idx
    }
    if (!missing(j) && is.numeric(j)) {
        if (any((j < 1L) || any(j > nboot)))
            stop("'j' must be >0 and <=", nboot)
        j <- paste0("bs", as.integer(j) - 1L)
    }

    m <- if (missing(i) && missing(j)) {
        simplify2array(h5read(con, "/bootstrap"))
    } else if (missing(i)) {
        query <- setNames(sprintf("/bootstrap/%s", j), j)
        simplify2array(lapply(query, h5read, file=con))
    } else if (missing(j)) {
        group <- H5Gopen(con, "/bootstrap")
        name <- h5ls(group)$name
        H5Gclose(group)
        query <- setNames(sprintf("/bootstrap/%s", name), name)
        simplify2array(lapply(query, h5read, file=con, index=list(i)))
    } else {
        query <- setNames(sprintf("/bootstrap/%s", j), j)
        simplify2array(lapply(query, h5read, file=con, index=list(i)))
    }

    rownames(m) <- .readIds(con, i)
    if (missing(j)) {
        o <- order(as.integer(sub("bs", "", colnames(m), fixed=TRUE)))
        m[,o]
    } else m
}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fct_go.R
\name{convert_from_ensembl_eck12}
\alias{convert_from_ensembl_eck12}
\title{For E coli, converts ensembl IDs to entrez IDs, 
symbol or name}
\usage{
convert_from_ensembl_eck12(ids, to = "entrez")
}
\arguments{
\item{ids}{genes to convert, ensembl}

\item{to}{value in c("entrez", "symbol", "name")}
}
\value{
named vector
}
\description{
For E coli, converts ensembl IDs to entrez IDs, 
symbol or name
}
\examples{
if(require("org.Ce.eg.db")){
genes <- c("WBGene00000042", "WBGene00000041")
convert_from_ensembl_ce(genes)
convert_from_ensembl_ce(genes, to = "symbol")
convert_from_ensembl_ce(genes, to = "name")
}
}

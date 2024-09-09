# Generated from create-biobaby.Rmd: do not edit by hand

#' A dataset containing all OpenGWAS outcomes
#'
#' @description This dataset lists all available outcome IDs obtained from the OpenGWAS database, primarily used for Mendelian Randomization analysis. The data was retrieved using the `available_outcomes()` function from the `TwoSampleMR` package. It includes important information related to each outcome, aiding researchers in selecting appropriate outcomes for causal inference analysis.
#'
#' @format A data frame with multiple rows and 24 variables:
#' \describe{
#'   \item{id}{Unique identifier for each outcome}
#'   \item{trait}{Name of the trait}
#'   \item{group_name}{Name of the study group}
#'   \item{year}{Year of publication}
#'   \item{consortium}{Name of the consortium}
#'   \item{author}{Lead author of the study}
#'   \item{sex}{Sex of the participants}
#'   \item{population}{Target population of the study}
#'   \item{sample_size}{Sample size of the study}
#'   \item{build}{Genome build version used}
#'   \item{subcategory}{Subcategory of the outcome}
#'   \item{category}{Main category of the outcome}
#'   \item{doi}{Digital Object Identifier (DOI) of the study}
#'   \item{unit}{Unit of measurement for the trait}
#'   \item{ontology}{Ontology description of the trait}
#'   \item{note}{Additional notes}
#'   \item{ncase}{Number of cases}
#'   \item{ncontrol}{Number of controls}
#'   \item{mr}{Indicator if the study is suitable for Mendelian Randomization}
#'   \item{pmid}{PubMed ID of the related publication}
#'   \item{nsnp}{Number of SNPs used in the study}
#'   \item{coverage}{Coverage of the study}
#'   \item{study_design}{Type of study design}
#'   \item{priority}{Priority of the study}
#'   \item{sd}{Standard deviation of the measurements}
#' }
#'
#' @source Data obtained from the OpenGWAS database using the `TwoSampleMR` package.
"all_outcomes"

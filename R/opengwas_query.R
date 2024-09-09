# Generated from create-biobaby.Rmd: do not edit by hand

#' @title 分片查询并缓存结果到本地文件
#' @description 此函数将SNP列表分片查询API，并将结果缓存到本地文件，以避免重复查询。
#'
#' @param snps 字符向量，表示要查询的SNP字符串或列表，比如ukb-e-30800_CSA。
#' @param outcomes 字符向量，表示要查询的结局列表。
#' @param chunk_size 整数，每个分片的SNP数量，默认为1000。
#' @param cache_dir 字符串，缓存文件的存储目录，默认为"cache"。
#' @return 所有分片查询的合并结果，数据框。
#' @examples
#' cache_dir <- "cache"
#' snps <- unique(exp_data$SNP[1:5000])
#' outcome <- opengwas_query(snps, "ukb-e-30800_CSA", cache_dir = cache_dir)
#' @details 此函数首先将SNP列表分片查询API，如果查询结果已缓存，则使用缓存结果，否则进行API查询并缓存结果。最后返回所有分片查询的合并结果。
#'
#' @note 请确保输入的SNP和结局列表是有效的。
#' @keywords gwas query api cache
#' @import TwoSampleMR digest crayon dplyr
#' @export
opengwas_query <- function(snps, outcomes, chunk_size = 1000, cache_dir = "cache") {
  # 定义一个分片查询的函数
  query_api <- function(snps, outcomes) {
    result <- extract_outcome_data(
      snps = snps,
      outcomes = outcomes,
      proxies = FALSE,
      palindromes = 1,
      maf_threshold = 0.3,
      splitsize = 5000,
      proxy_splitsize = 500
    )
    return(result)
  }

  unique_snps <- unique(snps)
  n <- length(unique_snps)
  cat(blue("注意10分钟上限1万次查询，您的查询数量为: "), yellow(n), "\n")

  # 创建缓存目录（如果不存在）
  if (!dir.exists(cache_dir)) {
    cat(blue("新建缓存目录: "), yellow(cache_dir), "\n")
    dir.create(cache_dir)
  }

  total_chunks <- ceiling(n / chunk_size)

  for (i in seq(1, n, by = chunk_size)) {
    chunk <- unique_snps[i:min(i + chunk_size - 1, n)]

    # 生成缓存文件路径
    cache_key <- digest(paste0(chunk,collapse = "_"), algo = "sha1")
    cache_file <- file.path(cache_dir, paste0(cache_key, ".rds"))

    chunk_index <- ceiling(i / chunk_size)
    cat(green("处理分片 "), yellow(chunk_index), green(" / "), yellow(total_chunks), "\n")

    # 检查是否已经缓存
    if (file.exists(cache_file)) {
      cat(blue("使用本地缓存结果，分片范围: "), yellow(paste(i, "到", min(i + chunk_size - 1, n))), "\n")
      cached_result <- readRDS(cache_file)
      api_result <- cached_result
    } else {
      cat(green("正在查询API，分片范围: "), yellow(paste(i, "到", min(i + chunk_size - 1, n))), "\n")

      # 如果没有缓存则查询API
      api_result <- query_api(chunk, outcomes)
      # 如果API返回非空结果则缓存到本地文件
      if (!is.null(api_result)) {
        saveRDS(api_result, cache_file)
        cat(green("查询成功并缓存结果到本地文件，分片范围: "), yellow(paste(i, "到", min(i + chunk_size - 1, n))), "\n")
      } else {
        cat(red("API查询返回空结果，分片范围: "), yellow(paste(i, "到", min(i + chunk_size - 1, n))), "\n")
      }
    }

    # 处理结果 (这里假设你需要将结果保存到一个列表中)
    if (i == 1) {
      final_result <- api_result
    } else {
      final_result <- bind_rows(final_result, api_result)
    }
  }

  return(final_result)
}

# README

## 项目简介

本项目包含了一组用于进行孟德尔随机化 (MR) 分析的批量有效暴露筛选的方法。

## 安装

```R
# 使用 devtools
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}
devtools::install_github("Younthing/biobaby")

# 使用 remotes
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}
remotes::install_github("Younthing/biobaby")

# 使用 pak
if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak")
}
pak::pkg_install("Younthing/biobaby")

```

## 依赖

运行脚本需要以下 R 包：

- crayon
- TwoSampleMR
- digest
- furrr
- dplyr
- tidyr
- stringr
- openxlsx

## 函数列表

### process_data

处理暴露和结局数据，根据指定条件进行筛选并合并。

- **exp_data**: 数据框，暴露数据。
- **ao_data**: 数据框，结局数据。
- **remove_eqtl**: 逻辑值，是否移除暴露数据中的 eQTL，默认为`TRUE`。
- **filter_population**: 字符串，指定结局数据中需要筛选的人群，默认为`"European"`。

示例：

```r
result_data <- process_data(exp_data, ao_data, remove_eqtl = TRUE, filter_population = "European")
```

### get_cached_results

分片查询 SNP 信息，并将结果缓存到本地以避免重复查询。

- **snps**: 字符向量，要查询的 SNP 字符串或列表。
- **outcomes**: 字符向量，要查询的结局列表。
- **chunk_size**: 整数，每个分片的 SNP 数量，默认为`1000`。
- **cache_dir**: 字符串，缓存文件的存储目录，默认为`"cache"`。

示例：

```r
snps <- unique(exp_data$SNP[1:5000])
outcome <- get_cached_results(snps, "ukb-e-30800_CSA", cache_dir = "cache")
```

### perform_mr_analysis

使用并行处理进行 MR 分析。

- **exp_data**: 数据框，暴露数据。
- **outcome_data**: 数据框，结局数据。
- **cores**: 整数，使用的 CPU 核心数量，默认为可用核心数量的一半。

示例：

```r
final_results <- perform_mr_analysis(exp_data, outcome_data, cores = availableCores() / 2)
```

### export_results

将 MR 分析结果导出到 Excel 文件。

- **final_results**: 数据框，MR 分析结果。
- **output_file**: 字符串，保存 Excel 工作簿的文件名，默认为`"results.xlsx"`。

示例：

```r
export_results(final_results, output_file = "results.xlsx")
```

## 示例

```r
exp_file <- "exp_data_2023.4.3_p5e8_idALL.rds"
ao_file <- "ao_2024_4_23.csv"
exp_data <- readRDS(exp_file)
ao_data <- read.csv(ao_file)

exp_data <- process_data(exp_data, ao_data)
snps <- unique(exp_data$SNP[1:5000])
outcome <- get_cached_results(snps, "ukb-e-30800_CSA", cache_dir = "cache")
final_results <- perform_mr_analysis(exp_data = exp_data, outcome_data = outcome)
export_results(final_results)
```

## 注意事项

- 请确保输入数据框的格式正确。
- 注意 API 查询限制（每 10 分钟 10000 次查询）。

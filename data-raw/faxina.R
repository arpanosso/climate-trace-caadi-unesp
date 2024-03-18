library(tidyverse)
dados <- readr::read_rds("data-raw/emissions_sources.rds")
dados <- dados %>%
 filter(sigla_uf == "SP")
readr::write_rds(dados,"data/sp-emissions-sources.rds")

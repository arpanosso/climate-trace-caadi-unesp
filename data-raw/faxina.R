library(tidyverse)
dados <- readr::read_rds("data/emissions_sources.rds")
dados <- dados %>%
 filter(sigla_uf == "SP")
writexl::write_xlsx(dados,"data/sp-emissions-sources.xlsx")

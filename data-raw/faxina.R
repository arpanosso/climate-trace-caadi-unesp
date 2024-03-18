library(tidyverse)
dados <- readr::read_rds("data-raw/emissions_sources.rds")
dados <- dados %>%
 filter(sigla_uf == "SP")

sub_sector <- dados$sub_sector |> unique()

for(i in seq_along(sub_sector)){
  string_ss <- sub_sector[i]
  df <- dados |>
    filter(sub_sector == string_ss)
  readr::write_rds(df,
                  paste0("data/",
                         sub_sector[i],".rds"))
}


<!-- README.md is generated from README.Rmd. Please edit that file -->

# Caracterização dos municípios paulistas para intervenção ambiental na redução de emissões de gases de efeito estufa

**Tema do projeto:** Mudanças Climáticas Globais

**Local de desenvolvimento da intervenção:** Estudo realizado na FCAV-
UNESP, com foco para os municípios do Estado de São Paulo, Brasil.

**Objetivos do projeto, incluindo as mudanças a serem atingidas:** O
projeto tem como principal objetivo fornecer subsídios para a tomada de
decisão em políticas públicas, com foco na redução do desmatamento, na
promoção de práticas sustentáveis na agricultura e uso da terra, na
conservação dos biomas brasileiros e no desenvolvimento de tecnologias
para monitoramento e mitigação de emissões, especialmente nos municípios
do estado de São Paulo. Para isso, serão adotadas técnicas de
inteligência artificial, como aprendizado de máquina, para análise de
dados do Climate TRACE, identificando padrões e agrupando municípios
para definir as variáveis mais relevantes em cada um, proporcionando
subsídios estratégicos para as ações de intervenção.

**Resumo** A elevação da temperatura global destaca a importância dos
países atingirem o equilíbrio líquido de zero emissões de gases de
efeito estufa (GEE) até meados deste século. Para isso, é importante
equilibrar as fontes e sumidouros de emissões; nesse contexto, em 2015,
o Brasil apresentou suas metas de redução de emissões em suas primeiras
Contribuições Nacionalmente Determinadas (NDC) para a Convenção das
Nações Unidas sobre Mudança do Clima (UNFCCC). As estimativas do balanço
de carbono podem ser feitas com vários métodos, desde amostragem de
gases atmosféricos, técnicas de torres estáticas e métodos de
inventários usando fatores de emissão em diretrizes com protocolos do
IPCC (Painel Intergovernamental sobre Mudança do Clima). Recentemente, o
Climate TRACE, uma coalizão de organizações que trabalham para melhorar
o monitoramento de emissões, desenvolveu uma abordagem que combina
sensoriamento remoto, técnicas de aprendizado de máquina e dados de
inventários para estimar as emissões globais de gases de efeito estufa
por setor (www.climatetrace.org). Os dados do Climate TRACE incluem
estimativas de emissões para Agricultura, Edifícios, Operações de
Combustíveis Fósseis, Floresta e Uso da Terra, Gases Fluorados,
Manufatura, Extração Mineral, Energia e Resíduos. No contexto deste
projeto, serão aplicadas técnicas de inteligência artificial, como
aprendizado de máquina estatístico, para identificar padrões e agrupar
os municípios do estado de São Paulo em fontes e sumidouros de gases,
isso permitirá a definição das variáveis chaves para descrever as
emissões e fornecer os subsídios necessários para a criação de
estratégias de intervenção locais.

## Carregando os pacotes

``` r
library(tidyverse)
```

## Entrada dos dados

``` r
list_rds <- list.files("data/")
dados <- map_df(
  list_rds,
  ~readr::read_rds(paste0("data/",
                          .x))
)
```

## Municipios `geobr`

``` r
city <- geobr::read_municipality(
  showProgress = FALSE)
```

## Definindo os municípios do estado de São Paulo

``` r
sp_city <- city %>%  
  filter(abbrev_state == "SP")
```

## Estado de São Paulo

``` r
sp_city %>%  
  ggplot()  +
  geom_sf(fill="white", color="black",
          size=.15, show.legend = FALSE) +
  geom_point(
    data = dados %>%
      filter(year == 2022
             ),
    aes(lon,lat, color = biome))
```

![](README_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

``` r
nomes_uf = "SP"
dados %>% 
  filter(
         year == 2022,
         gas == "co2e_100yr",
         !source_name %in% nomes_uf,
         !sub_sector %in% c("forest-land-clearing",
                            "forest-land-degradation",
                            "shrubgrass-fires",
                            "forest-land-fires",
                            "wetland-fires",
                            "removals")
         ) %>% 
  group_by(sector_name) %>% 
  summarise(
    emission = sum(emissions_quantity, na.rm=TRUE)
  ) %>% 
  arrange(emission)  %>% 
  ungroup() %>% 
  mutate(emisison_p = emission/sum(emission)*100)
#> # A tibble: 7 × 3
#>   sector_name               emission emisison_p
#>   <chr>                        <dbl>      <dbl>
#> 1 forestry_and_land_use  -156419904.    -149.  
#> 2 power                     1668000        1.59
#> 3 manufacturing             8317700        7.91
#> 4 fossil_fuel_operations   10594440.      10.1 
#> 5 waste                    11698932.      11.1 
#> 6 transportation           54578954.      51.9 
#> 7 agriculture             174667725.     166.
```

``` r
dados %>% 
  filter(
    year == 2022,
    gas == "co2e_100yr",
    sector_name == "transportation",
#    !source_name %in% nomes_uf,
    !sub_sector %in% c("forest-land-clearing",
                            "forest-land-degradation",
                            "shrubgrass-fires",
                            "forest-land-fires",
                            "wetland-fires",
                            "removals")
     ) %>% 
  group_by(source_id,source_name, sub_sector) %>% 
  summarise(
    emission = sum(emissions_quantity, na.rm=TRUE)
  ) %>% 
  arrange(emission %>% desc()) %>% 
  ungroup() %>% 
  mutate(Acumulada = cumsum(emission)) %>% 
  ggplot(aes(x=emission)) +
  geom_histogram()
```

![](README_files/figure-gfm/unnamed-chunk-8-1.png)<!-- -->

``` r
library(treemapify)
dados %>% 
  filter(
         year == 2022,
         gas == "co2e_100yr",
         sector_name != "forestry_and_land_use",
         !source_name %in% nomes_uf,
         !sub_sector %in% c("forest-land-clearing",
                            "forest-land-degradation",
                            "shrubgrass-fires",
                            "forest-land-fires",
                            "wetland-fires",
                            "removals")
         ) %>% 
  group_by(sector_name) %>% 
  summarise(
    emission = sum(emissions_quantity, na.rm=TRUE)
  ) %>% 
  arrange(emission)  %>% 
  ungroup() %>% 
  mutate(emisison_p = emission/sum(emission)*100) %>% 
  ggplot(aes(area = emisison_p, fill = sector_name)) +
  geom_treemap() +
  geom_treemap_text(
    aes(label = paste(sector_name, 
                      paste0(round(emisison_p, 2), "%"), sep = "\n")), 
    colour = "white") +
  theme(legend.position = "none") +
  scale_fill_viridis_d()
```

![](README_files/figure-gfm/unnamed-chunk-9-1.png)<!-- -->

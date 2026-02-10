
# ----------- SETUP -----------

# Install required packages if missing
list.of.packages <- c("fredr", "tidyverse", "lubridate", "writexl")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

# Load packages
library(fredr)
library(tidyverse)
library(lubridate)
library(writexl)


# Set your FRED API key
# La chiave viene letta dal file .Renviron (NON committare mai la chiave nel codice!)
# Per configurarla:
#   1. Crea un file .Renviron nella cartella del progetto (o nella home ~/)
#   2. Aggiungi la riga: FRED_API_KEY=la_tua_chiave_qui
#   3. Riavvia R
# La API key si ottiene dopo essersi registrati al FRED: https://fred.stlouisfed.org/
fredr_set_key(Sys.getenv("FRED_API_KEY"))

# ----------- FUNCTION TO DOWNLOAD A SERIES -----------

scarica_serie <- function(codice, nome_locale) {
  fredr(
    series_id = codice,
    observation_start = as.Date("1950-01-01")
  ) %>%
    select(date, value) %>%
    rename(!!nome_locale := value)
}

# ----------- MENSILI -----------

serie_mensili <- list(
  INDPRO   = "produzione_industriale",
  CPIAUCNS = "indice dei prezzi al consumo usa",
  UNRATE   = "disoccupazione",
  FEDFUNDS = "tasso_fed_funds",
  PAYEMS   = "occupazione_non_agricola",
  PCE      = "consumi_personali"
)

mensili_df <- NULL
for (codice in names(serie_mensili)) {
  nome_locale <- serie_mensili[[codice]]
  serie <- scarica_serie(codice, nome_locale)
  mensili_df <- if (is.null(mensili_df)) serie else full_join(mensili_df, serie, by = "date")
}

# ----------- TRIMESTRALI -----------

serie_trimestrali <- list(
  GDPC1   = "pil_reale",
  DPCERA3Q086SBEA  = "consumi_reali",
  GPDIC1  = "investimenti_reali",
  GDPDEF  = "deflatore_pil"
)


trimestrali_df <- NULL
for (codice in names(serie_trimestrali)) {
  nome_locale <- serie_trimestrali[[codice]]
  serie <- scarica_serie(codice, nome_locale)
  trimestrali_df <- if (is.null(trimestrali_df)) serie else full_join(trimestrali_df, serie, by = "date")
}

# ----------- EXPORT TO EXCEL -----------
 
write_xlsx(
  list(
    "mensili" = mensili_df,
    "trimestrali" = trimestrali_df
  ),
  path = "serie_macro_fred.xlsx"
)

message("File Excel salvato: serie_macro_fred.xlsx")

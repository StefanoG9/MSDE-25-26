# Analisi Econometrica di Serie Storiche Macroeconomiche USA

> Progetto finale per il corso di **Modelli Statistici per Dati Economici (MSDE)** — Corso di Laurea in Scienze Statistiche, Università degli Studi di Padova, A.A. 2025–2026.

---

## Descrizione

Il progetto applica l'intero toolkit di analisi delle serie storiche lineari a un dataset di variabili macroeconomiche statunitensi provenienti dal database [FRED](https://fred.stlouisfed.org/) (Federal Reserve Economic Data). L'analisi copre progressivamente tutti i moduli del corso, dall'esplorazione univariata fino alla cointegrazione e alla stima di modelli VECM.

## Dataset

Il file `serie_macro_fred.xlsx` (foglio **mensili**) contiene sei serie storiche mensili:

| Variabile | Descrizione | Periodo |
|---|---|---|
| Produzione industriale | Indice di produzione industriale USA | Gen 1950 – Ago 2025 |
| CPI | Indice dei prezzi al consumo | Gen 1950 – Ago 2025 |
| Disoccupazione | Tasso di disoccupazione (%) | Gen 1950 – Ago 2025 |
| Tasso Fed Funds | Tasso dei Federal Funds (%) | Lug 1954 – Ago 2025 |
| Occupazione non agricola | Occupati non agricoli (migliaia) | Gen 1950 – Ago 2025 |
| Consumi personali | Consumi personali (mld USD) | Gen 1959 – Ago 2025 |

Il campione di analisi va da **gennaio 1959** (prima data con tutte le variabili disponibili) ad **agosto 2025**, per un totale di circa 800 osservazioni mensili.

## Struttura del progetto

```
.
├── README.md
├── .gitignore
├── .Renviron.example              # Template per la API key FRED
├── Scarica_serie_macro_fred.R     # Script per scaricare i dati dal FRED
├── progetto_msde.qmd              # Documento R Quarto (sorgente)
└── serie_macro_fred.xlsx          # Dataset (già incluso, scaricabile anche via script)
```

> Il report HTML non è incluso nel repository. Per generarlo: `quarto render progetto_msde.qmd`

## Metodologie applicate

### 1. Analisi univariata (MSDE_01)

- **Decomposizione classica** additiva e multiplicativa (trend, stagionalità, ciclo, residui)
- **ACF e PACF** campionarie per l'identificazione del modello
- **Modelli ARIMA/SARIMA** secondo l'approccio Box-Jenkins: il modello selezionato per log(produzione industriale) è un ARIMA(0,1,1)(2,0,1)[12] con drift (AIC = −4336.07)
- **Diagnostica dei residui**: test di Ljung-Box, test di Jarque-Bera per la normalità, QQ-plot
- **Previsione** a 12 mesi con intervalli di confidenza al 80% e 95%

### 2. Analisi bivariata e cross-correlazione (MSDE_02)

- **Cross-correlazione (CCF)** tra coppie di variabili in differenze: Δlog(Prod. Ind.) vs Δ(Disoccupazione), Δlog(CPI) vs Δ(Fed Funds), Δlog(Prod. Ind.) vs Δlog(CPI)
- Forte correlazione negativa contemporanea tra produzione e disoccupazione (coerente con la legge di Okun)
- Correlazione positiva ai lag positivi tra CPI e Fed Funds (la politica monetaria reagisce all'inflazione con ritardo)

### 3. Transfer Function Model (MSDE_03)

- **Prewhitening** della serie di input Δ(Fed Funds) tramite modello ARMA
- **CCF filtrata** tra residui prewhitened per l'identificazione della funzione di trasferimento
- Stima del TFM: Δ(Fed Funds) → Δ(Disoccupazione) con lag distribuiti
- Confronto tra CCF grezza e prewhitened: il prewhitening rimuove la contaminazione dell'autocorrelazione dell'input, producendo una CCF più pulita

### 4. Modelli VAR (MSDE_04)

- **Selezione dell'ordine** tramite criteri AIC, BIC, HQ e FPE su un VAR trivariato (Δlog Produzione, Δ Disoccupazione, Δlog CPI)
- **Verifica della stabilità**: tutte le radici inverse del polinomio caratteristico all'interno del cerchio unitario
- **Test di Granger-causalità**: la produzione industriale Granger-causa significativamente la disoccupazione
- **Impulse Response Functions (IRF)** ortogonalizzate (Cholesky, 500 bootstrap): uno shock positivo alla produzione riduce la disoccupazione per circa 5 mesi prima di esaurirsi; l'effetto sul CPI è trascurabile
- **FEVD**: la varianza dell'errore di previsione della disoccupazione è spiegata per circa il 50% dalla produzione industriale, confermando la forte interdipendenza tra settore reale e mercato del lavoro

### 5. Cointegrazione (MSDE_05)

- **Test ADF di radice unitaria** (procedura step-by-step con trend, drift e senza) su tutte le serie: log(Prod), log(CPI), log(Consumi), log(Occupazione) risultano I(1); la disoccupazione è stazionaria o borderline
- **Procedura di Engle-Granger**: regressione di cointegrazione log(Consumi) ~ log(Prod) + log(CPI); i residui mostrano forte persistenza (ACF che decade lentamente), indicando assenza di cointegrazione tra queste tre variabili con questa specifica combinazione lineare
- **Stima ECM**: il coefficiente dell'error correction term, pur negativo, è molto piccolo, confermando la debolezza della relazione di lungo periodo
- **Procedura di Johansen** (test trace e max eigenvalue): applicata al sistema trivariato log(Consumi), log(Prod), log(CPI) per determinare il rango di cointegrazione e stimare il VECM

### 6. Confronto tra modelli e selezione finale

| Criterio | ARIMA | TFM | VAR | VECM |
|---|---|---|---|---|
| N. variabili | 1 | 2 (input-output) | k (tutte endogene) | k (tutte endogene) |
| Relazioni dinamiche | Solo autocorrelazione | Unidirezionale | Bidirezionali | Bidirezionali + equilibrio |
| Relazioni di lungo periodo | No | No | No | Sì (cointegrazione) |
| Stagionalità | Sì (SARIMA) | Possibile | Possibile | Possibile |
| Interpretabilità | Alta | Media | Media (IRF, FEVD) | Alta (relazioni economiche) |
| N. parametri | Basso | Medio | Alto (k²p) | Alto |

## Principali risultati

1. **Le serie macroeconomiche USA sono I(1)**: produzione industriale, CPI, occupazione e consumi mostrano trend stocastici e necessitano di differenziazione per la stazionarietà.

2. **La relazione produzione-disoccupazione è la più forte**: sia la CCF che la Granger-causalità e le IRF confermano un legame robusto e negativo, coerente con la legge di Okun.

3. **Il CPI è la variabile più "esogena"**: la FEVD mostra che la varianza del CPI è quasi interamente auto-spiegata, suggerendo che l'inflazione è guidata da fattori esterni al sistema trivariato analizzato (aspettative, costi energetici, offerta di moneta).

4. **Il modello ARIMA univariato è efficace per la previsione a breve termine** della produzione industriale, con residui ben comportati.

5. **Il VAR cattura interdipendenze** che l'ARIMA ignora, ma opera su serie differenziate perdendo l'informazione di lungo periodo.

6. **Il VECM è il modello metodologicamente più appropriato** quando le serie sono I(1) e cointegrate, poiché incorpora sia le dinamiche di breve periodo sia le relazioni di equilibrio di lungo periodo. Tuttavia, la forza della cointegrazione dipende dalla specifica combinazione di variabili: non tutte le combinazioni producono relazioni di lungo periodo statisticamente significative.

## Requisiti

### Software

- **R** ≥ 4.3
- **Quarto** ≥ 1.4

### Pacchetti R

```r
install.packages(c(
  "readxl",     # Lettura file Excel
  "tseries",    # Test ADF, Jarque-Bera
  "forecast",   # ARIMA, auto.arima, diagnostica
  "urca",       # Test di radice unitaria, cointegrazione Johansen
  "vars",       # Modelli VAR, Granger-causalità, IRF, FEVD
  "lmtest",     # Test diagnostici
  "dynlm",      # Modelli dinamici lineari
  "ggplot2",    # Grafici
  "gridExtra"   # Layout grafici multipli
))
```

## Come riprodurre

1. Clonare il repository:
   ```bash
   git clone https://github.com/<username>/progetto-msde.git
   cd progetto-msde
   ```

2. **(Opzionale) Configurare la API key FRED** per riscaricare i dati da zero:
   ```bash
   cp .Renviron.example .Renviron
   ```
   Aprire `.Renviron` e sostituire `inserisci_la_tua_chiave_qui` con la propria API key (ottenibile registrandosi gratuitamente su [fred.stlouisfed.org](https://fred.stlouisfed.org/)). Poi eseguire:
   ```r
   source("Scarica_serie_macro_fred.R")
   ```
   Il file `.Renviron` è nel `.gitignore` e **non verrà mai committato**, quindi la chiave resta privata.

   > **Nota**: il dataset `serie_macro_fred.xlsx` è già incluso nel repository, quindi questo passaggio è necessario solo per aggiornare i dati.

3. Renderizzare il report:
   ```bash
   quarto render progetto_msde.qmd
   ```

   Oppure da RStudio: aprire `progetto_msde.qmd` e premere **Render**.

## Riferimenti

- Bisaglia, L. (2025). *Modelli Statistici per Dati Economici* — Dispense del corso, Università degli Studi di Padova.
- Box, G. E. P., Jenkins, G. M., Reinsel, G. C. & Ljung, G. M. (2015). *Time Series Analysis: Forecasting and Control*, 5th ed. Wiley.
- Hamilton, J. D. (1994). *Time Series Analysis*. Princeton University Press.
- Lütkepohl, H. (2005). *New Introduction to Multiple Time Series Analysis*. Springer.
- Wei, W. W. S. (2006). *Time Series Analysis: Univariate and Multivariate Methods*, 2nd ed. Pearson.

## Licenza

Questo progetto è distribuito a scopo didattico. I dati provengono dal [FRED](https://fred.stlouisfed.org/) (Federal Reserve Bank of St. Louis) e sono di pubblico dominio.

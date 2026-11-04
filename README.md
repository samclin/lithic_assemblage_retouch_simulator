# A Base Model of Lithic Assemblage Accumulation
An interactive Shiny application exploring how preferential selection and reuse of larger artefacts may generate inverse relationships between assemblage size and retouch frequency.

## Background
This model was developed to evaluate whether size-biased flake selection and repeated reuse can produce assemblage retouch-density patterns traditionally attributed to mobility and provisioning behaviour.

## Features
* Alternative artefact selection variables:
  * Weight
  * Maximum length
  * Maximum width
  * Maximum thickness
* Continuous selection strength parameter (k)
* Alternative retouch allocation rules:
  * Fixed proportion
  * Fixed number
* Empirically derived flake production events from experimental reduction datasets

## How to run
### Locally
Shiny::runApp("app.R")

### Online
https://samclin.shinyapps.io/Lithic_retouch_assemblage_simulator/

## Model Summary
The model simulates lithic assemblage accumulation by repeatedly:
 1. Sampling experimentally derived reduction events.
 2. Adding artefacts to an accumulating assemblage.
 3. Selecting artefacts for retouch according to a user-specified selection variable and selection strength.
 4. Returning retouched artefacts to the assemblage, allowing repeated reuse through time.

The application allows users to explore how assumptions about artefact selection and retouch behaviour influence assemblage-level retouch frequencies.

## References
* Lin, S. C. (2018). Flake selection and scraper retouch probability: an alternative model for explaining Middle Paleolithic assemblage retouch variability. _Archaeological and Anthropological Sciences_, 10, 1791–1806.
* Lin, S. C., McPherron, S. P., & Dibble, H. L. (2015). Establishing statistical confidence in Cortex Ratios within and among lithic assemblages. _Journal of Archaeological Science_, 59, 89–109.
* Lin, S. C., Pop, C. M., Dibble, H. L., Archer, W., Desta, D., Weiss, M., & McPherron, S. P. (2016). A core reduction experiment finds no effect of original stone size and reduction intensity on flake debris size distribution. _American Antiquity_, 81, 562–575.

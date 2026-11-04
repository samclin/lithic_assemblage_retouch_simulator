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
 4. Applying any penalty associated with previous retouch.
 5. Retouching selected artefacts and returning them to the accumulating assemblage.
 6. Allowing repeated reuse and modification through time.

The application allows users to explore how assumptions about artefact selection, reuse, and retouch behaviour influence assemblage-level retouch frequencies.

# Version history
## Version 2.0 (current)
Substantial revision of the original model to improve transparency and evaluate the sensitivity of model outcomes to alternative assumptions.

New features
* Alternative artefact selection variables:
  * Weight
  * Maximum length
  * Maximum width
  * Maximum thickness
* Continuous selection strength parameter (k), where:
  * k=0 produces uniform selection
  * k=1 produces linear size-based selection
  * k=2 produces cubic size-based selection
* Retouched artefact penalty parameter governing the probability of selecting previously retouched artefacts.
* Alternative retouch allocation methods:
  * Fixed proportion of flakes produced per event
  * Fixed number of flakes selected per event
* Expanded parameter descriptions and model documentation.
* Full source code made publicaly available.

Changes
* Replaced predefined Uniform, Linear, and Cubic selection functions with a continuous selection strength parameter.
* Included multiple artefact size attributes as selection variable rather than weight alone.
* Revised output metrics to reflect the selected attribute rather than a fixed weight measure.

## Version 1.0
The original model presented at the 2023 annual meeting of the Society for American Archaeology (Portland, OR) and the 2024 Computer Applications and Quantitative Methods in Archaeology meeting (Auckland, NZ).

Original features
* Weight-based artefact selection
* Three fixed selection functions:
  * Uniform
  * Linear
  * Cubic
* Retouch allocation based on a fixed proportion of flakes produced per event. 

# References
* Lin, S. C. (2018). Flake selection and scraper retouch probability: an alternative model for explaining Middle Paleolithic assemblage retouch variability. _Archaeological and Anthropological Sciences_, 10, 1791–1806.
* Lin, S. C., McPherron, S. P., & Dibble, H. L. (2015). Establishing statistical confidence in Cortex Ratios within and among lithic assemblages. _Journal of Archaeological Science_, 59, 89–109.
* Lin, S. C., Pop, C. M., Dibble, H. L., Archer, W., Desta, D., Weiss, M., & McPherron, S. P. (2016). A core reduction experiment finds no effect of original stone size and reduction intensity on flake debris size distribution. _American Antiquity_, 81, 562–575.

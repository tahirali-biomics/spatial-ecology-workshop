
# **Advanced Spatial Ecology and Species Distribution Modeling Workshop**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R Version](https://img.shields.io/badge/R-4.2%2B-blue)](https://www.r-project.org/)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/tahirali-biomics/spatial-ecology-workshop/graphs/commit-activity)

------------------------------------------------------------------------

## **Overview**

This repository contains comprehensive materials for a five-session advanced training workshop integrating spatial sampling theory, biostatistical diagnostics, climate (BioClim) analysis, multivariate statistics, and machine learning approaches for Species Distribution Modeling (SDMs).

The workshop is designed for researchers in ecology, environmental science, conservation biology, and climate modeling who seek rigorous statistical and ecological reasoning combined with reproducible computational workflows in R.

## **Target Audience**

- Bachelor's students
- Master's students
- Early-career scientists
- Conservation practitioners

------------------------------------------------------------------------

## **Format**

- Five sessions (60 minutes each)

- Integrated theory and hands-on R practice

- Emphasis on statistical reasoning and ecological interpretation

- Real-world case study from Pakistan

- Reproducible workflows with version control

------------------------------------------------------------------------

## **Prerequisites**

- Introductory statistics

- Basic familiarity with R (helpful but not required)

- Foundational understanding of ecology or environmental science

------------------------------------------------------------------------

## **Repository Structure**

```
spatial-ecology-workshop/
│
├── README.md                         # Workshop overview and instructions
├── LICENSE                           # MIT License
├── .gitignore                        # Git ignore rules
│
├── sessions/                         # Session-by-session materials
│   ├── 01_spatial_sampling/          # Session 1: Spatial Sampling & Inference
│   │   ├── theory_slides.Rmd
│   │   ├── hands_on.R
│   │   ├── exercises.Rmd
│   │   └── solutions.R
│   ├── 02_data_exploration/          # Session 2: Data Exploration & Normalization
│   ├── 03_collinearity/              # Session 3: Collinearity & Regularization
│   ├── 04_multivariate/              # Session 4: Multivariate Analysis
│   └── 05_sdm/                       # Session 5: Species Distribution Modeling
│
├── data/                             # All workshop data
│   ├── presence/                     # Species occurrence data
│   │   ├── spider_coords.csv
│   │   └── metadata_presence.txt
│   ├── climate/                      # WorldClim bioclimatic data
│   │   ├── wc2.1_2.5m_elev.tif
│   │   ├── wc2.1_2.5m_bio_1.tif
│   │   ├── wc2.1_2.5m_bio_12.tif
│   │   └── ... (all 19 bioclim variables)
│   ├── boundaries/                   # Administrative boundaries
│   │   ├── pakistan_admin.shp
│   │   ├── pakistan_admin.dbf
│   │   ├── pakistan_admin.shx
│   │   └── pakistan_admin.prj
│   ├── infrastructure/               # Anthropogenic features
│   │   ├── roads/
│   │   │   ├── hotosm_pak_roads_lines_shp/
│   │   │   └── karakoram_highway.shp
│   │   └── waterways/
│   │       ├── hotosm_pak_waterways_lines_shp/
│   │       └── indus_river.shp
│   ├── derived/                      # Generated during workshops (gitignored)
│   └── metadata/                     # Data documentation
│       ├── data_sources.csv
│       └── variable_descriptions.txt
│
├── scripts/                           # R scripts for all sessions
│   ├── 00_install_packages.R          # One-time setup
│   ├── 00_colab_setup.R               # Google Colab configuration
│   ├── 01_spatial_sampling_complete.R # Session 1 complete script
│   ├── 02_data_exploration_template.R
│   ├── 03_collinearity_template.R
│   ├── 04_multivariate_template.R
│   ├── 05_sdm_template.R
│   └── functions/                      # Custom helper functions
│       ├── spatial_helpers.R
│       └── plotting_functions.R
│
├── outputs/                           # Generated outputs (gitignored)
│   ├── plots/
│   ├── models/
│   └── reports/
│
├── docs/                               # Documentation
│   ├── workshop_slides/                # Session slides (PDF)
│   ├── student_handout.md              # Pre-workshop setup guide
│   ├── colab_instructions.md           # Google Colab setup
│   └── references.bib                  # Citation references
│
├── colab/                              # Google Colab notebooks
│   ├── session1_colab.ipynb
│   ├── session2_colab.ipynb
│   ├── session3_colab.ipynb
│   ├── session4_colab.ipynb
│   └── session5_colab.ipynb
│
└── tests/                               # Validation scripts
    ├── test_data_integrity.R
    └── test_package_installation.R
```
        
------------------------------------------------------------------------

## **Data Sources**

| **Data Type** | **Source** | **Citation / Reference** |
|:---|:---|:---|
| **Spider presence** | Field collection | Environment Toxicology & Ecology Lab, CEES, Punjab University, Lahore |
| **Climate data** | [WorldClim v2.1](https://worldclim.org/) | Fick, S.E. & Hijmans, R.J. (2017). WorldClim 2: new 1km spatial resolution climate surfaces for global land areas. *International Journal of Climatology*. |
| **Administrative boundaries** | [HDX - Pakistan Admin Boundaries](https://data.humdata.org/dataset/cod-ab-pak) | OCHA (2025). Pakistan - Subnational Administrative Boundaries. Humanitarian Data Exchange. |
| **Road networks** | [HDX - Pakistan Roads](https://data.humdata.org/dataset/hotosm_pak_roads) | HOTOSM (2025). Pakistan Roads. Humanitarian OpenStreetMap Team. |
| **Waterways** | [HDX - Pakistan Waterways](https://data.humdata.org/dataset/hotosm_pak_waterways) | HOTOSM (2025). Pakistan Waterways. Humanitarian OpenStreetMap Team. |
| **Karakoram Highway** | Derived from HDX roads | Simplified feature created for workshop clarity |
| **Indus River** | Derived from HDX waterways | Simplified feature created for workshop clarity |
| **Elevation** | [WorldClim v2.1](https://worldclim.org/) | Fick, S.E. & Hijmans, R.J. (2017). WorldClim 2. |

---

### **Additional Metadata**

Detailed variable descriptions and data processing steps are available in:

- `data/metadata/variable_descriptions.txt`
- `data/metadata/data_sources.csv`
- `docs/references.bib` for BibTeX citations

------------------------------------------------------------------------

## **Workshop Sessions**

### **Session 1 – Spatial Sampling and Ecological Inference**

- Random, systematic, stratified, and transect sampling designs

- Road- and river-associated sampling bias detection

- Spatial autocorrelation (Moran's I)

- Effective sample size estimation

- Ripley's K function and pair correlation analysis

- Script: scripts/01_spatial_sampling_complete.R

### **Session 2 – Data Exploration and Normalization**

- Distribution diagnostics (histograms, Q–Q plots, density plots)

- Transformations (log, Box–Cox, scaling)

- Outlier detection (Isolation Forest)

- Ecological interpretation of transformed variables

- Script: scripts/02_data_exploration_template.R

### **Session 3 – Collinearity and Regularization**

- Correlation matrices and visualization

- Variance Inflation Factor (VIF) analysis

- Ridge regression, LASSO, Elastic Net

- Variable selection strategies for SDMs

- Script: scripts/03_collinearity_template.R

### **Session 4 – Multivariate Analysis and Dimensionality Reduction**

- Principal Component Analysis (PCA)

- Interpretation of loadings in environmental space

- UMAP and t-SNE visualization

- Climate niche space characterization

- Script: scripts/04_multivariate_template.R

### **Session 5 – Species Distribution Modeling**

- Generalized Linear Models (GLM)

- Generalized Additive Models (GAM)

- Random Forest and Boosted Regression Trees

- Regularized modeling (MaxEnt)

- Model comparison and variable importance

- Script: scripts/05_sdm_template.R

------------------------------------------------------------------------

## **Quick Start

**Option A: Local RStudio (Windows/Mac/Linux)**


```
# Clone the repository
git clone https://github.com/tahirali-biomics/spatial-ecology-workshop.git

# Navigate into the directory
cd spatial-ecology-workshop

# Install required packages
Rscript scripts/00_install_packages.R

# Run Session 1
Rscript scripts/01_spatial_sampling_complete.R
```

**Option B: Google Colab (No installation required)**

1. Open Google Colab

2. Click File → Upload notebook

3. Select colab/session1_colab.ipynb from this repository

4. Follow the setup instructions in the notebook

5. All packages will be installed automatically in the cloud

------------------------------------------------------------------------

## **Requirements**

**R Packages**
All required packages will be installed automatically by the setup script:

```
core <- c("sf", "terra", "ggplot2", "dplyr", "viridis")
spatial <- c("spatstat.geom", "spatstat.explore", "spdep", "FNN")
stats <- c("MASS", "glmnet", "randomForest", "gbm", "dismo")
viz <- c("patchwork", "tmap", "corrplot", "pROC")
```

## **System Dependencies**

**For Ubuntu/Debian Linux:**

```
sudo apt-get install libgdal-dev libgeos-dev libproj-dev libudunits2-dev
```

**For macOS:**

```
brew install gdal geos proj udunits
```

**For Windows:**

- No additional system dependencies needed

- R packages will install binary versions automatically

- If using Rtools is required, it will prompt you

**For Google Colab:**

- No system dependencies needed

- Everything runs in the cloud

------------------------------------------------------------------------

## **Student Preparation (Before Session 1)**

1.  **Install R** (version ≥ 4.2) from [CRAN](https://cran.r-project.org/) (not needed for Colab users)

2.  **Install RStudio** (optional but recommended) from [Posit](https://posit.co/download/rstudio-desktop/) (not needed for Colab users)

3.  **Clone the repository** or download the ZIP file

4.  **Run the setup script**:

    r

    ```         
    source("scripts/00_install_packages.R")
    ```

5.  **Test your setup**:

    r

    ```         
    source("scripts/01_spatial_sampling_complete.R")
    ```

6.  **Review documentation** in `docs/student_handout.md`

------------------------------------------------------------------------

## **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

------------------------------------------------------------------------

## **Contact**

**Instructor:** Dr. Tahir Ali | https://tahirali-biomics.github.io  
**Institution:** Molecular Plant Ecology, Institute of Plant Sciences, University of Cologne  
**Email:** tali@uni-koeln.de  
**Repository:** https://github.com/tahirali-biomics/spatial-ecology-workshop

------------------------------------------------------------------------

## **Citation**

If you use these materials in your work or teaching, please cite:

> Ali, T. (2026). Advanced Spatial Ecology and Species Distribution Modeling Workshop. GitHub Repository. <https://github.com/tahirali-biomics/spatial-ecology-workshop>

------------------------------------------------------------------------

## **Acknowledgments**

-   **WorldClim** for providing high-resolution climate data

-   **Humanitarian Data Exchange (HDX)** for spatial infrastructure datasets

-   **Environment Toxicology & Ecology Lab, CEES, Punjab University, Lahore** for species occurrence data

-   **Workshop participants** for valuable feedback and contributions

-   **University of Cologne** for institutional support

------------------------------------------------------------------------

**Happy Modeling!** 🕷️🗺️📊

------------------------------------------------------------------------
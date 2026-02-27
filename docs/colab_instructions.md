# Google Colab Setup Instructions for Workshop Participants

## Overview

Google Colab provides a free, cloud-based R environment that requires no software installation on your computer. This is the recommended option for participants who:

-   Have limited administrative access to their computers

-   Prefer not to install R and RStudio locally

-   Want a consistent environment across all workshop sessions

-   Experience issues with local package installations

## Step-by-Step Setup Guide

**Step 1: Sign in to Google** 1. Go to accounts.google.com

2.  Sign in with your existing Google account, or click "Create account" to make a new one

3.  Note: A Gmail address is not required—any Google account works

**Step 2: Access Google Colab** 1. Open your web browser (Chrome works best, but Firefox and Safari also work)

2.  Navigate to: colab.research.google.com

3.  You should see the Colab welcome screen

**Step 3: Set R as the Default Language** By default, Colab uses Python. To use R:

-   In any Colab notebook, click the Runtime menu

-   Select Change runtime type

-   In the dialog box, set Runtime type to "R"

-   Click Save

-   Alternatively, use the direct link to an R notebook: <https://colab.research.google.com/github/GoogleResearch/R_Colab/blob/master/README.md>

**Step 4: Mount Google Drive (Optional but Recommended)** This step allows you to save your work permanently and avoid reinstalling packages each session:

# Run this code in a Colab cell

```{r}
drive_mount_path \<- "/content/drive"

# Install required package if needed

if (!require(googledrive)) { install.packages("googledrive") library(googledrive) }

# Mount Google Drive

drive_auth()

# Create workshop folder

workshop_path \<- "/content/drive/My Drive/Colab_Notebooks/Spider_Workshop" dir.create(workshop_path, recursive = TRUE, showWarnings = FALSE)

# Set as working directory

setwd(workshop_path)

# Set library path to Drive (so packages persist)

.libPaths(c(workshop_path, .libPaths()))

cat("✓ Google Drive connected and ready!\n") 
cat("✓ Working directory:", getwd(), "\n") 
```

**Step 5: Upload Workshop Materials**
Option A: Upload from Computer (Fastest) 
1. In Colab, click the 📁 folder icon on the left sidebar
2. Click the 📤 upload icon (upward arrow)
3. Select and upload these files/folders:

  - spider_coords.csv

  - pakistan_admin.shp (and associated .dbf, .shx, .prj files)

  - hotosm_pak_roads_lines_shp/ (entire folder)

  - hotosm_pak_waterways_lines_shp/ (entire folder)

  - Any session scripts you need

**Option B: Download from GitHub to Colab**

```{r}
# Clone the workshop repository directly into Colab 
system("git clone <https://github.com/tahirali-biomics/spatial-ecology-workshop.git>")

# Navigate into the folder
setwd("spatial-ecology-workshop")

# List files to confirm
list.files() 

**Step 6: Install Required Packages**

Run this cell once per session (packages will need to be reinstalled each time unless you mounted Drive with custom library path):

```{r}
# List of required packages
packages_needed <- c(
  "sf", "terra", "ggplot2", "dplyr", "viridis",
  "spatstat.geom", "spatstat.explore", "spdep", "FNN",
  "MASS", "glmnet", "randomForest", "gbm", "dismo",
  "patchwork", "tmap", "corrplot", "pROC"
)

# Install packages (this takes 5-8 minutes)
for (pkg in packages_needed) {
  if (!require(pkg, character.only = TRUE)) {
    cat("Installing", pkg, "...\n")
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
  }
}

cat("\n✅ ALL PACKAGES INSTALLED SUCCESSFULLY!\n")
```

**Step 7: Update File Paths in Scripts**
- Important: After uploading files, you must update file paths in the scripts:

```{r}
# Check where your files are located
list.files("/content")

# Update these paths in the scripts (example for Session 1):
spider_file <- "/content/spider_coords.csv"
boundary_file <- "/content/pakistan_admin.shp"
roads_dir <- "/content/hotosm_pak_roads_lines_shp"
rivers_dir <- "/content/hotosm_pak_waterways_lines_shp"

# Verify files exist
cat("Spider data exists:", file.exists(spider_file), "\n")
cat("Boundary exists:", file.exists(boundary_file), "\n")
cat("Roads directory exists:", dir.exists(roads_dir), "\n")
cat("Rivers directory exists:", dir.exists(rivers_dir), "\n")
```

## Daily Workflow

### **Starting a New Session**

```{r}
# 1. Mount Google Drive (if using)
library(googledrive)
drive_auth()

# 2. Set working directory
setwd("/content/drive/My Drive/Colab_Notebooks/Spider_Workshop")

# 3. Set library path (to use previously installed packages)
.libPaths(c(getwd(), .libPaths()))

# 4. Load required libraries for the session
library(sf)
library(ggplot2)
# ... etc.

# 5. Update file paths if needed
spider_file <- "/content/drive/My Drive/Colab_Notebooks/Spider_Workshop/spider_coords.csv"
```

### **Saving Your Work**

```{r}
# Save plots to Google Drive
output_dir <- "/content/drive/My Drive/Colab_Notebooks/Spider_Workshop/outputs"
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

ggsave(file.path(output_dir, "my_plot.png"), width = 10, height = 8)

# Download directly to computer
zip_file <- "/content/results.zip"
files_to_zip <- list.files("/content", pattern = "*.png", full.names = TRUE)
zip(zip_file, files = files_to_zip)
# Then download from file browser (right-click → Download)
```

------------------------------------------------------------------------

## Important Notes

| **Aspect** | **Details** |
|:-----------------------------------|:-----------------------------------|
| **Session duration** | Colab sessions expire after 12 hours of inactivity |
| **Package installation** | Packages must be reinstalled each session unless using Drive mount |
| **File persistence** | Uploaded files remain until runtime is disconnected |
| **Storage limits** | Free tier has \~78 GB disk space, enough for this workshop |
| **Internet required** | Colab runs in the cloud—stable internet connection needed |
| **Cost** | Completely free (with usage limits) |

------------------------------------------------------------------------

## Troubleshooting

### **Problem: Package installation fails**

```{r}
# Try installing with binary version
install.packages("sf", type = "binary")

# Or install without dependencies first
install.packages("sf", dependencies = FALSE)
```

### **Problem: File not found error**

```{r}
# Check current directory
getwd()

# List all files
list.files(recursive = TRUE)

# Check specific file
file.exists("/content/spider_coords.csv")
```

### **Problem: Memory issues**

```{r}
# Clear unused memory
gc()

# Remove large objects
rm(list = c("large_object1", "large_object2"))
```

### **Problem: Session crashes/stalls**

-   Click **Runtime → Restart runtime**

-   Then re-run cells from the beginning

### **Problem: Cannot find uploaded files after restart**

Files must be re-uploaded each session unless saved to Google Drive.

------------------------------------------------------------------------

## ✅ Quick Reference Card

| **Action** | **Command / Instructions** |
|:-----------------------------------|:-----------------------------------|
| Open Colab | [colab.research.google.com](https://colab.research.google.com/) |
| Set R runtime | Runtime → Change runtime type → R |
| Mount Drive | `drive_auth()` then follow prompts |
| Install packages | `install.packages("pkgname")` |
| Upload files | Click 📁 → 📤 → select files |
| Run cell | Click cell → `Shift+Enter` |
| Run all cells | Runtime → Run all |
| Stop execution | Runtime → Interrupt execution |
| Restart runtime | Runtime → Restart runtime |
| Save notebook | File → Save a copy in Drive |
| Download files | Right-click in file browser → Download |

------------------------------------------------------------------------

## 📚 Workshop Session Links

| **Session** | **Colab Notebook**           |
|:------------|:-----------------------------|
| Session 1   | `colab/session1_colab.ipynb` |
| Session 2   | `colab/session2_colab.ipynb` |
| Session 3   | `colab/session3_colab.ipynb` |
| Session 4   | `colab/session4_colab.ipynb` |
| Session 5   | `colab/session5_colab.ipynb` |

------------------------------------------------------------------------

## 📧 Getting Help

If you encounter issues not covered here:

1.  Check the [workshop repository](https://github.com/tahirali-biomics/spatial-ecology-workshop) for updates

2.  Post in the workshop discussion forum

3.  Email the instructor: tali\@uni-koeln.de

------------------------------------------------------------------------

**You're now ready for the workshop!**

------------------------------------------------------------------------

*Last updated: February 2026*

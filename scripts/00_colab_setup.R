# 00_colab_setup.R
# ==============================================================================
# GOOGLE COLAB SETUP SCRIPT: Configure R environment for the workshop
# Run this script at the beginning of EACH Colab session
# ==============================================================================

cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat(" SPATIAL ECOLOGY WORKSHOP - GOOGLE COLAB SETUP\n")
cat(paste(rep("=", 70), collapse = ""), "\n")
cat("This script configures your Google Colab environment for the workshop.\n")
cat("Run this at the BEGINNING of each Colab session.\n")
cat(paste(rep("=", 70), collapse = ""), "\n\n")

# ==============================================================================
# 1. CHECK COLAB ENVIRONMENT
# ==============================================================================
cat("🔍 Checking Colab environment...\n")

# Check if running in Colab
is_colab <- tryCatch({
  library(httr)
  response <- GET("http://172.28.0.2:9000/api/sessions")
  status_code(response) == 200
}, error = function(e) {
  FALSE
})

if (!is_colab) {
  cat("⚠️ Warning: This script is designed for Google Colab.\n")
  cat("   You may be running in a different environment.\n")
  cat("   Some features may not work as expected.\n\n")
} else {
  cat("✅ Google Colab environment detected\n\n")
}

# ==============================================================================
# 2. INSTALL COLAB-SPECIFIC PACKAGES
# ==============================================================================
cat("📦 Installing Colab-specific packages...\n")

colab_packages <- c(
  "googledrive",  # For Google Drive integration
  "httr",         # For HTTP requests
  "jsonlite"      # For JSON parsing
)

for (pkg in colab_packages) {
  if (!require(pkg, character.only = TRUE)) {
    cat("   Installing", pkg, "...")
    install.packages(pkg, quiet = TRUE)
    library(pkg, character.only = TRUE)
    cat(" ✅\n")
  } else {
    cat("   ✅", pkg, "already installed\n")
  }
}
cat("\n")

# ==============================================================================
# 3. MOUNT GOOGLE DRIVE
# ==============================================================================
cat("💾 Google Drive Integration\n")
cat(paste(rep("-", 40), collapse = ""), "\n")

drive_mount <- function() {
  cat("\nOptions:\n")
  cat(" 1. Mount Google Drive (recommended - saves packages and work)\n")
  cat(" 2. Skip mounting (work in temporary storage)\n")
  cat("\nEnter choice (1 or 2): ")
  
  choice <- readline()
  
  if (choice == "1") {
    cat("\n🔄 Mounting Google Drive...\n")
    cat("   You will be prompted to authorize access in a new browser tab.\n")
    cat("   Follow the instructions and return here after authorization.\n\n")
    
    tryCatch({
      library(googledrive)
      drive_auth()
      
      # Create workshop folder in Drive
      workshop_path <- "/content/drive/My Drive/Colab_Notebooks/Spider_Workshop"
      dir.create(workshop_path, recursive = TRUE, showWarnings = FALSE)
      
      # Set as working directory
      setwd(workshop_path)
      
      # Create subdirectories
      dir.create(file.path(workshop_path, "data"), showWarnings = FALSE)
      dir.create(file.path(workshop_path, "outputs"), showWarnings = FALSE)
      dir.create(file.path(workshop_path, "scripts"), showWarnings = FALSE)
      
      # Set library path to Drive (so packages persist)
      drive_lib <- file.path(workshop_path, "r_library")
      dir.create(drive_lib, showWarnings = FALSE)
      .libPaths(c(drive_lib, .libPaths()))
      
      cat("\n✅ Google Drive mounted successfully!\n")
      cat("   📁 Workshop folder:", workshop_path, "\n")
      cat("   📁 R library path:", drive_lib, "\n")
      cat("   📁 Current working directory:", getwd(), "\n")
      
      return(TRUE)
    }, error = function(e) {
      cat("\n❌ Failed to mount Google Drive:", e$message, "\n")
      cat("   Continuing with temporary storage...\n")
      return(FALSE)
    })
  } else {
    cat("\n🔄 Working in temporary Colab storage.\n")
    cat("   Note: Files and packages will NOT persist after session ends.\n")
    cat("   Remember to download important outputs before closing.\n")
    
    # Set up temporary directories
    temp_path <- "/content/spatial_ecology_workshop"
    dir.create(temp_path, showWarnings = FALSE)
    setwd(temp_path)
    
    dir.create(file.path(temp_path, "data"), showWarnings = FALSE)
    dir.create(file.path(temp_path, "outputs"), showWarnings = FALSE)
    
    cat("\n✅ Temporary workspace ready!\n")
    cat("   📁 Working directory:", getwd(), "\n")
    return(FALSE)
  }
}

drive_mounted <- drive_mount()
cat("\n")

# ==============================================================================
# 4. CHECK AND INSTALL WORKSHOP PACKAGES
# ==============================================================================
cat("📦 Workshop Package Installation\n")
cat(paste(rep("-", 40), collapse = ""), "\n")

# Define required packages
required_packages <- c(
  # Core packages
  "sf", "terra", "ggplot2", "dplyr", "viridis",
  
  # Spatial statistics
  "spatstat.geom", "spatstat.explore", "spatstat.model",
  "spdep", "FNN",
  
  # Statistical modeling
  "MASS", "glmnet", "randomForest", "gbm", "dismo",
  
  # Visualization
  "patchwork", "tmap", "corrplot", "pROC"
)

cat("Required packages for workshop:\n")
cat("  ", paste(required_packages, collapse = "\n   "), "\n\n")

# Check which packages are already installed
installed <- installed.packages()
missing_pkgs <- required_packages[!required_packages %in% rownames(installed)]

if (length(missing_pkgs) == 0) {
  cat("✅ All workshop packages are already installed!\n\n")
} else {
  cat("📦 Installing missing packages (", length(missing_pkgs), "):\n", sep = "")
  cat("   ", paste(missing_pkgs, collapse = ", "), "\n\n")
  cat("   This may take 5-10 minutes. Progress dots (.) indicate compilation.\n\n")
  
  # Install missing packages
  for (pkg in missing_pkgs) {
    cat("   Installing", pkg, "...")
    tryCatch({
      install.packages(pkg, dependencies = TRUE, quiet = TRUE)
      cat(" ✅\n")
    }, error = function(e) {
      cat(" ❌\n")
      cat("   Error:", e$message, "\n")
    })
  }
  cat("\n")
}

# Verify all packages load
cat("🔍 Verifying package loading...\n")
failed_pkgs <- c()
for (pkg in required_packages) {
  if (require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("   ✅", pkg, "\n")
  } else {
    cat("   ❌", pkg, "- Failed to load\n")
    failed_pkgs <- c(failed_pkgs, pkg)
  }
}

if (length(failed_pkgs) > 0) {
  cat("\n⚠️ Some packages failed to load:\n")
  cat("   ", paste(failed_pkgs, collapse = ", "), "\n")
  cat("   You may need to install these manually:\n")
  cat("   install.packages(c('", paste(failed_pkgs, collapse = "', '"), "'))\n\n")
} else {
  cat("\n✅ All packages loaded successfully!\n\n")
}

# ==============================================================================
# 5. DOWNLOAD WORKSHOP MATERIALS FROM GITHUB
# ==============================================================================
cat("📂 Workshop Materials\n")
cat(paste(rep("-", 40), collapse = ""), "\n")

download_materials <- function() {
  cat("\nOptions:\n")
  cat(" 1. Download from GitHub (recommended - gets latest version)\n")
  cat(" 2. Upload local files (if you have them on your computer)\n")
  cat(" 3. Skip for now\n")
  cat("\nEnter choice (1, 2, or 3): ")
  
  choice <- readline()
  
  if (choice == "1") {
    cat("\n🔄 Downloading workshop materials from GitHub...\n")
    
    # Clone repository
    if (!dir.exists("spatial-ecology-workshop")) {
      system("git clone https://github.com/tahirali-biomics/spatial-ecology-workshop.git")
    }
    
    # Copy files to current workspace
    file.copy("spatial-ecology-workshop/data", ".", recursive = TRUE)
    file.copy("spatial-ecology-workshop/scripts", ".", recursive = TRUE)
    file.copy("spatial-ecology-workshop/colab", ".", recursive = TRUE)
    
    cat("✅ Workshop materials downloaded!\n")
    cat("   📁 Files in:", getwd(), "\n")
    
  } else if (choice == "2") {
    cat("\n🔄 Please upload your files now:\n")
    cat("   1. Click the 📁 folder icon in the left sidebar\n")
    cat("   2. Click the 📤 upload icon\n")
    cat("   3. Select and upload:\n")
    cat("      - spider_coords.csv\n")
    cat("      - pakistan_admin.shp (and associated files)\n")
    cat("      - hotosm_pak_roads_lines_shp/ folder\n")
    cat("      - hotosm_pak_waterways_lines_shp/ folder\n")
    cat("\n   Press Enter when upload is complete...")
    readline()
    
    cat("✅ Files uploaded\n")
  } else {
    cat("\n⏩ Skipping material download\n")
  }
}

download_materials()
cat("\n")

# ==============================================================================
# 6. CHECK DATA FILES
# ==============================================================================
cat("🔍 Checking data files...\n")
cat(paste(rep("-", 40), collapse = ""), "\n")

required_files <- c(
  "spider_coords.csv",
  "pakistan_admin.shp"
)

missing_files <- c()
for (file in required_files) {
  if (file.exists(file)) {
    file_size <- file.info(file)$size
    cat("   ✅", file, sprintf("(%.1f MB)", file_size/1e6), "\n")
  } else {
    # Check in subdirectories
    if (file.exists(file.path("data", file))) {
      file_size <- file.info(file.path("data", file))$size
      cat("   ✅", file, sprintf("(%.1f MB) [in data/]", file_size/1e6), "\n")
    } else {
      cat("   ❌", file, "- Not found\n")
      missing_files <- c(missing_files, file)
    }
  }
}

# Check directories
if (dir.exists("hotosm_pak_roads_lines_shp")) {
  cat("   ✅ hotosm_pak_roads_lines_shp/ directory\n")
} else if (dir.exists(file.path("data", "hotosm_pak_roads_lines_shp"))) {
  cat("   ✅ hotosm_pak_roads_lines_shp/ [in data/]\n")
} else {
  cat("   ⚠️ hotosm_pak_roads_lines_shp/ - Not found (optional for Session 1)\n")
}

if (dir.exists("hotosm_pak_waterways_lines_shp")) {
  cat("   ✅ hotosm_pak_waterways_lines_shp/ directory\n")
} else if (dir.exists(file.path("data", "hotosm_pak_waterways_lines_shp"))) {
  cat("   ✅ hotosm_pak_waterways_lines_shp/ [in data/]\n")
} else {
  cat("   ⚠️ hotosm_pak_waterways_lines_shp/ - Not found (optional for Session 1)\n")
}

cat("\n")

if (length(missing_files) > 0) {
  cat("⚠️ Missing essential files. You can:\n")
  cat("   • Download from GitHub (option 1 above)\n")
  cat("   • Upload files manually (option 2 above)\n")
  cat("   • Continue and update paths in scripts\n\n")
}

# ==============================================================================
# 7. SET UP FILE PATHS
# ==============================================================================
cat("🔧 Configuring file paths...\n")
cat(paste(rep("-", 40), collapse = ""), "\n")

# Create a paths configuration file
paths_content <- sprintf('
# ==============================================================================
# FILE PATHS CONFIGURATION - Generated by 00_colab_setup.R
# Source this file at the beginning of each session script
# ==============================================================================

# Base paths
workshop_dir <- "%s"
data_dir <- file.path(workshop_dir, "data")
output_dir <- file.path(workshop_dir, "outputs")

# Create output directory if it doesn\'t exist
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# Data files
spider_file <- file.path(data_dir, "spider_coords.csv")
boundary_file <- file.path(data_dir, "pakistan_admin.shp")

# Infrastructure directories
roads_dir <- file.path(data_dir, "hotosm_pak_roads_lines_shp")
rivers_dir <- file.path(data_dir, "hotosm_pak_waterways_lines_shp")

# Check for files in alternate locations
if (!file.exists(spider_file)) {
  if (file.exists("spider_coords.csv")) {
    spider_file <- "spider_coords.csv"
  }
}

if (!file.exists(boundary_file)) {
  if (file.exists("pakistan_admin.shp")) {
    boundary_file <- "pakistan_admin.shp"
  }
}

if (!dir.exists(roads_dir)) {
  if (dir.exists("hotosm_pak_roads_lines_shp")) {
    roads_dir <- "hotosm_pak_roads_lines_shp"
  }
}

if (!dir.exists(rivers_dir)) {
  if (dir.exists("hotosm_pak_waterways_lines_shp")) {
    rivers_dir <- "hotosm_pak_waterways_lines_shp"
  }
}

cat("\n✅ File paths configured\n")
cat("   Spider data:", basename(spider_file), "\n")
cat("   Boundary:", basename(boundary_file), "\n")
cat("   Roads dir:", basename(roads_dir), "\n")
cat("   Rivers dir:", basename(rivers_dir), "\n")
cat("   Output dir:", output_dir, "\n")
', getwd())

writeLines(paths_content, "workshop_paths.R")
cat("✅ Paths configuration saved to: workshop_paths.R\n\n")

# ==============================================================================
# 8. TEST PACKAGE LOADING WITH PATHS
# ==============================================================================
cat("🧪 Testing package loading with path configuration...\n")
cat(paste(rep("-", 40), collapse = ""), "\n")

source("workshop_paths.R")

test_packages <- c("sf", "ggplot2", "dplyr")
for (pkg in test_packages) {
  if (require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("   ✅", pkg, "loaded successfully\n")
  } else {
    cat("   ❌", pkg, "failed to load\n")
  }
}
cat("\n")

# ==============================================================================
# 9. SAVE SESSION INFO
# ==============================================================================
session_info_file <- "colab_session_info.txt"
sink(session_info_file)
cat("SPATIAL ECOLOGY WORKSHOP - COLAB SESSION INFO\n")
cat("==============================================\n\n")
cat("Date:", date(), "\n")
cat("Drive mounted:", drive_mounted, "\n")
cat("Working directory:", getwd(), "\n\n")
cat("R version:\n")
print(R.version)
cat("\n")
cat("Installed packages:\n")
print(sessionInfo()$otherPkgs)
sink()

cat("📁 Session info saved to:", session_info_file, "\n\n")

# ==============================================================================
# 10. FINAL SUMMARY
# ==============================================================================
cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat(" COLAB SETUP COMPLETE\n")
cat(paste(rep("=", 70), collapse = ""), "\n")
cat("\n")
cat("✅ Environment configured successfully!\n")
cat("\n")
cat("📋 Next steps:\n")
cat("   1. Source the paths file at the beginning of each script:\n")
cat("      source('workshop_paths.R')\n")
cat("\n")
cat("   2. Run Session 1 test:\n")
cat("      source('scripts/01_spatial_sampling_complete.R')\n")
cat("\n")
cat("   3. For subsequent sessions, simply run:\n")
cat("      source('workshop_paths.R')\n")
cat("      source('scripts/0X_session_script.R')\n")
cat("\n")
cat("📁 Important files:\n")
cat("   • workshop_paths.R - File path configuration\n")
cat("   • colab_session_info.txt - Session information\n")
cat("   • outputs/ - Your plots and results\n")
cat("\n")
if (drive_mounted) {
  cat("💾 Your work is saved to Google Drive and will persist\n")
} else {
  cat("⚠️ Working in temporary storage. Download important files!\n")
  cat("   Use the file browser (📁) to download outputs before closing.\n")
}
cat("\n")
cat("Happy modeling! 🕷️🗺️📊\n")
cat(paste(rep("=", 70), collapse = ""), "\n")

# ==============================================================================
# 11. OPTIONAL: CLEANUP
# ==============================================================================
# Remove temporary objects
rm(list = c("pkg", "installed", "missing_pkgs", "failed_pkgs",
            "required_files", "missing_files", "paths_content",
            "choice", "drive_mounted", "i", "file", "test_packages"))
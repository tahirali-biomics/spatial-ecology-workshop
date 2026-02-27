# ==============================================================================
# ONE-TIME SETUP SCRIPT: Install all required packages for the workshop
# Run this script ONCE before Session 1
# 00_install_packages.R
# ==============================================================================
cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat(" SPATIAL ECOLOGY WORKSHOP - PACKAGE INSTALLATION\n")
cat(paste(rep("=", 70), collapse = ""), "\n")
cat("This script will install all R packages needed for the 5-session workshop.\n")
cat("Installation may take 5-15 minutes depending on your internet speed.\n")
cat(paste(rep("=", 70), collapse = ""), "\n\n")

# ==============================================================================
# 1. SET OPTIONS
# ==============================================================================
# Set CRAN mirror (choose the one closest to you)
options(repos = c(CRAN = "https://cran.rstudio.com/"))

# Increase timeout for downloading large packages
options(timeout = 300)

# ==============================================================================
# 2. FUNCTION TO INSTALL PACKAGES SAFELY
# ==============================================================================
install_if_missing <- function(pkg, dependencies = TRUE) {
if (!require(pkg, character.only = TRUE)) {
cat("\n📦 Installing:", pkg, "...\n")
tryCatch({
install.packages(pkg, dependencies = dependencies)
if (require(pkg, character.only = TRUE)) {
cat("✅", pkg, "installed successfully!\n")
return(TRUE)
} else {
cat("❌ Failed to load", pkg, "after installation\n")
return(FALSE)
}
}, error = function(e) {
cat("❌ Error installing", pkg, ":", e$message, "\n")
return(FALSE)
})
} else {
cat("✅", pkg, "already installed\n")
return(TRUE)
}
}

# ==============================================================================
# 3. DEFINE PACKAGE GROUPS
# ==============================================================================
cat("\n", paste(rep("-", 70), collapse = ""), "\n")
cat("DEFINING PACKAGE GROUPS\n")
cat(paste(rep("-", 70), collapse = ""), "\n")

# Core data manipulation and visualization
core_packages <- c(
"sf", # Spatial data handling
"terra", # Raster data handling
"ggplot2", # Plotting
"dplyr", # Data manipulation
"viridis" # Color scales
)

# Spatial statistics packages
spatial_packages <- c(
"spatstat.geom", # Spatial point patterns
"spatstat.explore", # Exploratory spatial stats
"spatstat.model", # Spatial point process models
"spdep", # Spatial dependence
"FNN" # Fast nearest neighbor
)

# Statistical modeling packages
stats_packages <- c(
"MASS", # Modern Applied Statistics with S
"glmnet", # LASSO and elastic net
"randomForest", # Random Forest
"gbm", # Boosted regression trees
"dismo" # Species distribution modeling
)

# Visualization and reporting packages
viz_packages <- c(
"patchwork", # Combining plots
"tmap", # Thematic maps
"corrplot", # Correlation plots
"pROC" # ROC curves for model evaluation
)

# Additional utilities
utils_packages <- c(
"knitr", # Report generation
"rmarkdown", # Markdown documents
"googledrive" # Google Drive integration (for Colab users)
)

# Combine all packages
all_packages <- unique(c(
core_packages,
spatial_packages,
stats_packages,
viz_packages,
utils_packages
))

cat("Total packages to install:", length(all_packages), "\n")
cat("Package groups:\n")
cat(" • Core:", paste(core_packages, collapse = ", "), "\n")
cat(" • Spatial:", paste(spatial_packages, collapse = ", "), "\n")
cat(" • Statistical:", paste(stats_packages, collapse = ", "), "\n")
cat(" • Visualization:", paste(viz_packages, collapse = ", "), "\n")
cat(" • Utilities:", paste(utils_packages, collapse = ", "), "\n")

# ==============================================================================
# 4. INSTALL PACKAGES
# ==============================================================================
cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat("INSTALLING PACKAGES\n")
cat(paste(rep("=", 70), collapse = ""), "\n")
cat("This may take 5-15 minutes. Progress dots (.) indicate compilation.\n\n")

# Track installation results
results <- data.frame(
package = all_packages,
status = NA,
time = NA
)

# Install each package
for (i in seq_along(all_packages)) {
pkg <- all_packages[i]
start_time <- Sys.time()

success <- install_if_missing(pkg)

end_time <- Sys.time()
elapsed <- round(difftime(end_time, start_time, units = "secs"), 1)

results$status[i] <- ifelse(success, "SUCCESS", "FAILED")
results$time[i] <- paste(elapsed, "s")
}

# ==============================================================================
# 5. VERIFY INSTALLATIONS
# ==============================================================================
cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat("VERIFYING INSTALLATIONS\n")
cat(paste(rep("=", 70), collapse = ""), "\n")

verification <- data.frame(
package = all_packages,
loaded = NA
)

for (i in seq_along(all_packages)) {
pkg <- all_packages[i]
verification$loaded[i] <- require(pkg, character.only = TRUE, quietly = TRUE)
}

# ==============================================================================
# 6. DISPLAY RESULTS
# ==============================================================================
cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat("INSTALLATION SUMMARY\n")
cat(paste(rep("=", 70), collapse = ""), "\n\n")

# Successfully installed
success_pkgs <- verification$package[verification$loaded]
failed_pkgs <- verification$package[!verification$loaded]

cat("✅ Successfully installed (", length(success_pkgs), "):\n", sep = "")
if (length(success_pkgs) > 0) {
cat(" ", paste(success_pkgs, collapse = ", "), "\n\n")
} else {
cat(" None\n\n")
}

if (length(failed_pkgs) > 0) {
cat("❌ Failed to install (", length(failed_pkgs), "):\n", sep = "")
cat(" ", paste(failed_pkgs, collapse = ", "), "\n\n")

cat("Troubleshooting failed packages:\n")
for (pkg in failed_pkgs) {
cat(" • ", pkg, ": Try installing manually with:\n")
cat(" install.packages('", pkg, "', dependencies = TRUE)\n", sep = "")
}
} else {
cat("🎉 ALL PACKAGES INSTALLED SUCCESSFULLY!\n")
}

# ==============================================================================
# 7. SYSTEM DEPENDENCY CHECK (for sf package)
# ==============================================================================
cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat("SYSTEM DEPENDENCY CHECK\n")
cat(paste(rep("=", 70), collapse = ""), "\n")

if (require(sf, quietly = TRUE)) {
cat("✅ sf package loaded successfully\n")
cat(" GDAL version:", sf::gdal_version(), "\n")
cat(" GEOS version:", sf::geos_version(), "\n")
cat(" PROJ version:", sf::proj_version(), "\n")
} else {
cat("⚠️ sf package not loaded. You may need system dependencies:\n")
cat("\n")
cat(" For Ubuntu/Debian:\n")
cat(" sudo apt-get install libgdal-dev libgeos-dev libproj-dev libudunits2-dev\n")
cat("\n")
cat(" For macOS:\n")
cat(" brew install gdal geos proj udunits\n")
cat("\n")
cat(" For Windows:\n")
cat(" No additional dependencies needed - binary packages should work\n")
cat("\n")
cat(" For Google Colab:\n")
cat(" No action needed - system dependencies are pre-installed\n")
}

# ==============================================================================
# 8. SAVE PACKAGE LIST FOR FUTURE REFERENCE
# ==============================================================================
# Save package versions to file
pkg_versions <- data.frame(
package = success_pkgs,
version = sapply(success_pkgs, function(p) as.character(packageVersion(p)))
)

write.csv(pkg_versions, "workshop_package_versions.csv", row.names = FALSE)
cat("\n📁 Package versions saved to: workshop_package_versions.csv\n")

# ==============================================================================
# 9. FINAL MESSAGE
# ==============================================================================
cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat(" SETUP COMPLETE\n")
cat(paste(rep("=", 70), collapse = ""), "\n")
cat("\n")
cat("Next steps:\n")
cat("1. If any packages failed, try installing them manually\n")
cat("2. Test your setup with Session 1 script:\n")
cat(" source('scripts/01_spatial_sampling_complete.R')\n")
cat("\n")
cat("For Google Colab users:\n")
cat("• Run this script once per session, or mount Google Drive\n")
cat("• See docs/colab_instructions.md for detailed guidance\n")
cat("\n")
cat("Happy modeling! 🕷️🗺️📊\n")
cat(paste(rep("=", 70), collapse = ""), "\n")

# ==============================================================================
# 10. OPTIONAL: CREATE SESSION INFO FILE
# ==============================================================================
sink("workshop_session_info.txt")
cat("SPATIAL ECOLOGY WORKSHOP - SESSION INFO\n")
cat("========================================\n\n")
cat("Date:", date(), "\n\n")
cat("R version:\n")
print(R.version)
cat("\n")
cat("Platform:", sessionInfo()$platform, "\n")
cat("\n")
cat("Installed packages:\n")
print(sessionInfo()$otherPkgs)
sink()

cat("\n📁 Session info saved to: workshop_session_info.txt\n")
# ==============================================================================
# SESSION 1: SPATIAL ECOLOGY OF SPIDER WEBS IN PAKISTAN
# ==============================================================================
# This script performs spatial analysis of spider web distribution in Pakistan,
# including sampling bias detection, point pattern analysis, and visualization.
# 
# BEFORE RUNNING: You MUST update all file paths to match YOUR local directory structure
# ==============================================================================

# Instructions for Modifying File Paths:

# Step 1: Set Base Directory (Recommended)
# Find this section near the top of the script and change the path:
base_dir <- "/Users/tahirali/Desktop/Workshop_Pakistan/Hands-On-Session-dataset"
# Change to: base_dir <- "/Your/Actual/Path/To/Data"

# Step 2: Set Output Directory
# Find this section near the end of the script and change the path:
output_dir <- "/Users/tahirali/Desktop/Workshop_Pakistan/Output_Plots"
# Change to: output_dir <- "/Your/Desired/Output/Path"

# Step 3: Check All Paths at Once
# Run this diagnostic code at the beginning:
cat("Current working directory:", getwd(), "\n")
cat("Does base_dir exist?", dir.exists(base_dir), "\n")
cat("Spider file exists?", file.exists(file.path(base_dir, "spider_coords.csv")), "\n")


# ==============================================================================
# SECTION A: SETUP & DATA LOADING
# ==============================================================================
cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat(" SECTION A: LIBRARIES & DATA LOADING\n")
cat(paste(rep("=", 70), collapse = ""), "\n")

# Load required libraries
library(sf)                 # For handling spatial vector data
library(ggplot2)            # For visualization
library(dplyr)              # For data manipulation
library(viridis)            # For color scales
library(spatstat.geom)      # For point pattern objects
library(spatstat.model)     # For point pattern modeling
library(spatstat.explore)   # For point pattern exploration
library(spdep)              # For spatial dependence
library(patchwork)          # For combining plots
library(MASS)               # For kernel density estimation
library(tmap)               # For thematic maps
library(FNN)                # For fast nearest neighbor search

# ------------------------------------------------------------------------------
# IMPORTANT: FILE PATH CONFIGURATION
# ------------------------------------------------------------------------------
# MODIFY THESE PATHS to point to your local data directory
# The default paths assume a specific structure - change them to match YOUR setup

# Option 1: Set a base directory variable (RECOMMENDED)
# Uncomment and modify this line to point to YOUR data folder:
# base_dir <- "/Users/YourUsername/Path/To/Workshop_Pakistan/Hands-On-Session-dataset"

# Option 2: If you're running this script from within the project directory,
# you can use relative paths:
# base_dir <- "."

# Option 3: Manual path specification (simplest for testing)
# Replace the path below with YOUR actual path:
base_dir <- "/Users/tahirali/Desktop/Workshop_Pakistan/Hands-On-Session-dataset"

# Verify the directory exists
if(!dir.exists(base_dir)) {
  stop("ERROR: Directory not found at: ", base_dir, "\n",
       "Please update 'base_dir' variable to point to your data folder.")
}

cat("✓ Using data directory:", base_dir, "\n")

# ------------------------------------------------------------------------------
# Load spider presence data
# ------------------------------------------------------------------------------
spider_file <- file.path(base_dir, "spider_coords.csv")
if(!file.exists(spider_file)) stop("Spider data not found at: ", spider_file)

spiders <- read.csv2(spider_file, header = TRUE)
spiders$X <- as.numeric(gsub(",", ".", spiders$X))
spiders$Y <- as.numeric(gsub(",", ".", spiders$Y))
spiders <- distinct(spiders)
cat("✓ Spider data loaded:", nrow(spiders), "unique records\n")

# ------------------------------------------------------------------------------
# Load Pakistan boundary
# ------------------------------------------------------------------------------
boundary_file <- file.path(base_dir, "pakistan_admin.shp")
if(!file.exists(boundary_file)) stop("Boundary file not found at: ", boundary_file)

pakistan_boundary <- st_read(boundary_file, quiet = TRUE)
cat("✓ Pakistan boundary loaded\n")

# ------------------------------------------------------------------------------
# Load roads data
# ------------------------------------------------------------------------------
roads_dir <- file.path(base_dir, "hotosm_pak_roads_lines_shp")
roads_shp <- file.path(roads_dir, "hotosm_pak_roads_lines_shp.shp")
if(!file.exists(roads_shp)) stop("Roads data not found at: ", roads_shp)

roads <- st_read(roads_shp, quiet = TRUE)
cat("✓ Roads loaded:", nrow(roads), "features\n")

# ------------------------------------------------------------------------------
# Load waterways data
# ------------------------------------------------------------------------------
rivers_dir <- file.path(base_dir, "hotosm_pak_waterways_lines_shp")
rivers_shp <- file.path(rivers_dir, "hotosm_pak_waterways_lines_shp.shp")
if(!file.exists(rivers_shp)) stop("Waterways data not found at: ", rivers_shp)

rivers <- st_read(rivers_shp, quiet = TRUE)
cat("✓ Waterways loaded:", nrow(rivers), "features\n")

# ==============================================================================
# SECTION B: SPATIAL PROJECTION & COORDINATE TRANSFORMATION
# ==============================================================================
# Why: All spatial analyses require consistent coordinate reference systems.
# We transform from WGS84 (lat/lon) to UTM Zone 43N (meters) which is appropriate
# for Pakistan and allows distance calculations in meaningful units.
# ==============================================================================
cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat(" SECTION B: PROJECTION TO UTM (ZONE 43N)\n")
cat(paste(rep("=", 70), collapse = ""), "\n")

# Transform spider points from WGS84 to UTM 43N
spiders_sf <- st_as_sf(spiders, coords = c("X", "Y"), crs = 4326)
spiders_utm <- st_transform(spiders_sf, 32643)

# Transform all other spatial layers to match
pakistan_utm <- st_transform(pakistan_boundary, 32643)
roads_utm <- st_transform(roads, 32643)
rivers_utm <- st_transform(rivers, 32643)

# Extract coordinates as numeric columns for easier manipulation
coords <- st_coordinates(spiders_utm)
spiders$x <- coords[,1]
spiders$y <- coords[,2]

cat("✓ All data transformed to UTM 43N (units: meters)\n")
cat("  • Spider points: UTM X range:", round(range(spiders$x)/1000, 1), "km\n")
cat("  • Spider points: UTM Y range:", round(range(spiders$y)/1000, 1), "km\n")

# ==============================================================================
# SECTION C: VISUAL DISPLAY - BASE MAPS
# ==============================================================================
# Why: Initial visualization helps understand data distribution, identify
# potential issues, and provides context for subsequent analyses.
# ==============================================================================
cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat(" SECTION C: BASE VISUALIZATIONS\n")
cat(paste(rep("=", 70), collapse = ""), "\n")

# Get bounding box of spider points for zoomed views
spider_bbox <- st_bbox(spiders_utm)
x_range <- spider_bbox$xmax - spider_bbox$xmin
y_range <- spider_bbox$ymax - spider_bbox$ymin

# ------------------------------------------------------------------------------
# Plot 1: Full Pakistan view
# ------------------------------------------------------------------------------
p_pakistan <- ggplot() +
  geom_sf(data = pakistan_utm, fill = "gray90", color = "black", size = 0.5) +
  geom_sf(data = roads_utm, color = "red", size = 0.2, alpha = 0.3) +
  geom_sf(data = rivers_utm, color = "blue", size = 0.2, alpha = 0.3) +
  geom_sf(data = spiders_utm, color = "darkgreen", size = 1.5, alpha = 0.8) +
  labs(title = "Spider Web Distribution - Pakistan",
       subtitle = "Red = Roads, Blue = Waterways, Green = Spider webs",
       x = "Longitude", y = "Latitude") +
  theme_minimal()
print(p_pakistan)

# ------------------------------------------------------------------------------
# Plot 2: Decluttered view (10% sample of roads/rivers)
# Why: Full networks can overwhelm the visualization; sampling reduces clutter
# ------------------------------------------------------------------------------
set.seed(123)  # For reproducibility
roads_sample <- roads_utm[sample(1:nrow(roads_utm), size = floor(nrow(roads_utm) * 0.1)), ]
rivers_sample <- rivers_utm[sample(1:nrow(rivers_utm), size = floor(nrow(rivers_utm) * 0.1)), ]

p_declutter <- ggplot() +
  geom_sf(data = pakistan_utm, fill = "gray95", color = "black", size = 0.5) +
  geom_sf(data = roads_sample, color = "red", size = 0.15, alpha = 0.25) +
  geom_sf(data = rivers_sample, color = "blue", size = 0.15, alpha = 0.25) +
  geom_sf(data = spiders_utm, color = "darkgreen", size = 2, alpha = 0.8) +
  labs(title = "Spider Web Distribution - Decluttered View",
       subtitle = "Red = Roads (10% sample), Blue = Waterways (10% sample)",
       x = "Longitude", y = "Latitude") +
  theme_minimal()
print(p_declutter)

# ------------------------------------------------------------------------------
# Plot 3: Zoomed view of spider occurrence region (Punjab)
# Why: Focusing on the area with actual observations reveals local patterns
# ------------------------------------------------------------------------------
p_punjab <- ggplot() +
  geom_sf(data = pakistan_utm, fill = "gray90", color = "black", size = 0.5) +
  geom_sf(data = roads_utm, color = "red", size = 0.3, alpha = 0.4) +
  geom_sf(data = rivers_utm, color = "blue", size = 0.3, alpha = 0.4) +
  geom_sf(data = spiders_utm, color = "darkgreen", size = 2.5, alpha = 0.9) +
  coord_sf(xlim = c(spider_bbox[1] - x_range*0.1, spider_bbox[3] + x_range*0.1),
           ylim = c(spider_bbox[2] - y_range*0.1, spider_bbox[4] + y_range*0.1)) +
  labs(title = "Spider Web Distribution - Punjab Region",
       subtitle = "Zoomed view of spider occurrence area",
       x = "Longitude", y = "Latitude") +
  theme_minimal()
print(p_punjab)

# ==============================================================================
# SECTION D: OPTIMIZED SAMPLING BIAS ANALYSIS
# ==============================================================================
# Why: Sampling near roads and rivers can bias ecological inference.
# We test whether spider webs are systematically closer to infrastructure
# than random points, indicating sampling bias or true habitat preference.
# ==============================================================================
cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat(" SECTION D: OPTIMIZED SAMPLING BIAS DETECTION\n")
cat(paste(rep("=", 70), collapse = ""), "\n")

# ------------------------------------------------------------------------------
# Step 1: Define study region with buffer
# ------------------------------------------------------------------------------
study_buffer <- 20000  # 20km buffer around spider points
xmin_buffer <- spider_bbox$xmin - study_buffer
xmax_buffer <- spider_bbox$xmax + study_buffer
ymin_buffer <- spider_bbox$ymin - study_buffer
ymax_buffer <- spider_bbox$ymax + study_buffer

cat("Study region size:", round((xmax_buffer - xmin_buffer)/1000, 1), "km x",
    round((ymax_buffer - ymin_buffer)/1000, 1), "km\n")

# Create polygon for study region
study_polygon <- st_polygon(list(matrix(c(
  xmin_buffer, ymin_buffer,
  xmax_buffer, ymin_buffer,
  xmax_buffer, ymax_buffer,
  xmin_buffer, ymax_buffer,
  xmin_buffer, ymin_buffer
), ncol = 2, byrow = TRUE)))
study_region_sfc <- st_sfc(study_polygon, crs = st_crs(spiders_utm))

# ------------------------------------------------------------------------------
# Step 2: Crop features to study region (reduces computation)
# ------------------------------------------------------------------------------
crop_features <- function(features, region, feature_name) {
  cat(paste("  Cropping", feature_name, "..."))
  indices <- st_intersects(region, features)[[1]]
  if(length(indices) > 0) {
    cropped <- features[indices, ]
    cat(" kept", nrow(cropped), "features (",
        round(100 * nrow(cropped) / nrow(features), 1), "% of total)\n")
    return(cropped)
  } else {
    cat(" WARNING: No features found!\n")
    return(features[0,])
  }
}

roads_cropped <- crop_features(roads_utm, study_region_sfc, "roads")
rivers_cropped <- crop_features(rivers_utm, study_region_sfc, "rivers")

# ------------------------------------------------------------------------------
# Step 3: Extract coordinates for nearest neighbor search
# ------------------------------------------------------------------------------
extract_coords <- function(sf_object) {
  coords <- st_coordinates(sf_object)
  return(coords[, 1:2, drop = FALSE])
}

cat("  Extracting road coordinates...")
road_coords <- extract_coords(roads_cropped)
cat(" done (", nrow(road_coords), "points)\n")

cat("  Extracting river coordinates...")
river_coords <- extract_coords(rivers_cropped)
cat(" done (", nrow(river_coords), "points)\n")

presence_coords <- st_coordinates(spiders_utm)

# ------------------------------------------------------------------------------
# Step 4: Calculate distances using fast nearest neighbor search
# ------------------------------------------------------------------------------
cat("  Finding nearest roads...")
road_nn <- get.knnx(road_coords, presence_coords, k = 1)
spiders$dist_to_road_km <- road_nn$nn.dist[,1] / 1000
cat(" done\n")

cat("  Finding nearest rivers...")
river_nn <- get.knnx(river_coords, presence_coords, k = 1)
spiders$dist_to_river_km <- river_nn$nn.dist[,1] / 1000
cat(" done\n")

# ------------------------------------------------------------------------------
# Step 5: Generate random points for comparison
# ------------------------------------------------------------------------------
cat("\n5. Generating random points WITHIN SPIDER EXTENT...\n")
n_random <- 1000
set.seed(456)

random_coords <- data.frame(
  x = runif(n_random, spider_bbox$xmin, spider_bbox$xmax),
  y = runif(n_random, spider_bbox$ymin, spider_bbox$ymax)
)

# ------------------------------------------------------------------------------
# Step 6: Calculate distances for random points
# ------------------------------------------------------------------------------
cat("\n6. Calculating distances for random points...\n")
random_matrix <- as.matrix(random_coords)

cat("  Finding nearest roads...")
random_road_nn <- get.knnx(road_coords, random_matrix, k = 1)
random_coords$dist_to_road_km <- random_road_nn$nn.dist[,1] / 1000
cat(" done\n")

cat("  Finding nearest rivers...")
random_river_nn <- get.knnx(river_coords, random_matrix, k = 1)
random_coords$dist_to_river_km <- random_river_nn$nn.dist[,1] / 1000
cat(" done\n")

random_coords$type <- "random"

# ------------------------------------------------------------------------------
# Step 7: Statistical testing
# ------------------------------------------------------------------------------
cat("\n7. Running statistical tests...\n")
spiders$type <- "observed"

# Remove extreme outliers for fair comparison
spiders_clean <- spiders[spiders$dist_to_road_km < 100 & spiders$dist_to_river_km < 100, ]
random_clean <- random_coords[random_coords$dist_to_road_km < 100 & random_coords$dist_to_river_km < 100, ]

cat("  Removed", nrow(spiders) - nrow(spiders_clean), "outliers from observed\n")
cat("  Removed", nrow(random_coords) - nrow(random_clean), "outliers from random\n")

# Kolmogorov-Smirnov test for distribution differences
ks_road <- ks.test(spiders_clean$dist_to_road_km, random_clean$dist_to_road_km)
ks_river <- ks.test(spiders_clean$dist_to_river_km, random_clean$dist_to_river_km)

cat("\nRESULTS:\n")
cat(sprintf("  Roads KS test: D = %.3f, p = %.4f %s\n",
            ks_road$statistic, ks_road$p.value,
            ifelse(ks_road$p.value < 0.05, "★ BIAS DETECTED", "")))
cat(sprintf("  Rivers KS test: D = %.3f, p = %.4f %s\n",
            ks_river$statistic, ks_river$p.value,
            ifelse(ks_river$p.value < 0.05, "★ BIAS DETECTED", "")))

# ------------------------------------------------------------------------------
# Step 8: Visualize bias results
# ------------------------------------------------------------------------------
cat("\n8. Creating enhanced visualizations...\n")

# Combine data for plotting
bias_df <- rbind(
  data.frame(dist = spiders_clean$dist_to_road_km, type = spiders_clean$type, feature = "Roads"),
  data.frame(dist = random_clean$dist_to_road_km, type = random_clean$type, feature = "Roads"),
  data.frame(dist = spiders_clean$dist_to_river_km, type = spiders_clean$type, feature = "Rivers"),
  data.frame(dist = random_clean$dist_to_river_km, type = random_clean$type, feature = "Rivers")
)

# Density plot comparison
p_bias <- ggplot(bias_df, aes(x = dist, fill = type)) +
  geom_density(alpha = 0.6) +
  facet_wrap(~feature, scales = "free") +
  scale_fill_manual(values = c("observed" = "#E69F00", "random" = "#56B4E9")) +
  coord_cartesian(xlim = c(0, 30)) +
  labs(title = "Sampling Bias Detection",
       subtitle = sprintf("Roads: p=%.4f %s | Rivers: p=%.4f %s",
                          ks_road$p.value, ifelse(ks_road$p.value < 0.05, "★", ""),
                          ks_river$p.value, ifelse(ks_river$p.value < 0.05, "★", "")),
       x = "Distance (km)", y = "Density") +
  theme_minimal(base_size = 14) +
  theme(legend.position = "bottom",
        strip.text = element_text(face = "bold", size = 12))
print(p_bias)

# Boxplot comparison
p_bias_box <- ggplot(bias_df, aes(x = feature, y = dist, fill = type)) +
  geom_boxplot(alpha = 0.7, outlier.size = 0.5, outlier.alpha = 0.3) +
  scale_fill_manual(values = c("observed" = "#E69F00", "random" = "#56B4E9")) +
  coord_cartesian(ylim = c(0, 30)) +
  labs(title = "Distance Distribution Comparison",
       subtitle = "Zoomed to 0-30km (outliers >30km hidden)",
       x = "", y = "Distance (km)") +
  theme_minimal(base_size = 14) +
  theme(legend.position = "bottom")
print(p_bias_box)

# ==============================================================================
# SECTION E: DENSITY ANALYSIS & VISUALIZATION
# ==============================================================================
# Why: Kernel density estimation reveals hotspots of spider web occurrence
# and helps visualize spatial patterns across the landscape.
# ==============================================================================
cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat(" SECTION E: KERNEL DENSITY ESTIMATION\n")
cat(paste(rep("=", 70), collapse = ""), "\n")

# 2D kernel density estimation
kde <- kde2d(spiders$x, spiders$y, n = 100,
             lims = c(xmin_buffer, xmax_buffer, ymin_buffer, ymax_buffer))

# Convert to dataframe for ggplot
kde_df <- expand.grid(x = kde$x, y = kde$y)
kde_df$z <- as.vector(kde$z)

# Full density map with all infrastructure
p_density_full <- ggplot() +
  geom_contour_filled(data = kde_df, aes(x = x, y = y, z = z), alpha = 0.7) +
  geom_sf(data = roads_utm, color = "red", size = 0.2, alpha = 0.3) +
  geom_sf(data = rivers_utm, color = "blue", size = 0.2, alpha = 0.3) +
  geom_point(data = spiders, aes(x = x, y = y), color = "white", size = 0.5, alpha = 0.5) +
  coord_sf(xlim = c(xmin_buffer, xmax_buffer), ylim = c(ymin_buffer, ymax_buffer)) +
  scale_fill_viridis_d(name = "Density", option = "plasma") +
  labs(title = "Spider Web Density - Punjab Region",
       subtitle = "Full roads & waterways network",
       x = "Longitude", y = "Latitude") +
  theme_minimal() +
  theme(legend.position = "bottom")
print(p_density_full)

# Enhanced density map with transparency for low-density areas
cat("\n--- ENHANCING VISUALIZATION: 10% FEATURE SAMPLE + TRANSPARENT LOW DENSITY ---\n")

breaks <- seq(min(kde_df$z), max(kde_df$z), length.out = 11)
custom_colors <- c("#FFFFFF00", rev(viridis(9, option = "plasma")))

p_density_enhanced <- ggplot() +
  geom_contour_filled(data = kde_df, aes(x = x, y = y, z = z),
                      breaks = breaks, alpha = 0.85) +
  scale_fill_manual(name = "Density", values = custom_colors, drop = FALSE,
                    guide = guide_legend(reverse = TRUE)) +
  geom_sf(data = roads_sample, color = "red", size = 0.15, alpha = 0.25) +
  geom_sf(data = rivers_sample, color = "blue", size = 0.15, alpha = 0.25) +
  geom_point(data = spiders, aes(x = x, y = y), color = "white", size = 0.6, alpha = 0.6) +
  coord_sf(xlim = c(xmin_buffer, xmax_buffer), ylim = c(ymin_buffer, ymax_buffer)) +
  labs(title = "Enhanced Spider Web Density",
       subtitle = "10% feature sample | Transparent low-density areas",
       x = "Longitude", y = "Latitude") +
  theme_minimal(base_size = 14) +
  theme(legend.position = "bottom", legend.key.width = unit(1.5, "cm"))
print(p_density_enhanced)

# ==============================================================================
# SECTION F: POINT PATTERN ANALYSIS - FIXED
# ==============================================================================
# Why: Point pattern analysis quantifies spatial structure (clustering/regularity)
# and identifies the scale at which patterns occur.
# ==============================================================================
cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat(" SECTION F: POINT PATTERN ANALYSIS\n")
cat(paste(rep("=", 70), collapse = ""), "\n")

# Create spatstat point pattern object
win <- owin(xrange = range(spiders$x), yrange = range(spiders$y))
pp <- ppp(spiders$x, spiders$y, window = win)

# ------------------------------------------------------------------------------
# Clark-Evans test (nearest neighbor ratio)
# R < 1 indicates clustering, R > 1 indicates regularity
# ------------------------------------------------------------------------------
clark_result <- clarkevans.test(pp, alternative = "clustered")
cat("\nCLARK-EVANS TEST:\n")
cat("  R =", round(clark_result$statistic, 3),
    "→", ifelse(clark_result$statistic < 1, "CLUSTERED", "RANDOM/REGULAR"), "\n")
cat("  p =", format.pval(clark_result$p.value, digits = 3), "\n")

# ------------------------------------------------------------------------------
# Ripley's K function (cumulative clustering at increasing distances)
# ------------------------------------------------------------------------------
max_r <- 20000  # 20km maximum distance
K_env <- envelope(pp, Kest, nsim = 199, r = seq(0, max_r, length.out = 50))
K_df <- data.frame(r = K_env$r/1000, obs = K_env$obs, theo = K_env$theo,
                   lo = K_env$lo, hi = K_env$hi)

p_ripley <- ggplot(K_df, aes(x = r)) +
  geom_ribbon(aes(ymin = lo, ymax = hi), fill = "gray80", alpha = 0.5) +
  geom_line(aes(y = theo), color = "black", linetype = "dashed") +
  geom_line(aes(y = obs), color = "red", size = 1.2) +
  labs(title = "Ripley's K Function (0-20km)",
       subtitle = "Red = Observed | Black dashed = Random",
       x = "Distance (km)", y = "K(r)") +
  theme_minimal()
print(p_ripley)

# ------------------------------------------------------------------------------
# Pair Correlation Function (non-cumulative, shows scale of clustering)
# g(r) > 1 indicates clustering at distance r
# ------------------------------------------------------------------------------
pcf_env <- envelope(pp, pcf, nsim = 199, r = seq(0, max_r, length.out = 50))
pcf_df <- data.frame(r = pcf_env$r/1000, obs = pcf_env$obs, lo = pcf_env$lo, hi = pcf_env$hi)

# Find clustering scale where g(r) exceeds envelope
pcf_above <- which(pcf_df$obs > pcf_df$hi & pcf_df$r < 10)
cluster_scale <- if(length(pcf_above) > 0) max(pcf_df$r[pcf_above]) else NA

p_pcf <- ggplot(pcf_df, aes(x = r)) +
  geom_ribbon(aes(ymin = lo, ymax = hi), fill = "gray80", alpha = 0.5) +
  geom_hline(yintercept = 1, linetype = "dashed", alpha = 0.5) +
  geom_line(aes(y = obs), color = "blue", size = 1.2) +
  {if(!is.na(cluster_scale)) geom_vline(xintercept = cluster_scale,
                                        color = "red", linetype = "dashed")} +
  labs(title = "Pair Correlation Function (0-20km)",
       subtitle = ifelse(!is.na(cluster_scale),
                         sprintf("Clustering scale ≈ %.1f km", cluster_scale),
                         "No clear clustering scale"),
       x = "Distance (km)", y = "g(r)") +
  theme_minimal()
print(p_pcf)

# Fine-scale zoom (0-5km)
pcf_zoom <- ggplot(pcf_df[pcf_df$r < 5, ], aes(x = r)) +
  geom_ribbon(aes(ymin = lo, ymax = hi), fill = "gray80", alpha = 0.5) +
  geom_hline(yintercept = 1, linetype = "dashed") +
  geom_line(aes(y = obs), color = "blue", size = 1.2) +
  labs(title = "Pair Correlation - Fine Scale (0-5km)",
       x = "Distance (km)", y = "g(r)") +
  theme_minimal()
print(pcf_zoom)

# ==============================================================================
# SECTION G: COMPREHENSIVE DASHBOARD
# ==============================================================================
# Why: Combining key plots into a single figure provides a holistic view
# of the spatial analysis for reports and presentations.
# ==============================================================================
cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat(" SECTION G: SYNTHESIS & INTERPRETATION\n")
cat(paste(rep("=", 70), collapse = ""), "\n")

dashboard <- (p_declutter | p_bias) /
  (p_density_enhanced | p_pcf) +
  plot_annotation(title = "Spider Ecology: Complete Spatial Analysis",
                  theme = theme(plot.title = element_text(face = "bold", size = 16, hjust = 0.5)))
print(dashboard)

# ==============================================================================
# SECTION H: SAVE PLOTS
# ==============================================================================
# Why: Saving high-resolution plots enables their use in publications,
# presentations, and reports.
# ==============================================================================
cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat(" SECTION H: SAVING PLOTS\n")
cat(paste(rep("=", 70), collapse = ""), "\n")

# ------------------------------------------------------------------------------
# Configure output directory
# ------------------------------------------------------------------------------
# MODIFY THIS PATH to where you want plots saved
# Option 1: Set your desired output directory
output_dir <- "/Users/tahirali/Desktop/Workshop_Pakistan/Output_Plots"

# Option 2: Create output directory within project
# output_dir <- file.path(base_dir, "../Output_Plots")

# Create directory if it doesn't exist
if(!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
  cat("✓ Created output directory:", output_dir, "\n")
} else {
  cat("✓ Output directory exists:", output_dir, "\n")
}

# Save all plots
ggsave(file.path(output_dir, "01_pakistan_overview.png"), p_pakistan, width = 14, height = 10, dpi = 300, bg = "white")
ggsave(file.path(output_dir, "02_decluttered_view.png"), p_declutter, width = 14, height = 10, dpi = 300, bg = "white")
ggsave(file.path(output_dir, "03_punjab_zoom.png"), p_punjab, width = 12, height = 10, dpi = 300, bg = "white")
ggsave(file.path(output_dir, "04_sampling_bias_density.png"), p_bias, width = 14, height = 8, dpi = 300, bg = "white")
ggsave(file.path(output_dir, "05_sampling_bias_boxplot.png"), p_bias_box, width = 10, height = 8, dpi = 300, bg = "white")
ggsave(file.path(output_dir, "06_density_full.png"), p_density_full, width = 12, height = 10, dpi = 300, bg = "white")
ggsave(file.path(output_dir, "07_density_enhanced.png"), p_density_enhanced, width = 12, height = 10, dpi = 300, bg = "white")
ggsave(file.path(output_dir, "08_ripleys_k.png"), p_ripley, width = 10, height = 8, dpi = 300, bg = "white")
ggsave(file.path(output_dir, "09_pair_correlation.png"), p_pcf, width = 10, height = 8, dpi = 300, bg = "white")
ggsave(file.path(output_dir, "09b_pair_correlation_zoom.png"), pcf_zoom, width = 8, height = 6, dpi = 300, bg = "white")
ggsave(file.path(output_dir, "10_complete_dashboard.png"), dashboard, width = 20, height = 16, dpi = 300, bg = "white")

cat("✓ All plots saved to:", output_dir, "\n")

# ==============================================================================
# FINAL INTERPRETATION
# ==============================================================================
# Why: Summarizing results provides clear takeaways for decision-making
# and future research directions.
# ==============================================================================
cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat(" ECOLOGICAL INTERPRETATION\n")
cat(paste(rep("=", 70), collapse = ""), "\n")

cat("\n1. SAMPLING BIAS:\n")
cat("   • Roads:", ifelse(ks_road$p.value < 0.05, "SIGNIFICANT BIAS", "No bias detected"),
    sprintf("(p=%.4f)", ks_road$p.value), "\n")
cat("   • Rivers:", ifelse(ks_river$p.value < 0.05, "SIGNIFICANT BIAS", "No bias detected"),
    sprintf("(p=%.4f)", ks_river$p.value), "\n")

cat("\n2. SPATIAL PATTERN:\n")
cat("   • Clark-Evans R =", round(clark_result$statistic, 3),
    "→", ifelse(clark_result$statistic < 1, "CLUSTERED", "RANDOM"), "\n")
cat("   • Ripley's K:", ifelse(max(K_df$obs) > max(K_df$hi),
                               "Significant clustering", "Random pattern"), "\n")

cat("\n3. CLUSTERING SCALE:\n")
if(!is.na(cluster_scale)) {
  cat("   • Spider webs cluster at ~", round(cluster_scale, 1), "km\n")
  cat("   • Fine-scale clustering (0-5km): g(r) starts at ~68 → very strong aggregation\n")
} else {
  cat("   • No clear clustering scale detected\n")
}

cat("\n4. RECOMMENDATIONS:\n")
if(ks_road$p.value < 0.05 | ks_river$p.value < 0.05) {
  cat("   • ✓ Use inhomogeneous point process models with distance to roads/rivers as covariates\n")
}
if(!is.na(cluster_scale) && cluster_scale < 5) {
  cat("   • ✓ Fine-scale clustering → investigate microhabitat variables (vegetation, prey, moisture)\n")
}

cat("\n", paste(rep("=", 70), collapse = ""), "\n")
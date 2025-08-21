-- ========================================
-- Earth Engine AI Integration (Optional)
-- ========================================
-- NOTE: This script requires Google Earth Engine data export setup
-- Replace 'gs://my-earth-ai-bucket' with your actual GCS bucket
-- Comment out this section if you don't have GEE data yet
-- STEP 1: Create external table (only if GCS bucket exists)
-- Uncomment and modify the bucket path when ready:
/*
 CREATE OR REPLACE EXTERNAL TABLE `climate_ai.gee_export_metadata` OPTIONS (
 format = 'CSV',
 uris = ['gs://YOUR_BUCKET_NAME/gee_export/all_metadata.csv'],
 skip_leading_rows = 1
 );
 */
-- STEP 2: Alternative - Create sample imagery metadata for testing
-- This provides sample data structure without requiring external GCS setup
CREATE OR REPLACE TABLE `climate_ai.sample_imagery_metadata` AS
SELECT 'SAMPLE_IMG_001' AS image_id,
    'gs://sample-bucket/img001.tif' AS uri,
    'landsat8' AS source,
    38.2975 AS lat,
    -122.4583 AS lon,
    TIMESTAMP('2024-08-20 14:30:00') AS tstamp,
    0.65 AS fire_index,
    0.25 AS flood_index,
    'GEE-SONOMA-01' AS location_id,
    CURRENT_TIMESTAMP() AS capture_time
UNION ALL
SELECT 'SAMPLE_IMG_002',
    'gs://sample-bucket/img002.tif',
    'sentinel2',
    45.1500,
    25.0000,
    TIMESTAMP('2024-08-20 15:00:00'),
    0.45,
    0.75,
    'RO-CAMPULUNG-01',
    CURRENT_TIMESTAMP();
-- STEP 3: Populate imagery_metadata with sample data for testing
INSERT INTO `climate_ai.imagery_metadata` (
        image_id,
        fire_index,
        flood_index,
        location_id,
        capture_time
    )
SELECT image_id,
    fire_index,
    flood_index,
    location_id,
    capture_time
FROM `climate_ai.sample_imagery_metadata`;
-- STEP 4: Optional - Populate earth_images when GEE data is available
-- Uncomment when you have actual GCS data:
/*
 INSERT INTO `climate_ai.earth_images` (uri, ref, lat, lon, tstamp, content_type)
 SELECT uri,
 source,
 CAST(lat AS FLOAT64),
 CAST(lon AS FLOAT64),
 TIMESTAMP(tstamp),
 'image/tiff'
 FROM `climate_ai.gee_export_metadata`;
 */
-- STEP 5: Optional - Populate sensor_data with satellite references
-- Uncomment when you have actual GEE data:
/*
 INSERT INTO `climate_ai.sensor_data` (
 sensor_id,
 timestamp,
 sensor_type,
 location_id,
 lat,
 lon,
 elevation_m,
 temperature,
 humidity,
 wind_speed,
 wind_dir_deg,
 precipitation,
 pressure,
 data_quality,
 value,
 source,
 image_ref
 )
 SELECT CONCAT(
 'SEN-GEE-',
 CAST(FARM_FINGERPRINT(uri) AS STRING)
 ),
 TIMESTAMP(tstamp),
 'satellite',
 'GEE-' || source,
 CAST(lat AS FLOAT64),
 CAST(lon AS FLOAT64),
 NULL,
 NULL,
 NULL,
 NULL,
 NULL,
 NULL,
 NULL,
 'OK',
 NULL,
 'earth_engine',
 STRUCT(uri AS uri, TIMESTAMP(tstamp) AS tstamp)
 FROM `climate_ai.gee_export_metadata`;
 */
-- ========================================
-- VERIFICATION: Check sample data
-- ========================================
SELECT 'Sample imagery metadata created:' AS status,
    COUNT(*) AS records
FROM `climate_ai.sample_imagery_metadata`;
SELECT 'Imagery metadata populated:' AS status,
    COUNT(*) AS records
FROM `climate_ai.imagery_metadata`;
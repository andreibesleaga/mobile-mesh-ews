-- Stage metadata from GCS CSV
CREATE OR REPLACE EXTERNAL TABLE `climate_ai.gee_export_metadata` OPTIONS (
        format = 'CSV',
        uris = ['gs://my-earth-ai-bucket/gee_export/all_metadata.csv'],
        skip_leading_rows = 1
    );
-- Populate earth_images
INSERT INTO `climate_ai.earth_images` (uri, ref, lat, lon, tstamp, content_type)
SELECT uri,
    source,
    CAST(lat AS FLOAT64),
    CAST(lon AS FLOAT64),
    TIMESTAMP(tstamp),
    'image/tiff'
FROM `climate_ai.gee_export_metadata`;
-- Populate sensor_data with image_ref STRUCT
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
-- Populate imagery_metadata
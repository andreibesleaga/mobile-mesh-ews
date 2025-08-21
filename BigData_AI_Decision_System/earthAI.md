## **1. Google Earth Engine Export Script (JavaScript)**

Paste this into the [GEE Code Editor](https://code.earthengine.google.com/) and run it.
It will grab an image collection, sample it, and export **both imagery and metadata** to a Cloud Storage bucket you own.

```javascript
// ===== CONFIG =====
var roi = ee.Geometry.Polygon([
  [[23.0, 44.0], [27.0, 44.0], [27.0, 47.0], [23.0, 47.0], [23.0, 44.0]]
]);  // Broad Romania region

var startDate = '2025-07-01';
var endDate   = '2025-07-31';
var bucket    = 'my-earth-ai-bucket';   // <-- your GCS bucket
var folder    = 'gee_export';           // Prefix in bucket
var limitN    = 10;                      // Images per collection for demo

// ===== HELPER: export image & build metadata feature =====
function exportCollection(col, prefix, bands, limit) {
  var filtered = col
    .filterBounds(roi)
    .filterDate(startDate, endDate)
    .filter(ee.Filter.lt('CLOUD_COVER', 10))  // for Landsat
    .limit(limit);

  // Fallback for Sentinel's cloud property
  filtered = filtered.filter(ee.Filter.or(
    ee.Filter.notNull(['CLOUDY_PIXEL_PERCENTAGE']),
    ee.Filter.notNull(['CLOUD_COVER'])
  ));

  // Export each image
  filtered.evaluate(function(list) {
    list.features.forEach(function(f) {
      var img = ee.Image(f.id);
      var dateStr = img.date().format('YYYYMMdd_HHmmss').getInfo();
      var exportName = prefix + '_' + dateStr;

      Export.image.toCloudStorage({
        image: img.select(bands),
        description: exportName,
        bucket: bucket,
        fileNamePrefix: folder + '/' + exportName,
        scale: 10,
        region: roi,
        fileFormat: 'GeoTIFF'
      });
    });
  });

  // Metadata collection
  var meta = filtered.map(function(img) {
    var dateStr = img.date().format('YYYYMMdd_HHmmss');
    return ee.Feature(null, {
      'uri': 'gs://' + bucket + '/' + folder + '/' +
             ee.String(prefix + '_').cat(dateStr).cat('.tif'),
      'lat': img.geometry().centroid().coordinates().get(1),
      'lon': img.geometry().centroid().coordinates().get(0),
      'tstamp': img.date().format('YYYY-MM-dd\'T\'HH:mm:ss'),
      'source': prefix
    });
  });
  return meta;
}

// ===== SOURCE 1: Sentinel‑2 =====
var s2 = ee.ImageCollection('COPERNICUS/S2_SR');
var s2Meta = exportCollection(s2, 'S2', ['B4','B3','B2'], limitN);

// ===== SOURCE 2: Landsat 9 =====
var ls9 = ee.ImageCollection('LANDSAT/LC09/C02/T1_L2');
var ls9Meta = exportCollection(ls9, 'L9', ['SR_B4','SR_B3','SR_B2'], limitN);

// ===== MERGE & EXPORT METADATA =====
var allMeta = s2Meta.merge(ls9Meta);
Export.table.toCloudStorage({
  collection: allMeta,
  description: 'All_Metadata_Export',
  bucket: bucket,
  fileNamePrefix: folder + '/all_metadata',
  fileFormat: 'CSV'
});
```

Notes
• Adjust limitN for more images.
• Change bands arrays if your downstream model needs different spectral inputs.
• The metadata CSV will include uri, lat, lon, tstamp, and source.


**What it does:**
- Filters Sentinel‑2 for a given ROI/date/cloud cover.
- Exports a handful of RGB images as GeoTIFFs to your GCS bucket.
- Creates a metadata CSV with URI, centroid lat/lon, and timestamp.

---

## **2. Permissions & Setup**
Before running:
- Enable the **Google Earth Engine API** and **Cloud Storage API** in your Google Cloud project.
- Create the GCS bucket (`my-earth-ai-bucket` above) and give your GEE account write permission.
- In the GEE Code Editor, you’ll need to **Authorize** the export when prompted.

---

## **3. BigQuery Side: Load Into Tables**
Once the export finishes, point BigQuery at the bucket:

```sql
-- Stage metadata from GCS CSV
CREATE OR REPLACE EXTERNAL TABLE `climate_ai.gee_export_metadata`
OPTIONS (
  format = 'CSV',
  uris = ['gs://my-earth-ai-bucket/gee_export/all_metadata.csv'],
  skip_leading_rows = 1
);

-- Populate earth_images
INSERT INTO `climate_ai.earth_images` (uri, ref, lat, lon, tstamp, content_type)
SELECT
  uri,
  source,
  CAST(lat AS FLOAT64),
  CAST(lon AS FLOAT64),
  TIMESTAMP(tstamp),
  'image/tiff'
FROM `climate_ai.gee_export_metadata`;

-- Populate sensor_data with image_ref STRUCT
INSERT INTO `climate_ai.sensor_data` (
  sensor_id, timestamp, sensor_type, location_id, lat, lon,
  elevation_m, temperature, humidity, wind_speed, wind_dir_deg,
  precipitation, pressure, data_quality, value, source, image_ref
)
SELECT
  CONCAT('SEN-GEE-', CAST(FARM_FINGERPRINT(uri) AS STRING)),
  TIMESTAMP(tstamp),
  'satellite',
  'GEE-' || source,
  CAST(lat AS FLOAT64),
  CAST(lon AS FLOAT64),
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'OK', NULL,
  'earth_engine',
  STRUCT(uri AS uri, TIMESTAMP(tstamp) AS tstamp)
FROM `climate_ai.gee_export_metadata`;
```


---

## **4. Optional Enhancements**
- You can swap Sentinel‑2 for other GEE collections, like `LANDSAT/LC09/C02/T1_L2` or MODIS products.
- Add spectral indices (NDVI, NBR) into the metadata CSV for richer features.
- Use `.limit(N)` or `filter(ee.Filter.eq(...))` to control volume.

---

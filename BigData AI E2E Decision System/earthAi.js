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

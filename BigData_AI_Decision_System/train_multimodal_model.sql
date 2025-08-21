-- =========================================
-- Climate AI - Multimodal Embedding Model Training
-- =========================================
-- 1. Train the multimodal embedding model using Vertex AI connector
--    This uses BigQuery ML's remote model integration.
--    Make sure your project has the Vertex AI API enabled
--    and that you have the required IAM permissions.
CREATE OR REPLACE MODEL `climate_ai.multimodal_embedding_model` OPTIONS(
        MODEL_TYPE = 'EMBEDDING',
        REMOTE_MODEL = 'vertexai.multimodalembedding',
        ENDPOINT = 'multimodalembedding@001'
    ) AS
SELECT uri AS image_uri,
    ref AS metadata_json
FROM `climate_ai.earth_images`
WHERE content_type = 'image/jpeg';
-- 2. Generate embeddings for all stored JPEG images
CREATE OR REPLACE TABLE `climate_ai.earth_image_embeddings` AS
SELECT uri,
    ml_generate_embedding_result
FROM ML.GENERATE_EMBEDDING(
        MODEL `climate_ai.multimodal_embedding_model`,
        (
            SELECT uri,
                ref
            FROM `climate_ai.earth_images`
            WHERE content_type = 'image/jpeg'
        )
    );
-- 3. Generate a fixed embedding for the fire signature query
CREATE OR REPLACE TABLE `climate_ai.fire_signature_query_embedding` AS
SELECT content,
    ml_generate_embedding_result
FROM ML.GENERATE_EMBEDDING(
        MODEL `climate_ai.multimodal_embedding_model`,
        (
            SELECT "visible wildfire signature: plume, heat, smoke" AS content
        )
    );
-- 4. Use VECTOR_SEARCH to find the closest matches to the fire signature
CREATE OR REPLACE TABLE `climate_ai.fire_image_candidates` AS
SELECT base.uri AS gcs_uri,
    distance
FROM VECTOR_SEARCH(
        TABLE `climate_ai.earth_image_embeddings`,
        'ml_generate_embedding_result',
        TABLE `climate_ai.fire_signature_query_embedding`,
        'ml_generate_embedding_result',
        top_k => 5
    );
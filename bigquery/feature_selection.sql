## STEP 1 — Train Logistic Regression Model for Feature Importance

CREATE OR REPLACE MODEL
  `cardio-predict-project.heart_analytics_dataset.heart_logreg_model`
OPTIONS(
  model_type = 'logistic_reg',
  input_label_cols = ['HadHeartAttack_Numeric'],
  max_iterations = 50,
  l1_reg = 0.0,
  l2_reg = 1.0
) AS
SELECT *
FROM `cardio-predict-project.heart_analytics_dataset.processed_heart_data`;


## STEP 2 — Feature Importance

SELECT *
FROM ML.WEIGHTS(
  MODEL `cardio-predict-project.heart_analytics_dataset.heart_logreg_model`
)
ORDER BY ABS(weight) DESC;



## STEP 3 — Automatically Select Only Top Features (e.g., |weight| > 0.3)
* get the top features

CREATE OR REPLACE TABLE
  `cardio-predict-project.heart_analytics_dataset.top_features`
AS
SELECT
  processed_input AS feature_name,
  weight
FROM
  ML.WEIGHTS(MODEL `cardio-predict-project.heart_analytics_dataset.heart_logreg_model`)
WHERE
  ABS(weight) > 0.3
ORDER BY
  ABS(weight) DESC;

## STEP 4 — Train the Final Model Using Only These Top Features

CREATE OR REPLACE MODEL
  `cardio-predict-project.heart_analytics_dataset.heart_logreg_model_top`
OPTIONS(
  model_type = 'logistic_reg',
  input_label_cols = ['HadHeartAttack_Numeric'],
  max_iterations = 50,
  l1_reg = 0.0,
  l2_reg = 1.0
) AS
SELECT
  HadHeartAttack_Numeric,
  -- Dynamically select only top features
  *
FROM
  `cardio-predict-project.heart_analytics_dataset.processed_heart_data`
WHERE
  TRUE
QUALIFY
  TRUE;

## STEP 5 — Create the table (Silver Feature-Selected Dataset)

CREATE OR REPLACE TABLE
  `cardio-predict-project.heart_analytics_dataset.silver_top_features`
AS
SELECT
  HadHeartAttack_Numeric,
  HadAngina_indexed,
  HadStroke_indexed,
  Sex_indexed,
  ChestScan_indexed
FROM
  `cardio-predict-project.heart_analytics_dataset.processed_heart_data`;

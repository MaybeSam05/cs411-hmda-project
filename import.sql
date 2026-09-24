-- import.sql
-- Run with psql (the iLab "postgres" command), using: \i import.sql
-- Put hmda_2017_nj_all-records_labels.csv in the folder where you start postgres.
-- This targets the official 2017 New Jersey / all records / labels CSV.
-- It deliberately refuses to overwrite an existing Preliminary table.
-- If a statement fails, run ROLLBACK; before retrying after fixing the problem.
-- All work is committed together; the staging table is temporary.
-- AI assistance: OpenAI Codex generated these scripts for this assignment.
-- Disclose this assistance in README.txt and review the code before submitting.
-- References consulted (PostgreSQL documentation, not third-party solution code):
-- https://www.postgresql.org/docs/current/app-psql.html
-- https://www.postgresql.org/docs/current/sql-copy.html
-- https://www.postgresql.org/docs/current/datatype-numeric.html
-- Data and field definitions:
-- https://www.consumerfinance.gov/data-research/hmda/historic-data/
-- https://files.consumerfinance.gov/hmda-historic-data-dictionaries/lar_record_format.pdf
-- https://files.consumerfinance.gov/hmda-historic-data-dictionaries/lar_record_codes.pdf

\set ON_ERROR_STOP on
\encoding UTF8
BEGIN;

-- TEXT preserves descriptions and alphanumeric respondent IDs. Census tracts
-- are identifiers: TEXT preserves their meaningful leading zeros (e.g. 0218.04).
-- Category codes and whole-number quantities use INTEGER. NUMERIC without a
-- fixed scale preserves every decimal digit, including long census percentages.
-- Unquoted Preliminary is stored by PostgreSQL as preliminary; queries may use
-- either capitalization as long as they do not put the name in double quotes.
CREATE TABLE public.Preliminary (
    as_of_year INTEGER,
    respondent_id TEXT,
    agency_name TEXT,
    agency_abbr TEXT,
    agency_code INTEGER,
    loan_type_name TEXT,
    loan_type INTEGER,
    property_type_name TEXT,
    property_type INTEGER,
    loan_purpose_name TEXT,
    loan_purpose INTEGER,
    owner_occupancy_name TEXT,
    owner_occupancy INTEGER,
    loan_amount_000s INTEGER,
    preapproval_name TEXT,
    preapproval INTEGER,
    action_taken_name TEXT,
    action_taken INTEGER,
    msamd_name TEXT,
    msamd INTEGER,
    state_name TEXT,
    state_abbr TEXT,
    state_code INTEGER,
    county_name TEXT,
    county_code INTEGER,
    census_tract_number TEXT,
    applicant_ethnicity_name TEXT,
    applicant_ethnicity INTEGER,
    co_applicant_ethnicity_name TEXT,
    co_applicant_ethnicity INTEGER,
    applicant_race_name_1 TEXT,
    applicant_race_1 INTEGER,
    applicant_race_name_2 TEXT,
    applicant_race_2 INTEGER,
    applicant_race_name_3 TEXT,
    applicant_race_3 INTEGER,
    applicant_race_name_4 TEXT,
    applicant_race_4 INTEGER,
    applicant_race_name_5 TEXT,
    applicant_race_5 INTEGER,
    co_applicant_race_name_1 TEXT,
    co_applicant_race_1 INTEGER,
    co_applicant_race_name_2 TEXT,
    co_applicant_race_2 INTEGER,
    co_applicant_race_name_3 TEXT,
    co_applicant_race_3 INTEGER,
    co_applicant_race_name_4 TEXT,
    co_applicant_race_4 INTEGER,
    co_applicant_race_name_5 TEXT,
    co_applicant_race_5 INTEGER,
    applicant_sex_name TEXT,
    applicant_sex INTEGER,
    co_applicant_sex_name TEXT,
    co_applicant_sex INTEGER,
    applicant_income_000s INTEGER,
    purchaser_type_name TEXT,
    purchaser_type INTEGER,
    denial_reason_name_1 TEXT,
    denial_reason_1 INTEGER,
    denial_reason_name_2 TEXT,
    denial_reason_2 INTEGER,
    denial_reason_name_3 TEXT,
    denial_reason_3 INTEGER,
    rate_spread NUMERIC,
    hoepa_status_name TEXT,
    hoepa_status INTEGER,
    lien_status_name TEXT,
    lien_status INTEGER,
    edit_status_name TEXT,
    edit_status INTEGER,
    sequence_number BIGSERIAL PRIMARY KEY,
    population INTEGER,
    minority_population NUMERIC,
    hud_median_family_income INTEGER,
    tract_to_msamd_income NUMERIC,
    number_of_owner_occupied_units INTEGER,
    number_of_1_to_4_family_units INTEGER,
    application_date_indicator INTEGER
);

-- Assign source-order numbers while COPY reads the CSV, before any SELECT.
-- This avoids relying on the unspecified order of rows stored in a table.
CREATE TEMP TABLE hmda_stage (
    _source_order BIGSERIAL PRIMARY KEY,
    as_of_year TEXT,
    respondent_id TEXT,
    agency_name TEXT,
    agency_abbr TEXT,
    agency_code TEXT,
    loan_type_name TEXT,
    loan_type TEXT,
    property_type_name TEXT,
    property_type TEXT,
    loan_purpose_name TEXT,
    loan_purpose TEXT,
    owner_occupancy_name TEXT,
    owner_occupancy TEXT,
    loan_amount_000s TEXT,
    preapproval_name TEXT,
    preapproval TEXT,
    action_taken_name TEXT,
    action_taken TEXT,
    msamd_name TEXT,
    msamd TEXT,
    state_name TEXT,
    state_abbr TEXT,
    state_code TEXT,
    county_name TEXT,
    county_code TEXT,
    census_tract_number TEXT,
    applicant_ethnicity_name TEXT,
    applicant_ethnicity TEXT,
    co_applicant_ethnicity_name TEXT,
    co_applicant_ethnicity TEXT,
    applicant_race_name_1 TEXT,
    applicant_race_1 TEXT,
    applicant_race_name_2 TEXT,
    applicant_race_2 TEXT,
    applicant_race_name_3 TEXT,
    applicant_race_3 TEXT,
    applicant_race_name_4 TEXT,
    applicant_race_4 TEXT,
    applicant_race_name_5 TEXT,
    applicant_race_5 TEXT,
    co_applicant_race_name_1 TEXT,
    co_applicant_race_1 TEXT,
    co_applicant_race_name_2 TEXT,
    co_applicant_race_2 TEXT,
    co_applicant_race_name_3 TEXT,
    co_applicant_race_3 TEXT,
    co_applicant_race_name_4 TEXT,
    co_applicant_race_4 TEXT,
    co_applicant_race_name_5 TEXT,
    co_applicant_race_5 TEXT,
    applicant_sex_name TEXT,
    applicant_sex TEXT,
    co_applicant_sex_name TEXT,
    co_applicant_sex TEXT,
    applicant_income_000s TEXT,
    purchaser_type_name TEXT,
    purchaser_type TEXT,
    denial_reason_name_1 TEXT,
    denial_reason_1 TEXT,
    denial_reason_name_2 TEXT,
    denial_reason_2 TEXT,
    denial_reason_name_3 TEXT,
    denial_reason_3 TEXT,
    rate_spread TEXT,
    hoepa_status_name TEXT,
    hoepa_status TEXT,
    lien_status_name TEXT,
    lien_status TEXT,
    edit_status_name TEXT,
    edit_status TEXT,
    sequence_number TEXT,
    population TEXT,
    minority_population TEXT,
    hud_median_family_income TEXT,
    tract_to_msamd_income TEXT,
    number_of_owner_occupied_units TEXT,
    number_of_1_to_4_family_units TEXT,
    application_date_indicator TEXT
) ON COMMIT DROP;

-- psql requires this entire \copy command on ONE physical line.
\copy pg_temp.hmda_stage (as_of_year, respondent_id, agency_name, agency_abbr, agency_code, loan_type_name, loan_type, property_type_name, property_type, loan_purpose_name, loan_purpose, owner_occupancy_name, owner_occupancy, loan_amount_000s, preapproval_name, preapproval, action_taken_name, action_taken, msamd_name, msamd, state_name, state_abbr, state_code, county_name, county_code, census_tract_number, applicant_ethnicity_name, applicant_ethnicity, co_applicant_ethnicity_name, co_applicant_ethnicity, applicant_race_name_1, applicant_race_1, applicant_race_name_2, applicant_race_2, applicant_race_name_3, applicant_race_3, applicant_race_name_4, applicant_race_4, applicant_race_name_5, applicant_race_5, co_applicant_race_name_1, co_applicant_race_1, co_applicant_race_name_2, co_applicant_race_2, co_applicant_race_name_3, co_applicant_race_3, co_applicant_race_name_4, co_applicant_race_4, co_applicant_race_name_5, co_applicant_race_5, applicant_sex_name, applicant_sex, co_applicant_sex_name, co_applicant_sex, applicant_income_000s, purchaser_type_name, purchaser_type, denial_reason_name_1, denial_reason_1, denial_reason_name_2, denial_reason_2, denial_reason_name_3, denial_reason_3, rate_spread, hoepa_status_name, hoepa_status, lien_status_name, lien_status, edit_status_name, edit_status, sequence_number, population, minority_population, hud_median_family_income, tract_to_msamd_income, number_of_owner_occupied_units, number_of_1_to_4_family_units, application_date_indicator) FROM 'hmda_2017_nj_all-records_labels.csv' WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8')

-- Catch the wrong year/state/download variant and unexpected sequence values.
-- The published file has exactly 349563 records and a blank sequence column.
DO $$
BEGIN
    IF (SELECT COUNT(*) FROM pg_temp.hmda_stage) <> 349563 THEN
        RAISE EXCEPTION 'Expected 349563 records: check the downloaded CSV.';
    END IF;
    IF EXISTS (
        SELECT 1 FROM pg_temp.hmda_stage
        WHERE as_of_year IS DISTINCT FROM '2017'
           OR state_abbr IS DISTINCT FROM 'NJ'
           OR state_code IS DISTINCT FROM '34'
    ) THEN
        RAISE EXCEPTION 'Expected only 2017 New Jersey records.';
    END IF;
    IF EXISTS (
        SELECT 1 FROM pg_temp.hmda_stage
        WHERE COALESCE(sequence_number, '') <> ''
    ) THEN
        RAISE EXCEPTION 'Expected blank source sequence_number values; stopping to avoid losing source data.';
    END IF;
END
$$;

-- Convert blank fields to NULL, never to zero. Invalid numbers raise an error.
-- The source row numbers become the permanent sequential primary key.
INSERT INTO public.Preliminary (
    as_of_year,
    respondent_id,
    agency_name,
    agency_abbr,
    agency_code,
    loan_type_name,
    loan_type,
    property_type_name,
    property_type,
    loan_purpose_name,
    loan_purpose,
    owner_occupancy_name,
    owner_occupancy,
    loan_amount_000s,
    preapproval_name,
    preapproval,
    action_taken_name,
    action_taken,
    msamd_name,
    msamd,
    state_name,
    state_abbr,
    state_code,
    county_name,
    county_code,
    census_tract_number,
    applicant_ethnicity_name,
    applicant_ethnicity,
    co_applicant_ethnicity_name,
    co_applicant_ethnicity,
    applicant_race_name_1,
    applicant_race_1,
    applicant_race_name_2,
    applicant_race_2,
    applicant_race_name_3,
    applicant_race_3,
    applicant_race_name_4,
    applicant_race_4,
    applicant_race_name_5,
    applicant_race_5,
    co_applicant_race_name_1,
    co_applicant_race_1,
    co_applicant_race_name_2,
    co_applicant_race_2,
    co_applicant_race_name_3,
    co_applicant_race_3,
    co_applicant_race_name_4,
    co_applicant_race_4,
    co_applicant_race_name_5,
    co_applicant_race_5,
    applicant_sex_name,
    applicant_sex,
    co_applicant_sex_name,
    co_applicant_sex,
    applicant_income_000s,
    purchaser_type_name,
    purchaser_type,
    denial_reason_name_1,
    denial_reason_1,
    denial_reason_name_2,
    denial_reason_2,
    denial_reason_name_3,
    denial_reason_3,
    rate_spread,
    hoepa_status_name,
    hoepa_status,
    lien_status_name,
    lien_status,
    edit_status_name,
    edit_status,
    sequence_number,
    population,
    minority_population,
    hud_median_family_income,
    tract_to_msamd_income,
    number_of_owner_occupied_units,
    number_of_1_to_4_family_units,
    application_date_indicator
)
SELECT
    NULLIF(as_of_year, '')::INTEGER AS as_of_year,
    NULLIF(respondent_id, '')::TEXT AS respondent_id,
    NULLIF(agency_name, '')::TEXT AS agency_name,
    NULLIF(agency_abbr, '')::TEXT AS agency_abbr,
    NULLIF(agency_code, '')::INTEGER AS agency_code,
    NULLIF(loan_type_name, '')::TEXT AS loan_type_name,
    NULLIF(loan_type, '')::INTEGER AS loan_type,
    NULLIF(property_type_name, '')::TEXT AS property_type_name,
    NULLIF(property_type, '')::INTEGER AS property_type,
    NULLIF(loan_purpose_name, '')::TEXT AS loan_purpose_name,
    NULLIF(loan_purpose, '')::INTEGER AS loan_purpose,
    NULLIF(owner_occupancy_name, '')::TEXT AS owner_occupancy_name,
    NULLIF(owner_occupancy, '')::INTEGER AS owner_occupancy,
    NULLIF(loan_amount_000s, '')::INTEGER AS loan_amount_000s,
    NULLIF(preapproval_name, '')::TEXT AS preapproval_name,
    NULLIF(preapproval, '')::INTEGER AS preapproval,
    NULLIF(action_taken_name, '')::TEXT AS action_taken_name,
    NULLIF(action_taken, '')::INTEGER AS action_taken,
    NULLIF(msamd_name, '')::TEXT AS msamd_name,
    NULLIF(msamd, '')::INTEGER AS msamd,
    NULLIF(state_name, '')::TEXT AS state_name,
    NULLIF(state_abbr, '')::TEXT AS state_abbr,
    NULLIF(state_code, '')::INTEGER AS state_code,
    NULLIF(county_name, '')::TEXT AS county_name,
    NULLIF(county_code, '')::INTEGER AS county_code,
    NULLIF(census_tract_number, '')::TEXT AS census_tract_number,
    NULLIF(applicant_ethnicity_name, '')::TEXT AS applicant_ethnicity_name,
    NULLIF(applicant_ethnicity, '')::INTEGER AS applicant_ethnicity,
    NULLIF(co_applicant_ethnicity_name, '')::TEXT AS co_applicant_ethnicity_name,
    NULLIF(co_applicant_ethnicity, '')::INTEGER AS co_applicant_ethnicity,
    NULLIF(applicant_race_name_1, '')::TEXT AS applicant_race_name_1,
    NULLIF(applicant_race_1, '')::INTEGER AS applicant_race_1,
    NULLIF(applicant_race_name_2, '')::TEXT AS applicant_race_name_2,
    NULLIF(applicant_race_2, '')::INTEGER AS applicant_race_2,
    NULLIF(applicant_race_name_3, '')::TEXT AS applicant_race_name_3,
    NULLIF(applicant_race_3, '')::INTEGER AS applicant_race_3,
    NULLIF(applicant_race_name_4, '')::TEXT AS applicant_race_name_4,
    NULLIF(applicant_race_4, '')::INTEGER AS applicant_race_4,
    NULLIF(applicant_race_name_5, '')::TEXT AS applicant_race_name_5,
    NULLIF(applicant_race_5, '')::INTEGER AS applicant_race_5,
    NULLIF(co_applicant_race_name_1, '')::TEXT AS co_applicant_race_name_1,
    NULLIF(co_applicant_race_1, '')::INTEGER AS co_applicant_race_1,
    NULLIF(co_applicant_race_name_2, '')::TEXT AS co_applicant_race_name_2,
    NULLIF(co_applicant_race_2, '')::INTEGER AS co_applicant_race_2,
    NULLIF(co_applicant_race_name_3, '')::TEXT AS co_applicant_race_name_3,
    NULLIF(co_applicant_race_3, '')::INTEGER AS co_applicant_race_3,
    NULLIF(co_applicant_race_name_4, '')::TEXT AS co_applicant_race_name_4,
    NULLIF(co_applicant_race_4, '')::INTEGER AS co_applicant_race_4,
    NULLIF(co_applicant_race_name_5, '')::TEXT AS co_applicant_race_name_5,
    NULLIF(co_applicant_race_5, '')::INTEGER AS co_applicant_race_5,
    NULLIF(applicant_sex_name, '')::TEXT AS applicant_sex_name,
    NULLIF(applicant_sex, '')::INTEGER AS applicant_sex,
    NULLIF(co_applicant_sex_name, '')::TEXT AS co_applicant_sex_name,
    NULLIF(co_applicant_sex, '')::INTEGER AS co_applicant_sex,
    NULLIF(applicant_income_000s, '')::INTEGER AS applicant_income_000s,
    NULLIF(purchaser_type_name, '')::TEXT AS purchaser_type_name,
    NULLIF(purchaser_type, '')::INTEGER AS purchaser_type,
    NULLIF(denial_reason_name_1, '')::TEXT AS denial_reason_name_1,
    NULLIF(denial_reason_1, '')::INTEGER AS denial_reason_1,
    NULLIF(denial_reason_name_2, '')::TEXT AS denial_reason_name_2,
    NULLIF(denial_reason_2, '')::INTEGER AS denial_reason_2,
    NULLIF(denial_reason_name_3, '')::TEXT AS denial_reason_name_3,
    NULLIF(denial_reason_3, '')::INTEGER AS denial_reason_3,
    NULLIF(rate_spread, '')::NUMERIC AS rate_spread,
    NULLIF(hoepa_status_name, '')::TEXT AS hoepa_status_name,
    NULLIF(hoepa_status, '')::INTEGER AS hoepa_status,
    NULLIF(lien_status_name, '')::TEXT AS lien_status_name,
    NULLIF(lien_status, '')::INTEGER AS lien_status,
    NULLIF(edit_status_name, '')::TEXT AS edit_status_name,
    NULLIF(edit_status, '')::INTEGER AS edit_status,
    _source_order AS sequence_number,
    NULLIF(population, '')::INTEGER AS population,
    NULLIF(minority_population, '')::NUMERIC AS minority_population,
    NULLIF(hud_median_family_income, '')::INTEGER AS hud_median_family_income,
    NULLIF(tract_to_msamd_income, '')::NUMERIC AS tract_to_msamd_income,
    NULLIF(number_of_owner_occupied_units, '')::INTEGER AS number_of_owner_occupied_units,
    NULLIF(number_of_1_to_4_family_units, '')::INTEGER AS number_of_1_to_4_family_units,
    NULLIF(application_date_indicator, '')::INTEGER AS application_date_indicator
FROM pg_temp.hmda_stage
ORDER BY _source_order;

-- Explicitly inserted keys do not advance BIGSERIAL's default sequence.
-- Set its next generated value to 349564, avoiding conflicts on future inserts.
SELECT setval(
    pg_get_serial_sequence('public.preliminary', 'sequence_number'),
    (SELECT MAX(sequence_number) FROM public.Preliminary),
    true
);

COMMIT;

-- Expected: 349563 rows, first_sequence 1, last_sequence 349563.
SELECT COUNT(*) AS total_rows,
       MIN(sequence_number) AS first_sequence,
       MAX(sequence_number) AS last_sequence
FROM public.Preliminary;

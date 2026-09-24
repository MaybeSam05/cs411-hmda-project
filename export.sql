-- export.sql
-- Run after import.sql, using: \i export.sql
-- Writes reconstructed.csv in the folder where you started postgres.
-- That output file is overwritten if it already exists.
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

-- Export current values from the typed Preliminary table, not a saved CSV.
-- Restore the source's blank sequence_number FIELD. Do not remove its column:
-- the original CSV contains this column, so deleting it cannot pass exact diff.
-- Only the generated numbers are removed from the CSV; the database keeps them.
-- COALESCE turns NULL into empty text so FORCE_QUOTE also quotes blank values.
-- Rate spreads use the source's five-character form, e.g. 01.50, not 1.50.
-- _export_order is internal to this temporary view and is never exported.
CREATE TEMP VIEW hmda_export AS
SELECT
    sequence_number AS _export_order,
    COALESCE(as_of_year::TEXT, '') AS as_of_year,
    COALESCE(respondent_id::TEXT, '') AS respondent_id,
    COALESCE(agency_name::TEXT, '') AS agency_name,
    COALESCE(agency_abbr::TEXT, '') AS agency_abbr,
    COALESCE(agency_code::TEXT, '') AS agency_code,
    COALESCE(loan_type_name::TEXT, '') AS loan_type_name,
    COALESCE(loan_type::TEXT, '') AS loan_type,
    COALESCE(property_type_name::TEXT, '') AS property_type_name,
    COALESCE(property_type::TEXT, '') AS property_type,
    COALESCE(loan_purpose_name::TEXT, '') AS loan_purpose_name,
    COALESCE(loan_purpose::TEXT, '') AS loan_purpose,
    COALESCE(owner_occupancy_name::TEXT, '') AS owner_occupancy_name,
    COALESCE(owner_occupancy::TEXT, '') AS owner_occupancy,
    COALESCE(loan_amount_000s::TEXT, '') AS loan_amount_000s,
    COALESCE(preapproval_name::TEXT, '') AS preapproval_name,
    COALESCE(preapproval::TEXT, '') AS preapproval,
    COALESCE(action_taken_name::TEXT, '') AS action_taken_name,
    COALESCE(action_taken::TEXT, '') AS action_taken,
    COALESCE(msamd_name::TEXT, '') AS msamd_name,
    COALESCE(msamd::TEXT, '') AS msamd,
    COALESCE(state_name::TEXT, '') AS state_name,
    COALESCE(state_abbr::TEXT, '') AS state_abbr,
    COALESCE(state_code::TEXT, '') AS state_code,
    COALESCE(county_name::TEXT, '') AS county_name,
    COALESCE(county_code::TEXT, '') AS county_code,
    COALESCE(census_tract_number::TEXT, '') AS census_tract_number,
    COALESCE(applicant_ethnicity_name::TEXT, '') AS applicant_ethnicity_name,
    COALESCE(applicant_ethnicity::TEXT, '') AS applicant_ethnicity,
    COALESCE(co_applicant_ethnicity_name::TEXT, '') AS co_applicant_ethnicity_name,
    COALESCE(co_applicant_ethnicity::TEXT, '') AS co_applicant_ethnicity,
    COALESCE(applicant_race_name_1::TEXT, '') AS applicant_race_name_1,
    COALESCE(applicant_race_1::TEXT, '') AS applicant_race_1,
    COALESCE(applicant_race_name_2::TEXT, '') AS applicant_race_name_2,
    COALESCE(applicant_race_2::TEXT, '') AS applicant_race_2,
    COALESCE(applicant_race_name_3::TEXT, '') AS applicant_race_name_3,
    COALESCE(applicant_race_3::TEXT, '') AS applicant_race_3,
    COALESCE(applicant_race_name_4::TEXT, '') AS applicant_race_name_4,
    COALESCE(applicant_race_4::TEXT, '') AS applicant_race_4,
    COALESCE(applicant_race_name_5::TEXT, '') AS applicant_race_name_5,
    COALESCE(applicant_race_5::TEXT, '') AS applicant_race_5,
    COALESCE(co_applicant_race_name_1::TEXT, '') AS co_applicant_race_name_1,
    COALESCE(co_applicant_race_1::TEXT, '') AS co_applicant_race_1,
    COALESCE(co_applicant_race_name_2::TEXT, '') AS co_applicant_race_name_2,
    COALESCE(co_applicant_race_2::TEXT, '') AS co_applicant_race_2,
    COALESCE(co_applicant_race_name_3::TEXT, '') AS co_applicant_race_name_3,
    COALESCE(co_applicant_race_3::TEXT, '') AS co_applicant_race_3,
    COALESCE(co_applicant_race_name_4::TEXT, '') AS co_applicant_race_name_4,
    COALESCE(co_applicant_race_4::TEXT, '') AS co_applicant_race_4,
    COALESCE(co_applicant_race_name_5::TEXT, '') AS co_applicant_race_name_5,
    COALESCE(co_applicant_race_5::TEXT, '') AS co_applicant_race_5,
    COALESCE(applicant_sex_name::TEXT, '') AS applicant_sex_name,
    COALESCE(applicant_sex::TEXT, '') AS applicant_sex,
    COALESCE(co_applicant_sex_name::TEXT, '') AS co_applicant_sex_name,
    COALESCE(co_applicant_sex::TEXT, '') AS co_applicant_sex,
    COALESCE(applicant_income_000s::TEXT, '') AS applicant_income_000s,
    COALESCE(purchaser_type_name::TEXT, '') AS purchaser_type_name,
    COALESCE(purchaser_type::TEXT, '') AS purchaser_type,
    COALESCE(denial_reason_name_1::TEXT, '') AS denial_reason_name_1,
    COALESCE(denial_reason_1::TEXT, '') AS denial_reason_1,
    COALESCE(denial_reason_name_2::TEXT, '') AS denial_reason_name_2,
    COALESCE(denial_reason_2::TEXT, '') AS denial_reason_2,
    COALESCE(denial_reason_name_3::TEXT, '') AS denial_reason_name_3,
    COALESCE(denial_reason_3::TEXT, '') AS denial_reason_3,
    COALESCE(to_char(rate_spread, 'FM00.00'), '') AS rate_spread,
    COALESCE(hoepa_status_name::TEXT, '') AS hoepa_status_name,
    COALESCE(hoepa_status::TEXT, '') AS hoepa_status,
    COALESCE(lien_status_name::TEXT, '') AS lien_status_name,
    COALESCE(lien_status::TEXT, '') AS lien_status,
    COALESCE(edit_status_name::TEXT, '') AS edit_status_name,
    COALESCE(edit_status::TEXT, '') AS edit_status,
    ''::TEXT AS sequence_number,
    COALESCE(population::TEXT, '') AS population,
    COALESCE(minority_population::TEXT, '') AS minority_population,
    COALESCE(hud_median_family_income::TEXT, '') AS hud_median_family_income,
    COALESCE(tract_to_msamd_income::TEXT, '') AS tract_to_msamd_income,
    COALESCE(number_of_owner_occupied_units::TEXT, '') AS number_of_owner_occupied_units,
    COALESCE(number_of_1_to_4_family_units::TEXT, '') AS number_of_1_to_4_family_units,
    COALESCE(application_date_indicator::TEXT, '') AS application_date_indicator
FROM public.Preliminary;

-- Select all 78 original columns in their original order, sorted by source row.
-- PostgreSQL leaves the header unquoted and quotes every data field, matching
-- the official file. On iLab/Linux the output uses LF newlines, as does the CSV.
-- Keep the following \copy command on ONE physical line.
\copy (SELECT as_of_year, respondent_id, agency_name, agency_abbr, agency_code, loan_type_name, loan_type, property_type_name, property_type, loan_purpose_name, loan_purpose, owner_occupancy_name, owner_occupancy, loan_amount_000s, preapproval_name, preapproval, action_taken_name, action_taken, msamd_name, msamd, state_name, state_abbr, state_code, county_name, county_code, census_tract_number, applicant_ethnicity_name, applicant_ethnicity, co_applicant_ethnicity_name, co_applicant_ethnicity, applicant_race_name_1, applicant_race_1, applicant_race_name_2, applicant_race_2, applicant_race_name_3, applicant_race_3, applicant_race_name_4, applicant_race_4, applicant_race_name_5, applicant_race_5, co_applicant_race_name_1, co_applicant_race_1, co_applicant_race_name_2, co_applicant_race_2, co_applicant_race_name_3, co_applicant_race_3, co_applicant_race_name_4, co_applicant_race_4, co_applicant_race_name_5, co_applicant_race_5, applicant_sex_name, applicant_sex, co_applicant_sex_name, co_applicant_sex, applicant_income_000s, purchaser_type_name, purchaser_type, denial_reason_name_1, denial_reason_1, denial_reason_name_2, denial_reason_2, denial_reason_name_3, denial_reason_3, rate_spread, hoepa_status_name, hoepa_status, lien_status_name, lien_status, edit_status_name, edit_status, sequence_number, population, minority_population, hud_median_family_income, tract_to_msamd_income, number_of_owner_occupied_units, number_of_1_to_4_family_units, application_date_indicator FROM pg_temp.hmda_export ORDER BY _export_order) TO 'reconstructed.csv' WITH (FORMAT CSV, HEADER TRUE, FORCE_QUOTE *, ENCODING 'UTF8')

DROP VIEW pg_temp.hmda_export;
COMMIT;

-- After leaving psql with \q, check in the ordinary Linux terminal:
-- diff hmda_2017_nj_all-records_labels.csv reconstructed.csv
-- Success: no differences printed, and diff exits with status 0.

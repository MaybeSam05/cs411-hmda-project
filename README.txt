CS411 HMDA Project - README
Repo: https://github.com/MaybeSam05/cs411-hmda-project

=====================================================================
0. TEAM MEMBERS
=====================================================================
- Samarth Verma - sv865
- Nandan Ranadive - netid: nr809
- Ansh Krishna - netid: ak2664
- Aavash Lamichhane - netid: al1752 

=====================================================================
1. KNOWN ISSUES
=====================================================================
There were no issues, nothing was printed and it exited with a status 0.

=====================================================================
2. COLLABORATION, RESOURCES, AND AI DISCLOSURE
=====================================================================
AI assistance: OpenAI Codex generated import.sql and export.sql for this
assignment. We reviewed the code before submitting. Claude was also used for
verifying some of the information.

Collaboration:
- Samarth Verma - Completed the ER diagram
- Nandan Ranadive and Ansh Krishna - SQL code and screenshots
- Aavash Lamichhane - README file, final revision

Resources consulted:
- PostgreSQL documentation: psql (app-psql), COPY (sql-copy), numeric types
  (datatype-numeric)
  https://www.postgresql.org/docs/current/app-psql.html
  https://www.postgresql.org/docs/current/sql-copy.html
  https://www.postgresql.org/docs/current/datatype-numeric.html
- CFPB HMDA historic data and data dictionaries (field definitions and
  code meanings)
  https://www.consumerfinance.gov/data-research/hmda/historic-data/
  https://files.consumerfinance.gov/hmda-historic-data-dictionaries/lar_record_format.pdf
  https://files.consumerfinance.gov/hmda-historic-data-dictionaries/lar_record_codes.pdf

=====================================================================
3. INSIGHTS AND ENTITY DECOMPOSITION
=====================================================================
Data: 2017 HMDA loan/application records for New Jersey (349,563 rows,
78 attributes), loaded into one wide table, public.Preliminary.

Insights (replace/confirm with your own queries and results):
- [e.g. approval vs. denial rates by loan purpose or county]
- [e.g. most common denial reasons and how they vary by applicant income]
- [e.g. relationship between census tract minority_population and
  denial rate, or applicant income and loan amount]
- [e.g. which lenders (respondent_id/agency) originate the most loans]

Rules used to divide attributes into entities:
1. Each *_name column is functionally determined by its matching code column
   (e.g. loan_type_name by loan_type), so code/name pairs move together into
   a lookup entity keyed by the code.
2. Attributes describing the same real-world thing are grouped: location
   (msamd, state, county, census tract), census tract demographics
   (population, minority_population, hud_median_family_income,
   tract_to_msamd_income, owner-occupied and 1-4 family units), lender
   (respondent_id, agency), and applicant / co-applicant demographics
   (ethnicity, race 1-5, sex).
3. Repeating groups (applicant_race_1..5, co_applicant_race_1..5,
   denial_reason_1..3) are split into separate rows in their own tables
   rather than left as numbered columns.
4. Attributes that describe the loan application itself (amount, income,
   action taken, purchaser type, lien status, rate spread, HOEPA status,
   application date indicator) stay in the central application entity, which
   references the others by foreign key.
5. Each entity gets a key that is either an existing code (lookup tables)
   or the source-row sequence_number (the application).

[Adjust the entity list and rules so they match your ER diagram in
/er-diagram exactly.]

=====================================================================
4. PROBLEMS FACED AND TIME SPENT
=====================================================================
Problems:
- [e.g. iLab/psql setup, \copy needing one line, CSV quoting and blank vs.
  NULL fields, leading zeros in census tracts, exact diff of the exported
  CSV, rate_spread formatting]
- [anything else]

Time spent: about [N] hours total ([N] each).

=====================================================================
5. DATABASE USED FOR GRADING
=====================================================================
[Team member's full name / netid] has the data stored in their database
(iLab account: [netid], database: [name]).

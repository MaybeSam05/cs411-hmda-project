CS336 HMDA Project 1 - README
Repo: https://github.com/MaybeSam05/cs411-hmda-project

=====================================================================
0. TEAM MEMBERS
=====================================================================
- Samarth Verma - netid: sv865
- Nandan Ranadive - netid: nr809
- Ansh Krishna - netid: ak2664
- Aavash Lamichhane - netid: al1752

=====================================================================
1. KNOWN ISSUES
=====================================================================
There are no known issues. The import script loaded all 349,563 records,
assigned unique sequence_number values from 1 through 349,563, and preserved
the required data types. The export script reconstructed a CSV that was
byte-for-byte identical to the original; diff printed no differences and
returned exit status 0.

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
78 attributes), loaded into one wide table, public.

Denial rate below = denied / (originated + denied), so withdrawn, closed,
purchased and approved-but-not-accepted files are excluded. Base: 218,410
decided applications; overall denial rate 22.5%.
 
1. Outcome mix. Of 349,563 records, 169,196 (48.4%) were originated,
   54,938 (15.7%) were loans purchased by an institution, 49,214 (14.1%)
   were denied, 48,680 (13.9%) were withdrawn, 17,940 (5.1%) were closed
   for incompleteness and 9,586 (2.7%) were approved but not accepted.
   Only 9 rows are preapproval requests. Just over half of all records
   are not an origination, so a file's presence in HMDA says little about
   whether the borrower got a loan.
 
2. Loan purpose is the strongest driver of denial. Home improvement loans
   are denied 45.6% of the time, refinancing 29.8%, home purchase 13.1%.
   Home purchase is the largest group (184,956 records) but is the safest
   to approve; home improvement is the smallest (25,529) and by far the
   riskiest to apply for. Median loan sizes are $261k (purchase), $233k
   (refinance), $50k (improvement); median applicant income is about
   $100-103k for all three, so the gap is not explained by income.
 
3. Racial and ethnic disparities in denial. Denial rates: American Indian/
   Alaska Native 44.3% (n=1,074), Black 35.7% (n=16,098), White 20.0%
   (n=146,759), Asian 18.8% (n=19,545). Hispanic/Latino applicants are
   denied 27.5% vs 20.9% for non-Hispanic. These gaps persist within
   income bands: for applicants earning $50-100k, Black applicants are
   denied 33.1% vs 20.8% White and 21.6% Asian; above $250k it is 25.5%
   vs 13.0% White and 14.1% Asian. So income alone does not explain the
   difference (though this data lacks credit score and debt-to-income, so
   we cannot claim discrimination). Applicants who did not provide race
   are denied 30.5% of the time, and 30,408 applications have no race
   reported, which is itself a data-quality issue.
 
4. Sex. Female applicants are denied 24.5% vs 20.8% for male applicants
   (62,473 vs 135,922 decided). Male applicants make up 68.5% of decided
   applications with a reported male or female sex.
 
5. Income. Denial falls steadily as income rises: 41.6% for incomes up to
   $50k, 24.0% for $50-100k, 18.4% for $100-150k, 15.7% for $150-250k, and
   14.7% above $250k. 14.5% of all records have no income (mostly
   purchased loans), so income analyses drop those rows.
 
6. Geography. Among counties with at least 2,000 decided applications,
   denial is highest in Cumberland (33.4%), Atlantic (26.8%), Camden
   (26.7%) and Essex (25.8%) and lowest in Morris (17.8%), Cape May
   (19.2%) and Somerset (19.3%). Denial also rises with the tract's
   minority share: 19.7% where minority population is 0-20%, 21.0% for
   20-40%, 23.7% for 40-60%, 26.6% for 60-80%, and 33.5% for 80-100%.
 
7. Stated reasons for denial. Among 49,214 denials, the top primary
   reasons are debt-to-income ratio (10,360; 21.1%), credit history
   (8,816; 17.9%), collateral (7,021; 14.3%) and incomplete application
   (5,486; 11.1%). 24.4% of denials list no reason at all because
   reporting is optional for some agencies, so these percentages
   understate the true reason mix.
 
8. Lender concentration. 758 lenders originated at least one loan (854
   appear in the file). The top lender by originations (respondent
   0000451965, CFPB) made 12,205 loans; the top 10 lenders account for
   31.6% of all originations. By regulating agency, HUD-supervised
   institutions file 196,440 records (56.2%) and CFPB 113,439 (32.5%).
 
9. Loan product. Conventional loans are 71.6% of records (250,133), FHA
   23.3% (81,517), VA 4.5% (15,845), FSA/RHS 0.6% (2,068). VA loans have
   the highest denial rate (29.1%) and FSA/RHS the lowest (18.6%).
 
10. Sparse fields. Only 8,816 records (2.5%) have a rate_spread (it is
    reported only for higher-priced loans), and just 26 loans are HOEPA
    loans. These columns are mostly NULL in the database.

- Entities and the rules used to derive them ---
Rules:
R1. Attributes were grouped by the real-world subject they describe. The ER
    diagram therefore uses Agency, Institution, Loan Application, Applicant,
    Co-Applicant, Property, Location, Census Tract, Purchaser, and Denial.
R2. Every one of the 78 source attributes appears in at least one entity. No
    source attribute was removed or renamed, and locationID is the only new
    attribute because the assignment specifically permits it.
R3. Code attributes remain beside their corresponding plain-language name
    attributes in the entity they describe. For example, loan_type and
    loan_type_name are both in Loan Application, while property_type and
    property_type_name are both in Property. This preserves both versions
    supplied by the source file.
R4. Applicant and Co-Applicant are separate because they represent different
    roles in an application. The numbered race fields and denial-reason fields
    remain as source attributes because this part of the project requires all
    downloaded attributes to appear and postpones normalization until the next
    part of the project.
R5. Geographic attributes were divided into Location and Census Tract.
    Location contains MSA/MD, state, and county information; Census Tract
    contains the tract number and tract-level demographic and housing data.
R6. Relationships follow the meaning of the data. An Agency oversees many
    Institutions, an Institution reports many Loan Applications, and each Loan
    Application has one Applicant and one Property. A Loan Application may
    optionally have a Co-Applicant, Purchaser, or Denial. A Location contains
    many Census Tracts, and a Census Tract can contain many Properties.

=====================================================================
4. DEVELOPMENT PROBLEMS AND TIME SPENT
=====================================================================
- Leading zeros: census tracts such as 0218.04 and some IDs are identifiers,
  not numbers; loading them as numeric dropped the zeros, so they are TEXT.
- Exact round trip: diff must show zero differences, which required
  quoting every field (FORCE_QUOTE *), an unquoted header, LF line endings,
  restoring the blank sequence_number column, and the 01.50 rate_spread
  format.
- Sequence bug risk: inserting explicit sequence_number values does not
  advance BIGSERIAL, so we call setval() afterward to avoid future key
  collisions.
Time spent: approximately 8 hours, including review.

=====================================================================
5. DATABASE USED FOR GRADING
=====================================================================
Nandan Ranadive (netid: nr809) has the data stored in their database


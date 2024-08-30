{{ config(enabled=false) }}

WITH filing_politicians AS (
    {{ select_filing_politicians('int_mn_sos_fed_state_county_filings_primaries') }}
)

SELECT *
FROM filing_politicians

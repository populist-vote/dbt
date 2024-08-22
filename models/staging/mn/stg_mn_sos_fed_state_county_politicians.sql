{{ config(enabled=true) }}
WITH filing_politicians AS (
    {{ select_filing_politicians('int_mn_sos_fed_state_county_filings') }}
)

SELECT *
FROM filing_politicians

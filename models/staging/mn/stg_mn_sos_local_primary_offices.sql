{{ config(enabled=false) }}
WITH filing_offices AS (
    {{ select_filing_offices('int_mn_sos_local_filings_primaries') }}
)

SELECT *
FROM filing_offices

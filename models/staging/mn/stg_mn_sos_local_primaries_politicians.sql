WITH filing_politicians AS (
    {{ select_filing_politicians('int_mn_sos_local_filings_primaries') }}
)

SELECT *
FROM filing_politicians

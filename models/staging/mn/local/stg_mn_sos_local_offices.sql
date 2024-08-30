WITH filing_offices AS (
    {{ select_filing_offices('int_mn_sos_local_filings') }}
)

SELECT *
FROM filing_offices

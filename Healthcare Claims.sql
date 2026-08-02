# Identifying blank rows in columns and adding value to blank spaces
SELECT member_id, 
	enrollment_end_date
FROM members
WHERE enrollment_end_date = '';

UPDATE members
SET enrollment_end_date = 'NULL'
WHERE enrollment_end_date = '';

# Claim type cost breakdown and rank claim types (expensive to least)
SELECT claim_type,
	SUM(billed_amount) AS total_billed_amount,
	SUM(paid_amount) AS total_paid_amount,
    COUNT(claim_id) AS total_claims,
    DENSE_RANK() OVER(
		ORDER BY SUM(paid_amount) DESC
	) AS total_amount_rank
FROM claims
GROUP BY claim_type;

# Find top 10 CPT codes by total paid amount
SELECT cpt_code,
	SUM(billed_amount) AS total_billed_amount,
	SUM(paid_amount) AS total_paid_amount
FROM claims
GROUP BY cpt_code 
ORDER BY total_paid_amount DESC
LIMIT 10;

# What is the percentage of total CPT billed was paid (top 10 CPT codes)
SELECT cpt_code,
	SUM(billed_amount) AS total_billed_amount,
	SUM(paid_amount) AS total_paid_amount,
    ROUND(SUM(paid_amount)/SUM(billed_amount) * 100, 0) AS percentage_paid
FROM claims
GROUP BY cpt_code 
ORDER BY total_paid_amount DESC
LIMIT 10;

# Find top 10 ICD codes by total paid amount
SELECT icd_code,
	SUM(paid_amount) AS total_paid_amount
FROM claims
GROUP BY icd_code 
ORDER BY total_paid_amount DESC
LIMIT 10;

# What is the percentage of total ICD billed was paid (top 10 ICD codes)
SELECT icd_code,
	SUM(billed_amount) AS total_billed_amount,
	SUM(paid_amount) AS total_paid_amount,
    ROUND(SUM(paid_amount)/SUM(billed_amount) * 100, 0) AS percentage_paid
FROM claims
GROUP BY icd_code 
ORDER BY total_paid_amount DESC
LIMIT 10;

# Identify CPT codes with a high paid amount per claim (average_paid_per_claim = total_paid_amount ÷ claim_count)
SELECT cpt_code,
	ROUND(SUM(paid_amount) / COUNT(claim_id), 0) AS average_paid_per_claim 
FROM claims
GROUP BY cpt_code 
ORDER BY average_paid_per_claim DESC

# Calculate total paid amount per member
SELECT member_id,
	SUM(paid_amount) AS total_paid
FROM claims
GROUP BY member_id;

# Identify the top 5-10 highest cost members
SELECT member_id,
	SUM(paid_amount) AS total_paid
FROM claims
GROUP BY member_id
ORDER BY total_paid DESC
LIMIT 10;

# For each high cost member, break down which claim types (inpatient, outpatient, ER, pharmacy) drive their costs
WITH highest_cost AS (
	SELECT member_id,
		SUM(paid_amount) AS total_paid
	FROM claims
	GROUP BY member_id
	ORDER BY total_paid DESC
	LIMIT 10
)
SELECT highest_cost.member_id,
	claims.claim_type,
	SUM(paid_amount) AS cost_claim,
    highest_cost.total_paid
FROM claims
JOIN highest_cost
ON claims.member_id = highest_cost.member_id
GROUP BY highest_cost.member_id, claims.claim_type, highest_cost.total_paid
ORDER BY highest_cost.total_paid DESC;

# Billed vs Paid Ratio (Desc.)
SELECT provider_id,
	claim_type,
    cpt_code,
    (paid_amount / billed_amount) AS paid_ratio
FROM claims
ORDER BY paid_ratio DESC;

# Billed vs Paid Ratio (Asc.)
SELECT provider_id,
	claim_type,
    cpt_code,
    (paid_amount / billed_amount) AS paid_ratio
FROM claims
ORDER BY paid_ratio ASC;

# Average ratio per claim for billed vs paid ratio (claim type)
WITH ratios AS (
	SELECT claim_type,
		(paid_amount / billed_amount) AS paid_ratio
	FROM claims
	ORDER BY claim_type ASC
)
SELECT ratios.claim_type,
	AVG(ratios.paid_ratio) AS avg_paid_ratio
FROM ratios
GROUP BY ratios.claim_type;

# Average ratio per claim for billed vs paid ratio (provider)
WITH ratios AS (
	SELECT provider_id,
		(paid_amount / billed_amount) AS paid_ratio
	FROM claims
	ORDER BY provider_id ASC
)
SELECT ratios.provider_id,
	AVG(ratios.paid_ratio) AS avg_paid_ratio
FROM ratios
GROUP BY ratios.provider_id;
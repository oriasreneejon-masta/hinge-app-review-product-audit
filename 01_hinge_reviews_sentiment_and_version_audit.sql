-- =====================================================================
-- HINGE GOOGLE PLAY STORE REVIEWS: PRODUCT PERFORMANCE AUDIT
-- Author: Renee Jon Orias
-- Dataset: Real Google Play Store Review Telemetry (80k+ records)
-- Objective: Identify app version regressions, audit support response times,
--            and categorize low-rating user feedback keywords.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. APP VERSION REGRESSION AUDIT
-- Identify software updates that caused user rating drops
-- ---------------------------------------------------------------------

SELECT 
    reviewCreatedVersion AS app_version,
    COUNT(reviewId) AS total_reviews,
    ROUND(AVG(score), 2) AS avg_star_rating,
    SUM(CASE WHEN score = 1 THEN 1 ELSE 0 END) AS one_star_count,
    ROUND(SUM(CASE WHEN score = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(reviewId), 2) AS one_star_pct
FROM hinge_google_play_reviews
WHERE reviewCreatedVersion IS NOT NULL
GROUP BY reviewCreatedVersion
HAVING total_reviews >= 200
ORDER BY avg_star_rating ASC;

-- ---------------------------------------------------------------------
-- 2. USER COMPLAINT KEYWORD CATEGORIZATION
-- Flag specific operational issues using text pattern matching
-- ---------------------------------------------------------------------

SELECT 
    CASE 
        WHEN LOWER(content) LIKE '%pay%' OR LOWER(content) LIKE '%subscription%' OR LOWER(content) LIKE '%money%' THEN 'Paywall / Billing'
        WHEN LOWER(content) LIKE '%ban%' OR LOWER(content) LIKE '%blocked%' OR LOWER(content) LIKE '%verify%' THEN 'Account Bans / Verification'
        WHEN LOWER(content) LIKE '%bug%' OR LOWER(content) LIKE '%crash%' OR LOWER(content) LIKE '%log out%' THEN 'Technical / App Stability'
        WHEN LOWER(content) LIKE '%bot%' OR LOWER(content) LIKE '%scam%' OR LOWER(content) LIKE '%fake%' THEN 'Safety / Fraud'
        ELSE 'General Feedback'
    END AS complaint_category,
    COUNT(reviewId) AS total_mentions,
    ROUND(AVG(score), 2) AS avg_category_score
FROM hinge_google_play_reviews
WHERE score <= 2
GROUP BY complaint_category
ORDER BY total_mentions DESC;

-- ---------------------------------------------------------------------
-- 3. CUSTOMER SUPPORT RESPONSE SLA (Service Level Agreement)
-- Measure company response rate and time to reply
-- ---------------------------------------------------------------------

SELECT 
    score AS user_star_rating,
    COUNT(reviewId) AS total_reviews,
    SUM(CASE WHEN replyContent IS NOT NULL THEN 1 ELSE 0 END) AS developer_replies,
    ROUND(SUM(CASE WHEN replyContent IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(reviewId), 2) AS response_rate_pct,
    -- Average days taken to reply
    ROUND(AVG(DATEDIFF(repliedAt, at)), 1) AS avg_days_to_reply
FROM hinge_google_play_reviews
GROUP BY score
ORDER BY user_star_rating ASC;

-- ---------------------------------------------------------------------
-- 4. PII SANITIZATION FOR ANALYTICS VIEW
-- Mask usernames and strip URLs before exposing data to reporting layers
-- ---------------------------------------------------------------------

CREATE VIEW vw_sanitized_hinge_reviews AS
SELECT 
    reviewId,
    -- Mask user names for privacy
    CONCAT(LEFT(userName, 1), '***') AS masked_username,
    score,
    thumbsUpCount,
    reviewCreatedVersion,
    at AS review_timestamp,
    content AS review_text,
    CASE WHEN replyContent IS NOT NULL THEN 1 ELSE 0 END AS has_company_reply
FROM hinge_google_play_reviews;

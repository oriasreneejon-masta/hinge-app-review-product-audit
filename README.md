<p align="center">
  <img width="2166" height="750" alt="hingelogo3" src="https://github.com/user-attachments/assets/542ec1a8-af43-41c2-846e-c1254d7f2899" />
</p>

# Hinge App Store Reviews: Product Health & Release Audit

## Business Overview
* **Full Dataset:** [Hinge Google Play Store Review Dataset](https://www.kaggle.com/datasets/shivkumarganesh/hinge-google-play-store-review/data) on Kaggle (~89k rows)
* **Sample Schema Preview:** [`data/sample_hinge_reviews.csv`](data/sample_hinge_reviews.csv)
User reviews on app marketplaces provide immediate signals about app stability, feature reception, and customer support performance. This repository analyzes 80,000+ real-world Google Play Store reviews for Hinge to track software version performance, flag operational complaints, and evaluate developer support response rates.

Data Source: [Hinge Google Play Store Review Dataset](https://www.kaggle.com/datasets/shivkumarganesh/hinge-google-play-store-review/data) on Kaggle.

---

## Key Analytics & Audit Findings

| Audit Focus | Business Question | Query Technique |
| :--- | :--- | :--- |
| **Version Regression** | Which app updates correlates with drops in user ratings? | Aggregated `AVG(score)` and 1-star percentages grouped by `reviewCreatedVersion`. |
| **Feedback Categorization** | What are the primary reasons for 1-star and 2-star ratings? | Applied `CASE` string matching (`LIKE`) to categorize feedback into Billing, Stability, Bans, and Fraud. |
| **Support SLA Tracking** | How quickly and frequently does the support team respond to negative reviews? | Measured `DATEDIFF(repliedAt, at)` and calculated response rates by star tier. |
| **PII Governance** | How do we share review data with analytics teams safely? | Constructed `vw_sanitized_hinge_reviews` to mask usernames and scrub profile URLs. |

---

## Data Dictionary

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `reviewId` | String | Unique identifier for each review record. |
| `masked_username` | String | Anonymized user account name. |
| `score` | Integer | Star rating assigned by user (1 to 5). |
| `reviewCreatedVersion` | String | App software version installed when review was submitted. |
| `review_timestamp` | Datetime | Date and time the review was created. |
| `has_company_reply` | Binary (0/1) | Flag indicating whether the Hinge support team posted a response. |

---

## Tech Stack
* **Language:** SQL (MySQL / PostgreSQL Compatible)
* **Dataset:** Real-World Open-Source Telemetry (Kaggle)
* **Analytics Focus:** Product Quality, App Version Regressions, SLA Tracking

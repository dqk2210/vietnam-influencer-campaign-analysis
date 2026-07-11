-- 1: Data quality check

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT id) AS unique_creators
FROM influencers_cleaned;

-- 2: Missing score check

SELECT
    SUM(CASE WHEN broadcast_score IS NULL THEN 1 ELSE 0 END) AS missing_broadcast_score,
    SUM(CASE WHEN commerce_score IS NULL THEN 1 ELSE 0 END) AS missing_commerce_score,
    SUM(CASE WHEN collab_score IS NULL THEN 1 ELSE 0 END) AS missing_collab_score
FROM influencers_cleaned;

-- 3: Market overview

SELECT
    COUNT(DISTINCT id) AS total_creators,
    SUM(followers_num) AS total_followers,
    AVG(median_views_num) AS avg_median_views,
    AVG(engagement_pct) AS avg_engagement,
    AVG(price_num) AS avg_price,
    AVG(cpv) AS avg_cpv,
    AVG(view_rate_pct) AS avg_view_rate
FROM influencers_cleaned;

-- 4: Creator segment performance

SELECT
    creator_segment,
    COUNT(DISTINCT id) AS total_creators,
    AVG(followers_num) AS avg_followers,
    AVG(median_views_num) AS avg_median_views,
    AVG(engagement_pct) AS avg_engagement,
    AVG(price_num) AS avg_price,
    AVG(cpv) AS avg_cpv
FROM influencers_cleaned
GROUP BY creator_segment
ORDER BY total_creators DESC;

-- 5: Potential group distribution

SELECT
    potential_group,
    COUNT(DISTINCT id) AS total_creators,
    AVG(median_views_num) AS avg_median_views,
    AVG(engagement_pct) AS avg_engagement,
    AVG(price_num) AS avg_price,
    AVG(cpv) AS avg_cpv
FROM influencers_cleaned
GROUP BY potential_group
ORDER BY total_creators DESC;

-- 6: Category distribution

SELECT
    content_category,
    COUNT(DISTINCT id) AS total_creators
FROM creator_content_category
GROUP BY content_category
ORDER BY total_creators DESC;


-- 7: Category performance

SELECT
    c.content_category,
    COUNT(DISTINCT i.id) AS total_creators,
    AVG(i.followers_num) AS avg_followers,
    AVG(i.median_views_num) AS avg_median_views,
    AVG(i.engagement_pct) AS avg_engagement,
    AVG(i.price_num) AS avg_price,
    AVG(i.cpv) AS avg_cpv,
    AVG(i.broadcast_score) AS avg_broadcast_score,
    AVG(i.commerce_score) AS avg_commerce_score,
    AVG(i.collab_score) AS avg_collab_score
FROM influencers_cleaned i
JOIN creator_content_category c
    ON i.id = c.id
GROUP BY c.content_category
ORDER BY total_creators DESC;


-- 8: Top cost-efficient creators

SELECT
    id,
    name,
    creator_segment,
    followers_num,
    median_views_num,
    engagement_pct,
    price_num,
    cpv,
    potential_group
FROM influencers_cleaned
WHERE cpv IS NOT NULL
ORDER BY cpv ASC, median_views_num DESC
LIMIT 20;


-- 9: Top creators for awareness campaign

SELECT
    id,
    name,
    followers_num,
    median_views_num,
    engagement_pct,
    broadcast_score,
    price_num,
    cpv,
    potential_group
FROM influencers_cleaned
WHERE broadcast_score IS NOT NULL
ORDER BY broadcast_score DESC, median_views_num DESC, cpv ASC
LIMIT 20;


-- 10: Top creators by category using window function

SELECT *
FROM (
    SELECT
        c.content_category,
        i.id,
        i.name,
        i.followers_num,
        i.median_views_num,
        i.engagement_pct,
        i.price_num,
        i.cpv,
        i.potential_group,
        ROW_NUMBER() OVER (
            PARTITION BY c.content_category
            ORDER BY i.cpv ASC, i.median_views_num DESC, i.engagement_pct DESC
        ) AS rank_in_category
    FROM influencers_cleaned i
    JOIN creator_content_category c
        ON i.id = c.id
    WHERE i.cpv IS NOT NULL
) AS ranked_creators
WHERE rank_in_category <= 10
ORDER BY content_category, rank_in_category;

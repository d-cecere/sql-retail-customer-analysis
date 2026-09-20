-- ============================================================
-- RETAIL CUSTOMER BEHAVIOR & ANALYSIS
-- Database: PostgreSQL (Neon.tech)
-- Author: Domenico Cecere
-- ============================================================

-- 1. Analisi delle performance per Tipologia di Dispositivo (Device Type)
-- Valuta spesa media, tempo di permanenza e tasso di conversione per device
SELECT
    device_type,
    COUNT(customer_id) AS n_clienti,
    ROUND(AVG(total_spent_usd)::numeric, 2) AS spesa_media,
    ROUND(AVG(time_spent_minutes)::numeric, 1) AS tempo_medio_minuti,
    ROUND(AVG(items_purchased::numeric / NULLIF(items_viewed, 0)), 2) AS tasso_conversione
FROM customer_behavior
WHERE total_spent_usd > 0
GROUP BY device_type
ORDER BY spesa_media DESC;


-- 2. Segmentazione Demografica per Fasce d'Età
-- Calcola il fatturato totale e la spesa media per cluster di clienti
SELECT
    CASE
        WHEN age < 30 THEN 'Young (<30)'
        WHEN age BETWEEN 30 AND 49 THEN 'Adult (30-49)'
        ELSE 'Senior (50+)'
    END AS fascia_eta,
    COUNT(customer_id) AS totale_clienti,
    SUM(total_spent_usd) AS fatturato_totale,
    ROUND(AVG(total_spent_usd)::numeric, 2) AS spesa_media
FROM customer_behavior
GROUP BY 1
ORDER BY fatturato_totale DESC;


-- 3. Analisi Categorie di Prodotto ad Alto Fatturato
-- Identifica le categorie top con fatturato complessivo superiore a $50.000
SELECT
    product_category,
    COUNT(customer_id) AS numero_acquisti,
    SUM(items_purchased) AS totale_articoli_venduti,
    SUM(total_spent_usd) AS fatturato_totale
FROM customer_behavior
GROUP BY product_category
HAVING SUM(total_spent_usd) > 50000
ORDER BY fatturato_totale DESC;

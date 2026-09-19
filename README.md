# 📊 Retail Customer Behavior Analysis (SQL Baseline)

## 📌 Project Overview
Questo progetto esplora ed analizza il comportamento d'acquisto di **1.800 clienti e-commerce** per identificare i principali driver di fatturato, le dinamiche di conversione sui diversi dispositivi e i segmenti demografici più redditizi.

* **Dataset:** [Online Shopping Customer Behavior (Kaggle)](https://www.kaggle.com/datasets/kojibrand/name-online-shopping-customer-behavior/data)
* **Environment:** PostgreSQL gestito tramite istanza cloud **Neon.tech**

---

---

## 🛠️ Tech Stack & Concepts
* **Database Engine:** PostgreSQL
* **SQL Core Concepts:**
  * Aggregazioni di base ed avanzate (`SUM`, `AVG`, `COUNT`)
  * Data Type Casting (`::numeric`) per il calcolo dei tassi di conversione senza perdita di decimali
  * Arrotondamento dinamico per facilitare la reportistica (`ROUND`)
  * Segmentazione condizionale (`CASE WHEN`)
  * Filtraggio sui gruppi aggregati (`HAVING`)

---

## 🔍 Key Business Queries & Insights

<details>
<summary><b>1. Performance & Conversione per Dispositivo</b></summary>

<br>

**Obiettivo di Business:** Identificare su quali dispositivi i clienti spendono di più e dove si registra il miglior tasso di conversione.

```sql
SELECT
  device_type,
  COUNT(customer_id) AS n_clienti,
  ROUND(AVG(total_spent_usd)::numeric, 2) AS spesa_media,
  ROUND(AVG(time_spent_minutes)::numeric, 1) AS tempo_medio_minuti,
  ROUND(AVG(items_purchased::numeric / items_viewed), 2) AS tasso_conversione
FROM customer_behavior
WHERE total_spent_usd > 0
GROUP BY device_type
ORDER BY spesa_media DESC;
```

</details>

<details>
<summary><b>2. Segmentazione Demografica per Fascia d'Età</b></summary>

<br>

**Obiettivo di Business:** Categorizzare la base clienti in 3 macro-target (Young, Adult, Senior) e valutarne la distribuzione del fatturato totale.

```sql
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
```

</details>

<details>
<summary><b>3. Categorie di Prodotto ad Alto Valore</b></summary>

<br>

**Obiettivo di Business:** Isolamento delle categorie merceologiche con performance rilevanti (fatturato > $50.000) per ottimizzare la gestione delle scorte e della logistica.

```sql
SELECT
  product_category,
  COUNT(customer_id) AS numero_acquisti,
  SUM(items_purchased) AS totale_articoli_venduti,
  SUM(total_spent_usd) AS fatturato_totale
FROM customer_behavior
GROUP BY product_category
HAVING SUM(total_spent_usd) > 50000
ORDER BY fatturato_totale DESC;
```

</details>

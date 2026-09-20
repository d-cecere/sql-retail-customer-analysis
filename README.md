# 📊 Retail Customer Behavior Analysis (SQL Baseline)

## 📌 Project Overview
Questo progetto esplora ed analizza il comportamento d'acquisto di **1.800 clienti e-commerce** per identificare i principali driver di fatturato, le dinamiche di conversione sui diversi dispositivi e i segmenti demografici più redditizi.

* **Dataset:** [Online Shopping Customer Behavior (Kaggle)](https://www.kaggle.com/datasets/kojibrand/name-online-shopping-customer-behavior/data)
* **Environment:** PostgreSQL gestito tramite istanza cloud **Neon.tech**

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

**Risultato:**

| device_type | n_clienti | spesa_media | tempo_medio_osservazione | tasso_conversione |
|---|---|---|---|---|
| Tablet | 637 | 794.73 | 59.2 | 0.39 |
| Mobile | 563 | 774.69 | 60.8 | 0.48 |
| Desktop | 600 | 764.86 | 61.8 | 0.44 |

📥 [Scarica risultati completi (CSV)](results/output_device_analysis.csv)

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

**Risultato:**

| fascia_eta | totale_clienti | fatturato_totale | spesa_media |
|---|---|---|---|
| Adult (30-49) | 771 | 604,430 | 783.96 |
| Senior (50+) | 583 | 464,061 | 795.99 |
| Young (<30) | 446 | 332,815 | 746.22 |

📥 [Scarica risultati completi (CSV)](results/output_demographic_segmentation.csv)

</details>

<details>
<summary><b>3. Categorie di Prodotto ad Alto Valore</b></summary>

<br>

**Obiettivo di Business:** Isolare le categorie merceologiche con fatturato superiore alla media di categoria, per concentrare la gestione delle scorte e della logistica sui prodotti più profittevoli.

```sql
WITH fatturato_per_categoria AS (
  SELECT
    product_category,
    COUNT(customer_id) AS numero_acquisti,
    SUM(items_purchased) AS totale_articoli_venduti,
    SUM(total_spent_usd) AS fatturato_totale
  FROM customer_behavior
  GROUP BY product_category
),
soglia AS (
  SELECT AVG(fatturato_totale) AS fatturato_medio_soglia
  FROM fatturato_per_categoria
)
SELECT
  f.product_category,
  f.numero_acquisti,
  f.totale_articoli_venduti,
  f.fatturato_totale,
  ROUND(s.fatturato_medio_soglia::numeric, 2) AS fatturato_medio_soglia
FROM fatturato_per_categoria f
CROSS JOIN soglia s
WHERE f.fatturato_totale > s.fatturato_medio_soglia
ORDER BY f.fatturato_totale DESC;
```

**Risultato:**

| product_category | numero_acquisti | totale_articoli_venduti | fatturato_totale | fatturato_medio_soglia |
|---|---|---|---|---|
| Clothing | 345 | 1,639 | 285,868 | 233,551.00 |
| Sports | 311 | 1,362 | 237,449 | 233,551.00 |
| Electronics | 294 | 1,310 | 233,801 | 233,551.00 |

📥 [Scarica risultati completi (CSV)](results/output_category_analysis.csv)

</details>


## 📈 Key Insights & Business Recommendations

### 1. Optimization by Device Type
* **Insight:** Tablet genera la spesa media più alta ($794.73) ma il tasso di conversione più basso (0.39), suggerendo un problema di "browsing intent" — molti utenti visualizzano prodotti senza completare l'acquisto. Mobile, al contrario, registra il miglior tasso di conversione (0.48) pur con la spesa media più bassa dei tre. Desktop si posiziona in una via di mezzo su entrambe le metriche.
* **Recommendation:** Investigare le cause del basso tasso di conversione su Tablet (UX del checkout, tempi di caricamento, layout non ottimizzato) dato l'alto valore medio degli utenti su questo dispositivo. Su Mobile, dove la conversione è già buona, puntare su azioni per aumentare lo scontrino medio (es. cross-selling, bundle).

### 2. Demographic Value & Customer Targeting
* **Insight:** La fascia **Adult (30-49)** genera il fatturato totale più alto ($604,430) grazie al maggior numero di clienti (771), ma è il segmento **Senior (50+)** ad avere lo scontrino medio più elevato ($795.99 vs $783.96 di Adult), pur con una base clienti più piccola (583). Young (<30) è il segmento con minor valore su entrambe le metriche.
* **Recommendation:** Mantenere il focus di acquisizione su Adult per il volume di fatturato, ma sviluppare campagne dedicate a Senior — segmento più piccolo ma a maggior valore per cliente, quindi ad alto potenziale se ampliato.

### 3. High-Value Product Categories
* **Insight:** Usando come soglia il fatturato medio tra tutte le categorie ($233,551), solo 3 categorie su 6 lo superano: **Clothing** guida nettamente ($285,868, +22% sulla media), seguita da **Sports** ed **Electronics**, quest'ultima sopra soglia per un margine ristretto (+$250). Le restanti 3 categorie (Beauty, Books, Home) si posizionano sotto la media, con Home più distante dalla soglia (-$25,858).
* **Recommendation:** Concentrare priorità di stock e visibilità su Clothing e Sports, categorie con margine più solido sopra la media. Monitorare Electronics nel tempo: essendo sopra soglia per un margine minimo, è la categoria più a rischio di scendere sotto la media al variare della stagionalità o della domanda.

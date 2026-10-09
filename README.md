# 🌦️ Real-Time Weather Analytics Project

## 📌 Project Overview

This project is an end-to-end **real-time weather data analytics pipeline** built to collect, store, analyze, and visualize weather data for five major Indian cities.

Weather data is collected automatically every **15 minutes** using the **Open-Meteo API**, processed using Python, stored in PostgreSQL, analyzed using SQL, and visualized through an interactive Power BI dashboard.

The project demonstrates the complete workflow of a Data Analyst project — from **API data collection and database storage to SQL analysis and business-focused visualization**.

---

## 🎯 Project Objectives

* Collect real-time weather data from an external API.
* Automate data collection at 15-minute intervals.
* Collect weather information for multiple cities.
* Store structured data in PostgreSQL.
* Perform data cleaning and validation.
* Analyze weather trends using SQL.
* Apply SQL concepts such as CTEs, subqueries, window functions, and correlation analysis.
* Build an interactive Power BI dashboard.
* Generate meaningful insights from temperature, humidity, precipitation, wind speed, and weather conditions.

---

## 🏙️ Cities Covered

The project currently collects weather data for:

* Mumbai
* Pune
* Hyderabad
* Chennai
* Delhi

---

## 🛠️ Technologies Used

| Technology         | Purpose                                      |
| ------------------ | -------------------------------------------- |
| **Python**         | API data collection, cleaning and automation |
| **Requests**       | API communication                            |
| **Pandas**         | Data processing and transformation           |
| **PostgreSQL**     | Data storage and querying                    |
| **SQL**            | Data analysis and insight generation         |
| **Power BI**       | Interactive dashboard and visualization      |
| **Open-Meteo API** | Weather and geocoding data source            |

---

## 🔄 Project Architecture

```text
                    Open-Meteo API
                          │
                          ▼
                 Python Data Collector
                          │
              ┌───────────┴───────────┐
              │                       │
        Geocoding API           Weather API
              │                       │
              └───────────┬───────────┘
                          │
                          ▼
                  Data Cleaning
                          │
                          ▼
                    PostgreSQL
                          │
                          ▼
                    SQL Analysis
                          │
                          ▼
                     Power BI
                          │
                          ▼
                 Interactive Dashboard
```

---

## 📡 Data Collection

The Python pipeline uses two Open-Meteo APIs:

### 1. Geocoding API

The geocoding API converts a city name into its corresponding latitude and longitude.

```text
City Name
   ↓
Geocoding API
   ↓
Latitude + Longitude
```

### 2. Weather API

The coordinates are then passed to the weather API to retrieve current weather information.

The project collects:

* Temperature
* Relative Humidity
* Precipitation
* Wind Speed
* Cloud Cover
* Weather Code
* Timestamp
* City

---

## ⏱️ Automated Data Collection

The Python script runs continuously and collects weather information every **15 minutes**.

```text
Collect Data
     ↓
Clean & Validate
     ↓
Store in PostgreSQL
     ↓
Wait 15 Minutes
     ↓
Collect Again
```

The pipeline also includes retry handling for API failures and request timeouts.

---

## 🗄️ PostgreSQL Database

The collected weather data is stored in a PostgreSQL table:

```text
weather_data
```

Main fields include:

```text
id
timestamp
city
temperature
humidity
precipitation
wind_speed
cloud_cover
weather_code
```

A unique constraint on:

```text
(timestamp, city)
```

helps prevent duplicate weather records.

---

## 🧹 Data Cleaning & Validation

Before storing the data, the Python pipeline performs several checks:

* Removes leading/trailing spaces from city names.
* Removes records with missing timestamp or city.
* Removes duplicate `(timestamp, city)` combinations.
* Checks whether all expected cities were successfully collected.
* Handles API failures using retry logic.
* Uses request timeouts to prevent indefinite API calls.

---

# 📊 SQL Analysis

The project contains a dedicated SQL file documenting the analytical work performed during the project.

The SQL analysis includes:

### Data Validation

* Database and table inspection
* Record counts
* Duplicate checks
* Missing data checks
* Collection completeness
* Missing-city detection

### Weather Analysis

* Average temperature by city
* Average humidity by city
* Average wind speed
* Total precipitation
* Temperature range
* City-level comparisons

### Time-Series Analysis

* Temperature changes over time
* `LAG()` window function
* Largest temperature increase
* Largest temperature decrease
* Hourly temperature analysis
* Temperature variation by city

### Advanced SQL

The project also uses:

* CTEs
* Subqueries
* Window functions
* `ROW_NUMBER()`
* Aggregations
* `GROUP BY`
* `HAVING`
* `ORDER BY`
* Correlation analysis

### Example Analytical Question

One of the analytical questions answered using SQL was:

> **Which city has the second-highest average temperature?**

The analysis identified:

**Delhi — 31.98°C**

---

# 📈 Power BI Dashboard

The analyzed weather data was connected to Power BI to create an interactive dashboard.

The dashboard includes KPIs and visualizations covering:

* Average Temperature
* Average Humidity
* Average Wind Speed
* Temperature trends over time
* Average Temperature by City
* City comparisons
* Temperature relationships
* Weather-related analysis

The dashboard is designed to provide a quick overview of current and historical weather patterns across the five cities.

---

# 🔎 Key Insights

Some of the observations identified during the analysis include:

* Chennai recorded the highest average temperature among the five cities.
* Pune recorded the lowest average temperature among the five cities.
* Delhi ranked second based on average temperature.
* Temperature and humidity showed a strong negative correlation across the analyzed cities.
* Weather conditions varied considerably between cities.
* The collected data can be used to monitor temperature, humidity, wind, and precipitation patterns over time.

---

# 📂 Project Files

The repository contains the complete project files used during development:


Weather Analytics Project/
│
├── Weather_Collector.py
├── Weather_Project_Queries.sql
├── Real_Time_Weather_Analysis.pbix
├── README.md
├── test_postgresql.sql
├── Weather_Data.csv
└── Screenshot_1 (Weather_Project_Page1)
└── Screenshot_2 (Weather_Project_Page2)


# 🚀 How the Project Works

### Step 1 — Run the Python Collector

The Python script connects to the Open-Meteo APIs and retrieves weather information for the five cities.

### Step 2 — Process the Data

Pandas is used to create and clean the weather records.

### Step 3 — Store the Data

The processed records are inserted into PostgreSQL.

### Step 4 — Analyze the Data

SQL queries are used to perform data validation, statistical analysis, time-series analysis, and city-level comparisons.

### Step 5 — Visualize the Results

The analyzed data is presented through an interactive Power BI dashboard.

---

# 💡 Skills Demonstrated

This project demonstrates practical experience in:

* Python
* API Integration
* Data Collection
* Data Cleaning
* Pandas
* PostgreSQL
* SQL
* CTEs
* Subqueries
* Window Functions
* Time-Series Analysis
* Correlation Analysis
* Power BI
* Data Visualization
* Dashboard Development
* Data Pipeline Automation

---

# 🎓 Project Learning

Through this project, I gained practical experience in building an end-to-end data analytics workflow rather than working only with static datasets.

The project helped me understand how to:

**Collect → Clean → Store → Analyze → Visualize → Generate Insights**

using a combination of REST API, Python, PostgreSQL, SQL, and Power BI.

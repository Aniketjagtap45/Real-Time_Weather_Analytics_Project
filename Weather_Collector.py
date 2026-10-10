import requests
import pandas as pd
import psycopg2
import os
import time
from dotenv import load_dotenv

def get_weather_data(city):

    # --------------------------------
    # Retry settings
    # --------------------------------

    max_retries = 3

    # --------------------------------
    # 1. Geocoding API
    # --------------------------------

    geocode_url = "https://geocoding-api.open-meteo.com/v1/search"

    geocode_params = {
        "name": city,
        "count": 1
    }

    for attempt in range(1, max_retries + 1):

        try:

            geocode_response = requests.get(
                geocode_url,
                params=geocode_params,
                timeout=10
            )

            if geocode_response.status_code == 200:
                break

            print(
                f"{city} - Geocoding failed "
                f"(Attempt {attempt}/{max_retries})"
            )

        except requests.exceptions.RequestException as e:

            print(
                f"{city} - Geocoding error "
                f"(Attempt {attempt}/{max_retries}): {e}"
            )

        if attempt < max_retries:
            time.sleep(5)

    else:

        print(f"{city} - Geocoding failed after {max_retries} attempts")
        return None


    # --------------------------------
    # Check city
    # --------------------------------

    geocode_data = geocode_response.json()

    if (
        "results" not in geocode_data
        or len(geocode_data["results"]) == 0
    ):

        print("City not found:", city)
        return None


    # --------------------------------
    # Get coordinates
    # --------------------------------

    latitude = geocode_data["results"][0]["latitude"]
    longitude = geocode_data["results"][0]["longitude"]

    print("City:", city)
    print("Latitude:", latitude)
    print("Longitude:", longitude)


    # --------------------------------
    # 2. Weather API
    # --------------------------------

    weather_url = "https://api.open-meteo.com/v1/forecast"

    weather_params = {
        "latitude": latitude,
        "longitude": longitude,
        "current": (
            "temperature_2m,"
            "relative_humidity_2m,"
            "precipitation,"
            "wind_speed_10m,"
            "cloud_cover,"
            "weather_code"
        ),
        "timezone": "Asia/Kolkata"
    }


    # --------------------------------
    # Retry Weather API
    # --------------------------------

    for attempt in range(1, max_retries + 1):

        try:

            response = requests.get(
                weather_url,
                params=weather_params,
                timeout=10
            )

            if response.status_code == 200:
                break

            print(
                f"{city} - Weather API failed "
                f"(Attempt {attempt}/{max_retries})"
            )

        except requests.exceptions.RequestException as e:

            print(
                f"{city} - Weather API error "
                f"(Attempt {attempt}/{max_retries}): {e}"
            )

        if attempt < max_retries:
            time.sleep(5)

    else:

        print(
            f"{city} - Weather API failed "
            f"after {max_retries} attempts"
        )

        return None


    # --------------------------------
    # Get weather data
    # --------------------------------

    data = response.json()

    weather = data["current"]


    # --------------------------------
    # 3. Create weather record
    # --------------------------------

    weather_record = {

        "timestamp": weather["time"],

        "city": city,

        "temperature": weather["temperature_2m"],

        "humidity": weather["relative_humidity_2m"],

        "precipitation": weather["precipitation"],

        "wind_speed": weather["wind_speed_10m"],

        "cloud_cover": weather["cloud_cover"],

        "weather_code": weather["weather_code"]
    }


    # --------------------------------
    # 4. Create DataFrame
    # --------------------------------

    weather_df = pd.DataFrame([weather_record])

    weather_df["timestamp"] = pd.to_datetime(
        weather_df["timestamp"]
    )

    return weather_df

# ==============================================
# Collect and store weather data
# ==============================================

def collect_and_store_weather():

    print("\n===================================")
    print("Starting weather data collection")
    print("===================================")


    # --------------------------------
    # Cities
    # --------------------------------

    cities = [
        "Mumbai",
        "Pune",
        "Hyderabad",
        "Chennai",
        "Delhi"
    ]


    # --------------------------------
    # Collect data
    # --------------------------------

    all_weather_data = []

    for city in cities:

        print(f"\nCollecting weather data for {city}...")

        weather_data = get_weather_data(city)

        if weather_data is not None:

            all_weather_data.append(weather_data)

    if all_weather_data:
        all_weather_df=pd.concat(all_weather_data, ignore_index=True)
        #print(all_weather_df)
    else:
        print("No weather data collected.")

# --------------------------------
# Check collection completeness
# --------------------------------

    expected_cities = set(cities)
    collected_cities = set(all_weather_df["city"])

    missing_cities = expected_cities - collected_cities

    print("\nCollection Summary")
    print("------------------")
    print("Expected cities :", len(expected_cities))
    print("Collected cities:", len(collected_cities))

    if missing_cities:
        print("Missing cities  :", missing_cities)
    else:
        print("All 5 cities collected successfully!")

# --------------------------------
# Clean the collected data
# --------------------------------
    all_weather_df["city"]=all_weather_df["city"].str.strip()

    all_weather_df = all_weather_df.dropna(subset=["timestamp", "city"])

    all_weather_df = all_weather_df.drop_duplicates(subset=["timestamp", "city"],keep="last")


# --------------------------------
# Connect to PostgreSQL
# --------------------------------
    load_dotenv()
    connection = psycopg2.connect(
        host=os.getenv("DB_HOST"),
        database=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        port=os.getenv("DB_PORT","5432")
    )

    cursor = connection.cursor()

    print("PostgreSQL connected successfully!")


    # --------------------------------
    # Insert weather data
    # --------------------------------

    insert_query = '''
    INSERT INTO weather_data
    (timestamp, city, temperature, humidity, precipitation,
    wind_speed, cloud_cover, weather_code)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
    ON CONFLICT (timestamp, city) DO NOTHING;
    '''

    for _, row in all_weather_df.iterrows():

        cursor.execute(
            insert_query,
            (
                row["timestamp"],
                row["city"],
                row["temperature"],
                row["humidity"],
                row["precipitation"],
                row["wind_speed"],
                row["cloud_cover"],
                row["weather_code"]
            )
        )


    # --------------------------------
    # Save changes
    # --------------------------------

    connection.commit()

    print("Weather data stored successfully in PostgreSQL!")


    # --------------------------------
    # Close PostgreSQL connection
    # --------------------------------

    cursor.close()
    connection.close()

    print("PostgreSQL connection closed!")

# ==============================================
# Run automatically every 15 minutes
# ==============================================

while True:

    try:

        collect_and_store_weather()

        print("\nNext collection will start after 15 minutes.")

        time.sleep(15 * 60)

    except Exception as e:

        print("\nError occurred:", e)

        print("Retrying after 1 minute...")

        time.sleep(60)
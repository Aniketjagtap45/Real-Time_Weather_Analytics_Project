import psycopg2

# Connect to PostgreSQL
connection = psycopg2.connect(
    host="localhost",
    database="WeatherDB",
    user="postgres",
    password="Aniket@45",
    port="5432"
)

print("PostgreSQL connection successful!")

cursor = connection.cursor()

# Create weather table
create_table_query = """
CREATE TABLE IF NOT EXISTS weather_data (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP,
    city VARCHAR(100),
    temperature DECIMAL(5,2),
    humidity DECIMAL(5,2),
    precipitation DECIMAL(5,2),
    wind_speed DECIMAL(5,2)
);
"""

cursor.execute(create_table_query)

connection.commit()

print("Weather table created successfully!")

cursor.close()
connection.close()
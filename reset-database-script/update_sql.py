import os
import psycopg2
import pandas as pd
from getpass import getpass

# In order to run this program first run:
# pip install pandas psycopg2
# python update_sql.py
# Note that timesheets, transactions, and sale_items will take awhile
# if you only want to update one table move all csv-files except the one you want to update
# to a different folder so that you don't have to redownload them
 
# Database connection configuration (without the password)
db_config = {
    'host': 'csce-315-db.engr.tamu.edu',
    'port': 5432,
    'user': 'csce331_12',
    'database': 'csce331_12'
}

# Prompt user for password securely
db_config['password'] = getpass(prompt="Enter your database password: ")

csv_directory = 'csv-files'

# Function to update the database from a CSV file
def update_db_from_csv(csv_file):
    try:
        # Extract table name from the filename (remove 'database_tables - ' and '.csv')
        filename = os.path.basename(csv_file)  # Get the filename
        table_name = filename.split(' - ')[1].replace('.csv', '')  # Extract table name
        
        # Read the CSV file into a DataFrame
        df = pd.read_csv(csv_file)

        # Ensure we have column names from the first row
        columns = df.columns.tolist()  # Get the column names from the first row
        
        # Create the SQL INSERT statement dynamically based on the column names
        columns_str = ', '.join(columns)
        placeholders = ', '.join(['%s'] * len(columns))  # Create placeholders for values
        
        sql_insert = f"INSERT INTO {table_name} ({columns_str}) VALUES ({placeholders})"
        sql_truncate = f"TRUNCATE TABLE {table_name}"  # SQL to clear the table

        conn = psycopg2.connect(**db_config)
        cursor = conn.cursor()

        # Step 1: Truncate the table (remove all existing rows)
        print(f"Truncating table '{table_name}'...")
        cursor.execute(sql_truncate)
        
        # Step 2: Insert new data from the CSV
        print(f"Inserting data into table '{table_name}' from {csv_file}...")
        for index, row in df.iterrows():
            cursor.execute(sql_insert, tuple(row))  
            
        conn.commit()
        cursor.close()
        conn.close()

        print(f"Successfully updated table '{table_name}' from {csv_file}")

    except Exception as e:
        print(f"Error updating {csv_file}: {e}")

# Function to process all CSV files in the folder
def process_csv_files():
    for filename in os.listdir(csv_directory):
        if filename.endswith('.csv'):
            csv_file = os.path.join(csv_directory, filename)
            update_db_from_csv(csv_file)

if __name__ == '__main__':
    process_csv_files()

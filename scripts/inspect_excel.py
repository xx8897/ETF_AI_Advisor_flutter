import pandas as pd
import os

def inspect_sector_column():
    """
    Inspects the '行業類別' column in the etf.xlsx file to see its unique values.
    """
    file_path = os.path.join(os.path.dirname(__file__), 'data', 'etf.xlsx')
    print(f"--- Inspecting Sector Column in: {file_path} ---")
    
    try:
        df = pd.read_excel(file_path, sheet_name='etf')
        
        if '行業類別' in df.columns:
            print("\nSUCCESS: Found '行業類別' column.")
            unique_values = df['行業類別'].unique()
            print("Unique values in this column are:")
            for value in unique_values:
                print(f"- '{value}'")
        else:
            print("\nERROR: '行業類別' column not found.")
            
    except Exception as e:
        print(f"\nERROR: An unexpected error occurred: {e}")

if __name__ == "__main__":
    inspect_sector_column()

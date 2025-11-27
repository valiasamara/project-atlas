import re
import pandas as pd
from pathlib import Path
from PIL import Image  # pip install pillow

EXCEL_PATH = Path(r"C:\Users\valak\Desktop\thesis\project-atlas\fixed_output.xlsx")
IMAGES_DIR = Path(r"C:\Users\valak\Desktop\thesis\images")

def main():
    # Ask user for the search word
    search_word = input("Enter a word to search for in captions: ").strip()
    if not search_word:
        print("No search word entered. Exiting.")
        return

    # Exact word match (case-insensitive)
    pattern = re.compile(rf"\b{re.escape(search_word)}\b", re.IGNORECASE)

    # Read Excel
    try:
        df = pd.read_excel(EXCEL_PATH)
    except Exception as e:
        print(f"Failed to read Excel at {EXCEL_PATH}\nError: {e}")
        return

    # Validate required columns
    required_cols = {"Image Path", "Text on Page"}
    if not required_cols.issubset(df.columns):
        print(f"Missing required columns. Found: {list(df.columns)}\nExpected at least: {required_cols}")
        return

    matches = []

    for _, row in df.iterrows():
        caption = str(row["Text on Page"])
        if pattern.search(caption):
            # Get only the filename from the Excel cell (works if it already contains a path too)
            filename = Path(str(row["Image Path"])).name
            img_path = (IMAGES_DIR / filename).resolve()
            matches.append((img_path, caption))

    if not matches:
        print("❌ No results found.")
        return

    print(f"\n✅ Found {len(matches)} result(s):\n")

    for img_path, caption in matches:
        print(f"🖼️ Image Path: {img_path}")
        print(f"📝 Caption: {caption}\n")

        if img_path.exists():
            try:
                # More reliable than os.startfile across setups
                Image.open(img_path).show()  # Opens in default viewer
            except Exception as e:
                print(f"⚠️ Could not open image with Pillow at {img_path}. Error: {e}")
        else:
            print(f"⚠️ Image not found at: {img_path}")
            # Helpful hints:
            if IMAGES_DIR.exists():
                # Show a couple of files to confirm we’re in the right folder
                sample = list(IMAGES_DIR.glob("*"))[:5]
                if sample:
                    print("Here are some files I DO see in your images folder:")
                    for s in sample:
                        print(" -", s.name)
            else:
                print(f"⚠️ Images directory does not exist: {IMAGES_DIR}")

if __name__ == "__main__":
    main()

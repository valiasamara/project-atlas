import fitz  # PyMuPDF
import os
import csv

# clean text: taking out the first  skip_lines
def clean_text(raw_lines, skip_lines=1):
    content_lines = raw_lines[skip_lines:]
    clean_lines = []
    for line in content_lines:
        stripped = line.strip()
        if stripped:
            clean_lines.append(stripped)
    return ' '.join(clean_lines)


# main function
def extract_images_and_text_by_page(pdf_path, image_folder, output_csv, skip_lines=1):
    if not os.path.exists(image_folder):
        os.makedirs(image_folder)

    doc = fitz.open(pdf_path)

    with open(output_csv, mode='w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["Image Path", "Text on Page"])

        for page_num in range(24, 417):
            page = doc.load_page(page_num)
            images = page.get_images(full=True)
            if not images:
                continue  # skip pages without images

            raw_lines = page.get_text().split('\n')
            text = clean_text(raw_lines, skip_lines)

            for img_index, img in enumerate(images):
                xref = img[0]
                base_image = doc.extract_image(xref)
                image_bytes = base_image["image"]
                image_ext = base_image["ext"]

                image_name = f"page_{page_num+1}_image_{img_index+1}.{image_ext}"
                image_path = os.path.join(image_folder, image_name)

                with open(image_path, 'wb') as f:
                    f.write(image_bytes)

                writer.writerow([image_path, text])

    print(f"✅ Done! Images and cleaned text written to: {output_csv}")


#paths
pdf_path = r"C:\Users\valak\Desktop\thesis\Color_Atlas_of_Forensic_Medicine_and_Patholo.pdf"
image_folder = r"C:\Users\valak\Desktop\thesis\images"
output_csv = r"C:\Users\valak\Desktop\thesis\fixed_output.csv"

# execute without the first lines
extract_images_and_text_by_page(pdf_path, image_folder, output_csv, skip_lines=2)

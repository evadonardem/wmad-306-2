import PyPDF2
path='e:\\wmad-306-2\\06_adopt_a_dog_Catayao\\adopt_a_dog_specs.pdf'
reader=PyPDF2.PdfReader(path)
for i,p in enumerate(reader.pages):
    print('=== page', i+1, '===')
    print(p.extract_text())

import spacy

nlp = spacy.load("en_core_web_sm")
doc = nlp("I arrived in the country")
for chunk in doc.noun_chunks:
    print(chunk.text, chunk.root.text, chunk.root.dep_,
            chunk.root.head.text)
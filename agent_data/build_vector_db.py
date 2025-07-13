import pandas as pd
from langchain_community.embeddings import OpenAIEmbeddings
from langchain_community.vectorstores import Chroma
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.schema import Document
from dotenv import load_dotenv
import os

load_dotenv()  # Load environment variables from .env file (OPENAI_API for us)

CHROMA_PATH = "../chroma_db"
os.makedirs(CHROMA_PATH, exist_ok=True)

def row_to_doc(row, source): # change each row to a doc
    text = " | ".join([f"{col}: {row[col]}" for col in row.index])
    metadata = {"source": source}
    return Document(page_content=text, metadata=metadata)

def build_docs(): # create documents from rows of CSVs
    docs = []

    for filename, source in [
        ("employees.csv", "employee"),
        ("practitioners.csv", "doctor"),
        ("schedules.csv", "schedule")
    ]:
        df = pd.read_csv(f"../agent_data/data/{filename}")
        for _, row in df.iterrows():
            docs.append(row_to_doc(row, source))
    
    return docs

def build_chroma():
    docs = build_docs()
    print(f"Loaded {len(docs)} raw documents.")

    splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=0) # split if needed into chunks
    split_docs = splitter.split_documents(docs)
    print(f"Split into {len(split_docs)} chunks.")

    embeddings = OpenAIEmbeddings()
    vectordb = Chroma.from_documents(split_docs, embedding=embeddings, persist_directory=CHROMA_PATH) # convert chunks toembeddings and save to vector store
    vectordb.persist()
    print(f"Vector store built and saved at {CHROMA_PATH}")

if __name__ == "__main__":
    build_chroma()

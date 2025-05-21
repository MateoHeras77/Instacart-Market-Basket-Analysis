# Instacart Market Basket Analysis

## Project Overview
This project analyzes the Instacart Market Basket dataset to understand customer purchasing behavior, predict future purchases, and generate insights for business decisions.

## Project Structure
The project is organized into the following phases:

### Phase 1: Problem Definition, Research Question, Hypothesis Formulation, Data Collection
- `01_Problem_Definition/`: Contains problem statement, research questions, and hypotheses
  - `01 Problem Definition.ipynb`: Initial problem definition notebook
  - `data_collection_queries.sql`: SQL queries for data collection
  - `Phase1_Deliverable.md/.pdf`: Phase 1 documentation
- `data/raw/`: Original, immutable data
  - `archive.zip`: Compressed raw dataset

### Phase 2 & 3: Data Understanding and Data Visualization
- `02_Data_Understanding/`: Data exploration and analysis documentation
- `03_Data_Visualization/`: Visualizations and dashboards
- `data/processed/`: Clean data ready for analysis
  - `instacart.db`: SQLite database with processed data
- `data/interim/`: Intermediate data
  - `instacart_data/`: CSV files of the dataset

### Phase 4 & 5: Model Building and Model Evaluation
- `04_Model_Building/`: Model architecture and implementation details
- `05_Model_Evaluation/`: Model performance metrics and evaluation results

### Phase 6: Presentation and Documentation
- `06_Presentation/`: Presentation materials

## Notebooks
- `notebooks/00_download_data.ipynb`: Download the Instacart dataset

## Getting Started
1. Run the data download notebook to retrieve the dataset
2. Explore the data with the exploration notebook
3. Follow the project phases in sequence

## Dependencies
- Python 3.x
- Pandas
- Scikit-learn
- Matplotlib
- Other requirements listed in requirements.txt

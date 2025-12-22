# Sleep Disorder Diagnosis & Prediction System
**Group ID:** g1mg06  
**Project Type:** End-to-End MLOps Pipeline

## 📖 Project Overview
This project implements a complete MLOps lifecycle to detect and classify sleep disorders (Insomnia, Sleep Apnea, or Healthy) based on lifestyle and biometric data.

It features:
- **Automated Data Pipeline:** ETL process to ingest and clean raw data.
- **Reproducible Model Training:** Random Forest classifier with metric tracking.
- **Scalable Serving:** FastAPI application containerized with Docker.
- **CI/CD Automation:** GitHub Actions for testing, building, and deploying.
- **Infrastructure as Code:** Full AWS environment provisioned via Terraform.

## 🏗️ Architecture
The project follows a microservice-oriented architecture deployed on AWS:
- **Data Lake (S3):** Stores raw CSVs, processed datasets, and model artifacts (`.joblib`).
- **Registry (ECR):** Stores versioned Docker images of the API.
- **Compute (App Runner):** Serverless deployment of the API with auto-scaling.
- **Client:** Streamlit interface for end-user interaction.

## 📂 Project Structure
```bash
mlops-project-g1mg06/
├── .github/workflows/    # CI/CD Pipelines (Data, Train, Deploy)
├── src/
│   ├── api/              # FastAPI Application
│   │   ├── app.py        # Endpoints (/predict, /train, /metrics)
│   │   └── model_loader.py
│   ├── data/             # ETL Scripts
│   │   ├── download_data.py
│   │   └── clean_transform.py
│   └── models/           # Machine Learning Logic
│       ├── train_model.py
│       └── model.joblib  # Trained model artifact
├── tests/                # Unit Tests
│   ├── test_api.py    
│   └── test_components.py
├── frontend.py           # Streamlit User Interface
├── main.tf               # Terraform Infrastructure definition
├── Dockerfile            # Container definition
├── requirements.txt      # Python dependencies
├── Sleep_health_and_lifestyle_dataset.csv  # Raw dataset
└── README.md             # Project documentation
```

## Deployed Version

Link : https://6ixeyncmu8.eu-west-3.awsapprunner.com/docs

## 🚀 Getting Started Locally

### Prerequisites
- Python 3.9+
- Docker Desktop (optional for container testing)
- AWS Account with access credentials (for S3 data storage)
- AWS CLI (optional, for permanent credential storage)

### 1. Installation
Clone the repo and set up a virtual environment:
```bash
git clone https://github.com/YOUR_USERNAME/mlops-project-g1mg06.git
cd mlops-project-g1mg06

# Create and activate virtual environment (recommended)
python -m venv venv

# On Windows (PowerShell)
.\venv\Scripts\Activate.ps1

# On Linux/Mac
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### 2. Configure AWS Credentials
The data pipeline requires AWS credentials to access S3. Choose one option:

**Option A: Using AWS CLI (Permanent)**
```bash
aws configure
```
Then enter your AWS Access Key ID, Secret Access Key, and default region (e.g., `eu-west-3`).

**Option B: Using Environment Variables (Session-based)**
```bash
# On Windows (PowerShell)
$env:AWS_ACCESS_KEY_ID="your-access-key-id"
$env:AWS_SECRET_ACCESS_KEY="your-secret-access-key"
$env:AWS_DEFAULT_REGION="eu-west-3"

# On Linux/Mac
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="eu-west-3"
```

**How to get AWS credentials:**
1. Sign in to AWS Console
2. Navigate to IAM → Users → G1-MG06 → Security Credentials
3. Create Access Key → Choose "Local Code"
4. Download and save the credentials securely

### 3. Run the Data & Training Pipelines
Execute the scripts to prepare data and train the initial model:
```bash
# 1. Download & Upload Raw Data
python src/data/download_data.py

# 2. Clean & Transform Data
python src/data/clean_transform.py

# 3. Train Model (Saves model.joblib locally and to S3)
python src/models/train_model.py
```

### 4. Run Unit Tests
Validate the code logic before starting the API:
```bash
pytest tests/ -v
```

### 5. Start the API
Run the FastAPI server locally:
```bash
uvicorn src.api.app:app --reload
```
**Swagger UI:** Access `http://127.0.0.1:8000/docs` to test endpoints.

### 6. Run the Interface
Launch the Streamlit dashboard: (Only usable in local but links to the aws api for results)
```bash
streamlit run frontend.py
```

## 🐳 Docker Usage
To build and run the application in a container (simulating production):
```bash
# Build the image
docker build -t sleep-app .

# Run the container (Requires AWS credentials to fetch model from S3)
docker run -p 8000:8000 \
  -e AWS_ACCESS_KEY_ID=YOUR_KEY \
  -e AWS_SECRET_ACCESS_KEY=YOUR_SECRET \
  -e AWS_REGION=eu-west-3 \
  sleep-app
```

## ☁️ Deployment (AWS)
Deployment is fully automated via GitHub Actions and Terraform.

### 1. Infrastructure Setup
The `deploy-infra.yml` workflow runs Terraform to provision:
- **S3 Bucket:** `s3-g1mg06` (Data & Models)
- **ECR Repo:** `ecr-g1mg06` (Docker Images)
- **App Runner:** `apprunner-g1mg06` (Live API)
- **IAM Roles:** Secure permissions for the container to read S3.

### 2. CI/CD Pipeline
Every push to the main branch triggers:
- **Build & Push:** Builds the Docker image and pushes it to ECR.
- **Auto-Deploy:** App Runner detects the new image and updates the live service automatically.

## 📡 API Endpoints

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/health` | Health check (returns status & model load state). |
| `POST` | `/predict` | Returns prediction (Insomnia, Apnea, Healthy) for a patient. |
| `GET` | `/metrics` | Returns model performance metrics (Accuracy, F1-Score). |
| `POST` | `/train` | Triggers a background retraining job using the latest data. |

## 📊 Monitoring
You can monitor the application performance and logs via:
- **AWS CloudWatch:** For application logs (stdout/stderr) and deployment events.
- **App Runner Console:** For real-time service status and URL.

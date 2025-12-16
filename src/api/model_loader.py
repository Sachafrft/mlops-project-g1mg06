import boto3
import joblib
import os

BUCKET_NAME = "s3-g1mg06" 
S3_KEY_MODEL = "models/model.joblib"
LOCAL_MODEL_PATH = "src/models/model.joblib"

def load_model():

    if not os.path.exists(LOCAL_MODEL_PATH):
        print(f"Model not found at {LOCAL_MODEL_PATH}. Downloading from S3")
        
        os.makedirs(os.path.dirname(LOCAL_MODEL_PATH), exist_ok=True)
        
        try:
            s3 = boto3.client("s3")
            s3.download_file(BUCKET_NAME, S3_KEY_MODEL, LOCAL_MODEL_PATH)
            print("Download successful")
        except Exception as e:
            print(f"FATAL ERROR: Could not download model from S3 {e}")
            return None

    print("Loading model into memory")
    try:
        model = joblib.load(LOCAL_MODEL_PATH)
        return model
    except Exception as e:
        print(f"Error loading model file: {e}")
        return None
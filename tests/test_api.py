from fastapi.testclient import TestClient
from src.api.app import app
import pytest

client = TestClient(app)

def test_health_check_no_model(mocker):
    """
    Test health check when model is not loaded.
    We force 'model' to be None to verify the API returns 503 Service Unavailable.
    """
    # Patch returns the new object (None in this case), and applies it immediately.
    # pytest-mock handles cleanup automatically.
    mocker.patch("src.api.app.model", None)
    
    response = client.get("/health")
    
    assert response.status_code == 503
    assert response.json()["detail"] == "Model not loaded"

def test_health_endpoint():
    """Test the health endpoint returns 200/503 structure correctly."""
    response = client.get("/health")
    assert response.status_code in [200, 503]
    assert "status" in response.json() or "detail" in response.json()

def test_predict_endpoint_validation():
    """Test Input Validation (returning 422 for missing fields)."""
    response = client.post("/predict", json={})
    assert response.status_code == 422

import sys
from unittest.mock import MagicMock

def test_predict_success(mocker):

    mock_model = MagicMock()
    mock_model.predict.return_value = [1] # 1 = None (Healthy)
    
    with mocker.patch("src.api.app.model", mock_model):
        payload = {
            "gender": "Male",
            "age": 30,
            "occupation": "Doctor",
            "sleep_duration": 7.0,
            "quality_of_sleep": 8,
            "physical_activity_level": 50,
            "stress_level": 5,
            "bmi_category": "Normal",
            "heart_rate": 70,
            "daily_steps": 8000,
            "systolic_bp": 120,
            "diastolic_bp": 80
        }
        response = client.post("/predict", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert "prediction_label" in data
        assert data["prediction_code"] == 1

import pandas as pd
from src.api.app import preprocess_input, SleepInput

def test_preprocess_input_logic():
    """
    Test that the preprocessing logic correctly transforms input data:
    - Gender to 0/1
    - BMI to integer
    - Splits columns appropriately
    """
    input_data = SleepInput(
        gender="Male",
        age=30,
        occupation="Software Engineer",
        sleep_duration=7.5,
        quality_of_sleep=8,
        physical_activity_level=60,
        stress_level=4,
        bmi_category="Overweight",
        heart_rate=72,
        daily_steps=10000,
        systolic_bp=125,
        diastolic_bp=82
    )

    processed_df = preprocess_input(input_data)
    
    # Check Shape
    assert processed_df.shape == (1, 12)
    
    # Check Transformations
    assert processed_df.iloc[0]['gender'] == 1  # Male -> 1
    assert processed_df.iloc[0]['bmi_category'] == 2 # Overweight -> 2
    assert processed_df.iloc[0]['occupation'] == 0 # Logic was hardcoded to 0
    
    # Check Column Existence
    expected_cols = [
        'gender', 'age', 'occupation', 'sleep_duration', 'quality_of_sleep',
        'physical_activity_level', 'stress_level', 'bmi_category', 'heart_rate',
        'daily_steps', 'systolic_bp', 'diastolic_bp'
    ]
    for col in expected_cols:
        assert col in processed_df.columns

import requests
import os
import json
from dotenv import load_dotenv

load_dotenv()


TESTRAIL_URL = os.getenv("TESTRAIL_URL") 
USERNAME = os.getenv("tr_usr")
PASSWORD = os.getenv("tr_pwd")
PROJECT_ID = 1
RUN_ID = 1

print("Credentials for TestRail:")   
print(USERNAME)
print(PASSWORD)
print('------------------')

def update_testrail_step_result(case_id, step_results):
    """
    step_results should be a list of dicts:
    [
      {"content": "Step 1", "expected": "...", "status_id": 1 or 5, "actual": "..."},
      {"content": "Step 2", "expected": "...", "status_id": 1 or 5, "actual": "..."},
      ...
    ]
    """
    url = f"{TESTRAIL_URL}/index.php?/api/v2/add_result_for_case/{RUN_ID}/{case_id}"
    converted_step_results = [json.loads(i) for i in step_results]
    
    payload = {
        "status_id": 1 if all(s["status_id"] == 1 for s in converted_step_results) else 5,
        "custom_step_results": converted_step_results
    }
    r = requests.post(url, json=payload, auth=(USERNAME, PASSWORD))
    r.raise_for_status()
    return r.json()

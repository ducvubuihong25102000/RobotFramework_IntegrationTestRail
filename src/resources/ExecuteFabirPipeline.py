import requests
from azure.identity import InteractiveBrowserCredential
from robot.api.deco import keyword
import os
import time
from dotenv import load_dotenv
__version__ = '1.0.0'

class ExecuteFabirPipeline:
    ROBOT_LIBRARY_VERSION = __version__
    ROBOT_LIBRARY_SCOPE = 'SUITE'
    
    def __init__(self):
        self.conn = None
        load_dotenv()
        
    def get_token(self):
        credential = InteractiveBrowserCredential()
        token = credential.get_token("https://api.fabric.microsoft.com/.default")
        return token.token
    
    def execute_job(self, access_token, workspace, job_name):
        print("---------------------------------------------------")
        print(workspace)
        print(job_name)
        workspace_id = os.getenv(workspace)
        pipeline_id = os.getenv(job_name)
        print(workspace_id)
        print(pipeline_id)
        print("---------------------------------------------------")
        workspace_id = "8461cf45-3dac-48a1-8c7c-c03b36238d8d"
        pipeline_id = "5ca86481-6870-4e3e-a10c-9c9f7ec12a1b"
        
        print(workspace_id)
        print(pipeline_id)
        print("################################################")

        url = f"https://api.fabric.microsoft.com/v1/workspaces/{workspace_id}/items/{pipeline_id}/jobs/instances?jobType=Execute"
        headers = {
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json"
        }

        response = requests.post(url, headers=headers)
        
        print("Status:", response.status_code)
        print("Response:", response.text)
        print("Request URL to get status:", response.headers["Location"])

        return response.headers["Location"]
    
    def wait_for_fabric_job_to_finish(self, token, job_url, sleeper=10):
        """Must be waiting at least 1 seconds before polling, If not, Fabric may return fail with error 'Job run not found'."""
        time.sleep(5)
        headers = {"Authorization": f"Bearer {token}"}
        print(f"Polling job status at: {job_url}")
        print("--------------------------------")
        while True:
            resp = requests.get(job_url, headers=headers)
            data = resp.json()
            status = data.get("status")
            print(f"Job status: {status}")
            # print(f"Full response: {data}")
            if status in ("Failed", "Cancelled", "Completed", "Deduped"):
                return status
            time.sleep(sleeper)
            
            
            
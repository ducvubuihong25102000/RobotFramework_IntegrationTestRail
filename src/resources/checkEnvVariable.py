import os
import time
from dotenv import load_dotenv
__version__ = '1.0.0'


workspace="WORKSPACE_ID"
job_name="DATA_PIPELINE_ID"
load_dotenv()
print(workspace)
print(job_name)
workspace_id = os.getenv(workspace)
pipeline_id = os.getenv(job_name)
print("------------------------------------------------")
print(workspace_id)
print(pipeline_id)
print("------------------------------------------------")
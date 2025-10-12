from flask import Flask, request, jsonify
import subprocess
import pandas as pd
import os
import sys
import json

app = Flask(__name__)

@app.route("/run-tests", methods=["POST"])
def run_tests():
    df = pd.read_csv("../TestsStructure.csv")
    body = request.json
    case_tags = body.get("tags", [])
    test_suite_path = []
    cmd = ["robot", "--outputdir", "results"]
    for tag in case_tags:
        ts_path = df.loc[df['Tag'] == tag, 'Path']
        if not ts_path.empty:
            cmd += ["-i", tag]
            if ts_path.iloc[0] not in test_suite_path:
                test_suite_path.append(ts_path.iloc[0])
            
    for path in test_suite_path:
        cmd.append(path)

    result = subprocess.run(cmd, capture_output=True, text=True)

    return jsonify({
        "cmd": " ".join(cmd),
        "returncode": result.returncode,
        "stdout": result.stdout,
        "stderr": result.stderr
    })

def execute_robot(tags):
    # cmd path of runner -> git repo (which contains TestsStructure.csv and src folder)
    # os.system("python ./src/resources/checkEnvVariable.py")
    # result = subprocess.run("python ./src/resources/checkEnvVariable.py", capture_output=True, text=True)
    # print("STDOUT:", result.stdout)
    # print("STDERR:", result.stderr)

 
    df = pd.read_csv("./TestsStructure.csv")   
    test_suite_path = []
    cmd = "robot --outputdir ./src/results"
    for tag in tags:
        ts_path = df.loc[df['Tag'] == tag, 'Path']
        if not ts_path.empty:
            cmd += "--inclue=" + tag
            if ts_path.iloc[0] not in test_suite_path:
                test_suite_path.append(".src/" + ts_path.iloc[0])
    
    for path in test_suite_path:
        cmd += " " + path
    
    print(cmd)
    os.system(cmd)

if __name__ == "__main__":
    # app.run(port=5000)
    print('--------------------------------')
    print(sys.argv)
    print('#------------------------------#')
    if len(sys.argv) < 2:
        print("Usage: python execute.py '[\"TC_tag1\", \"TC_tag2\"]'")
        sys.exit(1)

    try:
        tags = sys.argv[1].strip("'[]")
        normalize_tags = tags.split(',')
        
        # tags = eval(sys.argv[1])
        print('$$$------------------------------$$$')    
        print(tags)
        print(type(tags))
        print(normalize_tags)
        print(type(normalize_tags))
        if not isinstance(normalize_tags, list):
            raise ValueError("Tags input must be a JSON array string")
    except Exception as e:
        print(f"Invalid tags input: {e}")
        sys.exit(1)

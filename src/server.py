from flask import Flask, request, jsonify
import subprocess
import pandas as pd
import os

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

def test_load_csv():
    # cmd path of runner -> git repo (which contains TestsStructure.csv and src folder)
    df = pd.read_csv("./TestsStructure.csv")
    data = df.loc[df['Tag'] == 'TC_sample_1', 'Path']
    # result = subprocess.run("cd", capture_output=True, text=True)
    # print("STDOUT:", result.stdout)
    # print("STDERR:", result.stderr)
    result = subprocess.run("python ./src/resources/checkEnvVariable.py", capture_output=True, text=True)
    print("STDOUT:", result.stdout)
    print("STDERR:", result.stderr)
    os.system("python ./src/resources/checkEnvVariable.py")
    if data.empty:
        print("No data found")
    else:
        print(type(data.iloc[0]))
        print(data.iloc[0])


if __name__ == "__main__":
    # app.run(port=5000)
    test_load_csv()

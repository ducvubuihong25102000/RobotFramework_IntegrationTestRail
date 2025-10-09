*** Settings ***
Library   DatabaseLibrary
Library    ../resources/FabricDBConnector.py    WITH NAME    FabricDB
Library    ../resources/ExecuteFabirPipeline.py    WITH NAME    ExecutePipeline

# Suite Setup       Initialize Test Suite
# Suite Teardown    FabricDB.Close Fabric Connection

*** Keywords ***
Initialize Test Suite
    Comment   Initialize Suite set up
    FabricDB.Connect With Aad    ${SQL_ENDPOINT}    ${DBNAME}

    

*** Variables ***
${SERVER}    localhost
${PORT}      3306
${DB}       bk_db
${USER}     admin
${PASSWORD}  admin
${DB_DRIVER}    MySQL ODBC 9.4 Unicode Driver
${QUERY_TC_1}    SELECT * FROM employees e 
${QUERY_TC_3}    SELECT * FROM moved.business_buyer
${QUERY_TC_3_1}    SELECT * FROM moved.business_not_buyer
${SQL_ENDPOINT}    bkjr54bowwyufnypvcecwxiehm-ixhwdbfmhwqurdd4ya5tmi4nru.datawarehouse.fabric.microsoft.com
${DBNAME}          destination
${token}
${job_execution_url}


*** Keywords ***
Wait For Fabric Job To Finish
    [Arguments]    ${job_url}    ${tokenn}
    ${status}=    Set Variable    Running
    WHILE    '${status}' == 'Running' or '${status}' == 'NotStarted'
        ${resp}=    Evaluate    requests.get("${job_url}", headers={"Authorization": f"Bearer ${tokenn}"})
        ${data}=    Evaluate    ${resp}.json()
        ${status}=    Set Variable    ${data['status']}
        Log    Job status: ${status}
        Sleep    60s
    END
    Run Keyword If    '${status}' != 'Succeeded'    Fail    Job failed with status ${status}

 
*** Test Cases ***
1. Happy case for businessDataQualityExceptionReport pipelin
    [Tags]    TC_sample_6
    Connect To Database
    ...    pyodbc
    ...    odbc_driver={${DB_DRIVER}}
    ...    db_name=${DB}
    ...    db_user=${USER}
    ...    db_password=${PASSWORD}
    ...    db_host=${SERVER}
    ...    db_port=${PORT}
    # Add your query and validation steps here
    Query    ${QUERY_TC_1}
2. test Case 2 of suite 1
    [Tags]    TC_sample_12
    Comment   This is a TC_sample_22
    # FabricDB.Connect With Aad    ${SQL_ENDPOINT}    ${DBNAME}

3. test Case 3 of suite 1
    [Tags]    TC_sample_22
    Comment   This is a TC_sample_22
    ${token}    ExecutePipeline.Get Token
    Log    Token: ${token}
    ${job_execution_url}    ExecutePipeline.Execute Job    ${token}    workspace=WORKSPACE_ID    job_name=DATA_PIPELINE_ID
    Log    Job Execution URL: ${job_execution_url}
    ${statusss}    ExecutePipeline.Wait For Fabric Job To Finish    ${token}    ${job_execution_url}    sleeper=5
    Log    Job Status: ${statusss}
    
    FabricDB.Connect With Aad    ${SQL_ENDPOINT}    ${DBNAME}

    ${rows}=         FabricDB.Execute Fabric Query    ${QUERY_TC_3}
    Run Keyword If    ${rows} == 38    Log    Row of demo.business_buyer is 38 - Step Passed
    ...    ELSE    Fail    Row of demo.business is not 38 - Step Failed - Actual value: ${rows}

    ${rows}=         FabricDB.Execute Fabric Query    ${QUERY_TC_3_1}
    Run Keyword If    ${rows} == 12    Log    Row of demo.business_not_buyer is 12 - Step Passed
    ...    ELSE    Fail    Row of demo.business_not_buyer is not 12 - Step Failed - Actual value: ${rows}





*** Settings ***
Library   DatabaseLibrary
Library    ../resources/testrail_keywords.py
Library    ../resources/FabricDBConnector.py    WITH NAME    FabricDB_tgt
Library    ../resources/FabricDBConnector.py    WITH NAME    FabricDB_src
Library    ../resources/ExecuteFabirPipeline.py    WITH NAME    ExecutePipeline

Suite Setup       Initialize Test Suite
# Suite Teardown    FabricDB.Close Fabric Connection
Suite Teardown    Finish Test Suite

*** Keywords ***
Initialize Test Suite
    Comment   Initialize Suite set up
    ${TOKEN}    ExecutePipeline.Get Token
    Set Suite Variable    ${TOKEN}  
    
    ${job_execution_url}    ExecutePipeline.Execute Job    ${TOKEN}    workspace=WORKSPACE_ID    job_name=DATA_PIPELINE_ID
    Log    Job Execution URL: ${job_execution_url}

    ${status}    ExecutePipeline.Wait For Fabric Job To Finish    ${TOKEN}    ${job_execution_url}    sleeper=5
    Log    Job Status: ${status}
    
    FabricDB_tgt.Connect With Aad    ${SQL_ENDPOINT}    ${TARGET_DBNAME}
    FabricDB_src.Connect With Aad    ${SQL_ENDPOINT}    ${SRC_DBNAME}
    

Finish Test Suite
    Comment   Finish Suite tear down
    FabricDB_tgt.Close Fabric Connection
    FabricDB_src.Close Fabric Connection


# Wait For Fabric Job To Finish
#     [Arguments]    ${job_url}    ${tokenn}
#     ${status}=    Set Variable    Running
#     WHILE    '${status}' == 'Running' or '${status}' == 'NotStarted'
#         ${resp}=    Evaluate    requests.get("${job_url}", headers={"Authorization": f"Bearer ${tokenn}"})
#         ${data}=    Evaluate    ${resp}.json()
#         ${status}=    Set Variable    ${data['status']}
#         Log    Job status: ${status}
#         Sleep    60s
#     END
#     Run Keyword If    '${status}' != 'Succeeded'    Fail    Job failed with status ${status}


*** Variables ***
${SERVER}    localhost
${PORT}      3306
${DB}       bk_db
${USER}     admin
${PASSWORD}  admin
${DB_DRIVER}    MySQL ODBC 9.4 Unicode Driver
${PIPELINE_COND_1}    SELECT * FROM demo.business WHERE is_buyer = 1 AND country = 'USA' 
${PIPELINE_COND_2}    SELECT * FROM demo.business WHERE is_buyer = 0 AND country = 'USA' 
${QUERY_TC_1}    SELECT * FROM moved.business_buyer
${QUERY_TC_1_1}    SELECT * FROM [moved].[business_buyer] WHERE [moved].[business_buyer].[country] <> 'USA'
${QUERY_TC_2}    SELECT * FROM moved.business_not_buyer
${QUERY_TC_2_1}    SELECT * FROM [moved].[business_not_buyer] WHERE [moved].[business_not_buyer].[country] <> 'USA'
${SQL_ENDPOINT}    bkjr54bowwyufnypvcecwxiehm-ixhwdbfmhwqurdd4ya5tmi4nru.datawarehouse.fabric.microsoft.com
${TARGET_DBNAME}          destination
${SRC_DBNAME}          dwh_sample_demo
${token}
${job_execution_url}

 
*** Test Cases ***
1. [demo->destination] migration business buyer
    [Tags]    TC_139
    Comment   Verify data migration from demo to destination with condition is_buyer = 1 - pipeline 10102025_demo
    # Expected value:
    ${expected}=    FabricDB_src.Execute Fabric Query    ${PIPELINE_COND_1}

    # Step 1. Execute pipeline
    # Step 2
    ${src_rows}=         FabricDB_tgt.Execute Fabric Query    ${QUERY_TC_1}
    ${status1}=    Set Variable If    ${src_rows} == ${expected}    1    5
    ${actual1}=    Set Variable    Found ${src_rows} rows in query
    Run Keyword If    ${src_rows} == ${expected}   Log    Row of [moved].[business_buyer] is ${expected}  - Step Passed
    ...    ELSE    Run Keyword And Continue On Failure    Fail    Row of [moved].[business_buyer] is not ${expected}  - Step Failed - Actual value: ${src_rows}
    
    # Step 3
    ${src_rows_1}=         FabricDB_tgt.Execute Fabric Query    ${QUERY_TC_1_1}
    ${status2}=    Set Variable If    ${src_rows} == 0    1    5
    ${actual2}=    Set Variable    Found ${src_rows} rows in query
    Run Keyword If    ${src_rows} == 0    Log    No business with country different USA - Step Passed
    ...    ELSE    Run Keyword And Continue On Failure    Fail    Exist business out of USA - Step Failed - Actual value: ${src_rows}

    # Build step results for TestRail
    ${step_results}=    Create List
    ...    {"content": "Execute pipeline: 10102025_demo", "expected": "10102025_demo is executed successfully", "actual": "execute successfully", "status_id": 1}
    ...    {"content": "Data from [demo].[business] is migrated only buyer into [moved].[business_buyer] ", "expected": "All rows in [moved].[business_buyer] with condition:- [is_buyer] = 1- [country] = USA", "actual": "${actual1}", "status_id": ${status1}}
    ...    {"content": "SELECT COUNT(*) FROM [moved].[business_buyer] WHERE [moved].[business_buyer].[country] <> 'USA'", "expected": "rows = 0", "actual": "${actual2}", "status_id": ${status2}}

    Update Testrail Step Result    139    ${step_results}


2. [demo->destination] migration business not buyer
    [Tags]    TC_140
    Comment   Verify data migration from demo to destination with condition is_buyer = 0 - pipeline 10102025_demo

    # Expected value:
    ${expected}=    FabricDB_src.Execute Fabric Query    ${PIPELINE_COND_2}

    # Step 1. Execute pipeline
    # Step 2
    ${src_rows}=         FabricDB_tgt.Execute Fabric Query    ${QUERY_TC_2}
    ${status1}=    Set Variable If    ${src_rows} == ${expected}    1    5
    ${actual1}=    Set Variable    Found ${src_rows} rows in query
    Run Keyword If    ${src_rows} == ${expected}    Log    Row of [moved].[business_not_buyer] is ${expected} - Step Passed
    ...    ELSE  Run Keyword And Continue On Failure  Fail    [moved].[business_not_buyer] is not ${expected} - Step Failed - Actual value: ${src_rows}
    
    # Step 3
    ${src_rows_1}=         FabricDB_tgt.Execute Fabric Query    ${QUERY_TC_2_1}
    ${status2}=    Set Variable If    ${src_rows} == 0    1    5
    ${actual2}=    Set Variable    Found ${src_rows} rows in query
    Run Keyword If    ${src_rows} == 0    Log    No business with country different USA - Step Passed
    ...    ELSE    Run Keyword And Continue On Failure    Fail    Exist business out of USA - Step Failed - Actual value: ${src_rows}

    # Build step results for TestRail
    ${step_results}=    Create List
    ...    {"content": "Execute pipeline: 10102025_demo", "expected": "10102025_demo is executed successfully", "actual": "execute successfully", "status_id": 1}
    ...    {"content": "Data from [demo].[business] is migrated only not buyer into [moved].[business_not_buyer] ", "expected": "All rows in [moved].[business_buyer] with condition:- [is_buyer] = 0 - [country] = USA", "actual": "${actual1}", "status_id": ${status1}}
    ...    {"content": "SELECT COUNT(*) FROM [moved].[business_not_buyer] WHERE [moved].[business_buyer].[country] <> 'USA'", "expected": "rows = 0", "actual": "${actual2}", "status_id": ${status2}}
    Update Testrail Step Result    140    ${step_results}
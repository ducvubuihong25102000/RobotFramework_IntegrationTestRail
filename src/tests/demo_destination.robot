*** Settings ***
Library   DatabaseLibrary
Library    ../resources/FabricDBConnector.py    WITH NAME    FabricDB
Library    ../resources/ExecuteFabirPipeline.py    WITH NAME    ExecutePipeline

Suite Setup       Initialize Test Suite
Suite Teardown    FabricDB.Close Fabric Connection

*** Keywords ***
Initialize Test Suite
    Comment   Initialize Suite set up
    ${TOKEN}    ExecutePipeline.Get Token
    Set Suite Variable    ${TOKEN}  
    
    ${job_execution_url}    ExecutePipeline.Execute Job    ${TOKEN}    workspace=WORKSPACE_ID    job_name=DATA_PIPELINE_ID
    Log    Job Execution URL: ${job_execution_url}

    ${status}    ExecutePipeline.Wait For Fabric Job To Finish    ${TOKEN}    ${job_execution_url}    sleeper=5
    Log    Job Status: ${status}
    
    FabricDB.Connect With Aad    ${SQL_ENDPOINT}    ${DBNAME}


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
${QUERY_TC_1}    SELECT * FROM moved.business_buyer
${QUERY_TC_2}    SELECT * FROM moved.business_not_buyer
${SQL_ENDPOINT}    bkjr54bowwyufnypvcecwxiehm-ixhwdbfmhwqurdd4ya5tmi4nru.datawarehouse.fabric.microsoft.com
${DBNAME}          destination
${token}
${job_execution_url}

 
*** Test Cases ***
1. [demo->destination] migration business buyer
    [Tags]    TC_139
    Comment   Verify data migration from demo to destination with condition is_buyer = 1 - pipeline 10102025_demo
    # FabricDB.Connect With Aad    ${SQL_ENDPOINT}    ${DBNAME}

    ${src_rows}=         FabricDB.Execute Fabric Query    ${QUERY_TC_1}
    Run Keyword If    ${src_rows} == 38    Log    Row of demo.business_buyer is 38 - Step Passed
    ...    ELSE    Fail    Row of demo.business is not 38 - Step Failed - Actual value: ${src_rows}


2. [demo->destination] migration business not buyer
    [Tags]    TC_140
    Comment   Verify data migration from demo to destination with condition is_buyer = 0 - pipeline 10102025_demo

    # FabricDB.Connect With Aad    ${SQL_ENDPOINT}    ${DBNAME}

    ${rows}=         FabricDB.Execute Fabric Query    ${QUERY_TC_2}
    Run Keyword If    ${rows} == 12    Log    Row of demo.business_not_buyer is 12 - Step Passed
    ...    ELSE    Fail    Row of demo.business_not_buyer is not 12 - Step Failed - Actual value: ${rows}

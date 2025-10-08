*** Settings ***
Library    ../resources/FabricDBConnector.py    WITH NAME    FabricDB
Library    ../resources/testrail_keywords.py
Library    Collections

Suite Setup       FabricDB.Connect With Aad    ${SQL_ENDPOINT}    ${DBNAME}
Suite Teardown    FabricDB.Close Fabric Connection

*** Variables ***
${SQL_ENDPOINT}    bkjr54bowwyufnypvcecwxiehm-ixhwdbfmhwqurdd4ya5tmi4nru.datawarehouse.fabric.microsoft.com
${DBNAME}          dwh_sample_demo
${QUERY_EXECUTED}    SELECT * FROM demo.business
${QUERY_ERROR}    SELECT business_number, legal_name, exception_message
...        FROM demo.business
...        WHERE federal_tax_id IS NULL OR line1 IS NULL OR phone IS NULL

*** Test Cases ***
1. Verify Pipeline 1 happy case
    [Tags]    TC_137
    ${rows}=         FabricDB.Execute Fabric Query    ${QUERY_ERROR}
    ${num_table}=    FabricDB.Execute Fabric Query    ${QUERY_EXECUTED}

    # pre-step: triggger pipeline run
    

    
    # Step 1. Verify pipeline ingestion
    ${status1}=    Set Variable If    ${num_table} > 0    1    5
    ${actual1}=    Set Variable If    ${num_table} > 0    Found ${num_table} rows in table    Table empty

    # Step 2. Verify null values
    ${status2}=    Set Variable If    ${rows} == 0    1    5
    # ${actual2}=    Set Variable If    ${rows} == 0    Found ${len(${rows})} No DQ exceptions found    Found ${len(${rows})} DQ exceptions
    ${actual2}=    Set Variable If    ${rows} == 0    Found ${rows} No DQ exceptions found    Found ${rows} DQ exceptions

    # Build step results for TestRail
    ${step_results}=    Create List
    ...    {"content": "Step 1. Verify pipeline ingest csv into dwh_sample_demo.demo.business", "expected": "Table should not be empty", "actual": "${actual1}", "status_id": ${status1}}
    ...    {"content": "Step 2. Verify there is no Null value in dataset", "expected": "No NULL values", "actual": "${actual2}", "status_id": ${status2}}

    Update Testrail Step Result    137    ${step_results}

2. Test case 2 of demo suite
    [Tags]    TC_sample_1
    Comment   This is a TC_sample_1

3. Test case 3 of demo suite
    [Tags]    TC_sample_2
    Comment   This is a TC_sample_2

4. Test case 4 of demo suite
    [Tags]    TC_sample_4
    Comment   This is a TC_sample_4
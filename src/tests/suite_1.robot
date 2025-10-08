*** Settings ***
Library   DatabaseLibrary
Library    ../resources/FabricDBConnector.py    WITH NAME    FabricDB

*** Variables ***
${SERVER}    localhost
${PORT}      3306
${DB}       bk_db
${USER}     admin
${PASSWORD}  admin
${DB_DRIVER}    MySQL ODBC 9.4 Unicode Driver
${QUERY_TC_1}    SELECT * FROM employees e 
${SQL_ENDPOINT}    bkjr54bowwyufnypvcecwxiehm-ixhwdbfmhwqurdd4ya5tmi4nru.datawarehouse.fabric.microsoft.com
${DBNAME}          dwh_sample_demo
 
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
    FabricDB.Connect With Aad    ${SQL_ENDPOINT}    ${DBNAME}

3. test Case 3 of suite 1
    [Tags]    TC_sample_22
    Comment   This is a TC_sample_22


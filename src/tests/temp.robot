*** Settings ***
Library    ../resources/temp.py    WITH NAME    TempLib

*** Variables ***


*** Test Cases ***
1. Verify Pipeline 1 happy case
    [Tags]    TC_141
    TempLib.Get Env Variable    var_name=test_run_id

2. Do nothing
    [Tags]    HELLO_WORLD
    Log    Hello World    
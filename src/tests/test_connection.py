# https://learn.microsoft.com/en-us/fabric/data-warehouse/how-to-connect
# https://medium.com/@mariusz_kujawski/connect-to-microsoft-fabric-warehouse-using-python-and-sqlalchemy-1e1179855037
# https://debruyn.dev/2023/connect-to-fabric-lakehouses-warehouses-from-python-code/
# Related link to create connection - First need to test connection through SQL Server Management Studio (SSMS)
# if it's available to connect then apply by python


import struct
from itertools import chain, repeat
import pyodbc
from azure.identity import AzureCliCredential, InteractiveBrowserCredential

# credential = AzureCliCredential() -- Only available if account under subscription -> not working for trial account
credential = InteractiveBrowserCredential(user_system_browser=True)


sql_endpoint = "bkjr54bowwyufnypvcecwxiehm-ixhwdbfmhwqurdd4ya5tmi4nru.datawarehouse.fabric.microsoft.com"
database = "dwh_sample_demo"
connection_string = f"Driver={{ODBC Driver 18 for SQL Server}};Server={sql_endpoint},1433;Database={database};Encrypt=Yes;TrustServerCertificate=No"

token_object = credential.get_token("https://database.windows.net/.default") 
token_as_bytes = bytes(token_object.token, "UTF-8") 
encoded_bytes = bytes(chain.from_iterable(zip(token_as_bytes, repeat(0)))) 
token_bytes = struct.pack("<i", len(encoded_bytes)) + encoded_bytes 
attrs_before = {1256: token_bytes} 

connection = pyodbc.connect(connection_string, attrs_before=attrs_before)
cursor = connection.cursor()
cursor.execute("SELECT * FROM demo.business")
rows = cursor.fetchall()
print(rows)

cursor.close()
connection.close()




















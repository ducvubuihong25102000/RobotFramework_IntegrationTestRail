import struct
from itertools import chain, repeat
import pyodbc
from azure.identity import InteractiveBrowserCredential
from robot.api.deco import keyword
__version__ = '1.0.0'

class FabricDBConnector:
    ROBOT_LIBRARY_VERSION = __version__
    ROBOT_LIBRARY_SCOPE = 'SUITE'
    
    def __init__(self):
        self.conn = None

    @keyword("Connect With Aad")
    def connect_with_aad(self, sql_endpoint, database):
        credential = InteractiveBrowserCredential(user_system_browser=True)
        token_object = credential.get_token("https://database.windows.net/.default")

        # Convert token to byte array for ODBC
        token_as_bytes = bytes(token_object.token, "UTF-8")
        encoded_bytes = bytes(chain.from_iterable(zip(token_as_bytes, repeat(0))))
        token_bytes = struct.pack("<i", len(encoded_bytes)) + encoded_bytes
        attrs_before = {1256: token_bytes}

        connection_string = (
            f"Driver={{ODBC Driver 18 for SQL Server}};"
            f"Server={sql_endpoint},1433;"
            f"Database={database};"
            "Encrypt=Yes;TrustServerCertificate=No"
        )

        self.conn = pyodbc.connect(connection_string, attrs_before=attrs_before)
        return self.conn

    @keyword("Execute Fabric Query")
    def query(self, sql):
        cursor = self.conn.cursor()
        cursor.execute(sql)
        rows = cursor.fetchall()
        cursor.close()
        print(rows)
        print(type(rows))
        return len(rows)

    @keyword("Close Fabric Connection")
    def close(self):
        if self.conn:
            self.conn.close()
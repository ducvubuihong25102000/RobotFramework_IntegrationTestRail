import os

__version__ = '1.0.0'
class temp:
    ROBOT_LIBRARY_VERSION = __version__
    ROBOT_LIBRARY_SCOPE = 'SUITE'
    
    def __init__(self):
        self.conn = None

    def get_env_variable(self, var_name):
        print(var_name)
        test_run = os.getenv(var_name)
        print(f"Test Run ID: {test_run}")

from contextlib import contextmanager
import os

@contextmanager
def chdir( path ):
	old_dir = os.getcwd()
	os.chdir( path )
	yield
	os.chdir( old_dir )



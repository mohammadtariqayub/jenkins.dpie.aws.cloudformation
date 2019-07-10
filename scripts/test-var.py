import os
import sys
import json
import uuid
import boto3
from time import time

### Global variables ###
#HostName = $HostName
HostName = os.environ['HostName']

echo (HostName)

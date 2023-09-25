#!/bin/env python

from azure.devops.connection import Connection
from msrest.authentication import BasicAuthentication
import pprint

# Fill in with your personal access token and org URL
personal_access_token = '<<your_personal_access_token>>'
organization_url = '<<your_org_url>>'

# Create a connection to the org
credentials = BasicAuthentication('your@email.com', personal_access_token)
connection = Connection(base_url=organization_url, creds=credentials)

# Get a client (the "core" client provides access to projects, teams, etc)
core_client = connection.clients.get_core_client()

# Get the list of projects in the org
projects = core_client.get_projects()

# Show details about each project in the console
for project in projects:
    pprint.pprint(project.__dict__)

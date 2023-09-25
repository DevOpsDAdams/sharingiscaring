#!/usr/local/bin/python3.10

import json
import boto3
import datetime

current_date = datetime.datetime.now()
currdate = current_date.strftime("%Y-%m-%d")
currdate_split = currdate.split('-')
suppress_list=[]


ses = boto3.client('sesv2')
poll_output=ses.list_suppressed_destinations()

for po in poll_output['SuppressedDestinationSummaries']:
    suppress_list.append(po)

try:
    token=poll_output['NextToken']
    token_check = True
except:
    token_check = False

while token_check == True:
    poll_output=ses.list_suppressed_destinations(NextToken=token)
    for po in poll_output['SuppressedDestinationSummaries']:
        suppress_list.append(po)
    try:
        token=poll_output['NextToken']
        poll_output=ses.list_suppressed_destinations(NextToken=token)
        token_check = True
    except:
        token_check = False

print('''{
    "SuppressedDestinationSummaries": [''')
for sl in suppress_list:
    email_address=sl['EmailAddress']
    reason=sl['Reason']
    last_update=sl['LastUpdateTime']
    print('''\t\t{''')
    print('\t\t\t"EmailAddress": "' + email_address + '",')
    print('\t\t\t"Reason": "' + reason + '",')
    print('\t\t\t"LastUpdateTime": "' + str(last_update) + '"')
    print('''\t\t},''')

print('''    ]
}''')

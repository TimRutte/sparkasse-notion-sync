import json
import base64
import boto3
import requests
import os
from google.oauth2 import service_account
from googleapiclient.discovery import build

def get_gmail_service():
    credentials_json = os.environ['GMAIL_CREDENTIALS']
    credentials = service_account.Credentials.from_service_account_info(
        json.loads(credentials_json),
        scopes=['https://www.googleapis.com/auth/gmail.readonly']
    )
    service = build('gmail', 'v1', credentials=credentials)
    return service

def get_unread_emails(service):
    results = service.users().messages().list(userId='me', q='is:unread').execute()
    messages = results.get('messages', [])
    return messages

def get_email_content(service, msg_id):
    message = service.users().messages().get(userId='me', id=msg_id).execute()
    payload = message['payload']
    headers = payload['headers']

    for header in headers:
        if header['name'] == 'Subject':
            subject = header['value']

    if 'data' in payload['body']:
        body = base64.urlsafe_b64decode(payload['body']['data'].encode('ASCII')).decode('utf-8')
    else:
        body = "No Body Content"

    return subject, body

def send_to_notion(email_content, notion_token, notion_database_id):
    headers = {
        "Authorization": f"Bearer {notion_token}",
        "Content-Type": "application/json",
        "Notion-Version": "2021-05-13"
    }

    data = {
        "parent": {"database_id": notion_database_id},
        "properties": {
            "Name": {"title": [{"text": {"content": "Neue Kontoumsätze"}}]},
            "Content": {"rich_text": [{"text": {"content": email_content}}]}
        }
    }

    response = requests.post('https://api.notion.com/v1/pages', headers=headers, data=json.dumps(data))

    return response.status_code

def lambda_handler(event, context):
    notion_token = os.environ['NOTION_TOKEN']
    notion_database_id = os.environ['NOTION_DATABASE_ID']

    service = get_gmail_service()
    messages = get_unread_emails(service)

    for msg in messages:
        msg_id = msg['id']
        subject, body = get_email_content(service, msg_id)

        # Hier die Kontoumsätze analysieren (Implementiere deine Logik zur Analyse der Umsätze)

        send_to_notion(body, notion_token, notion_database_id)

    return {
        'statusCode': 200,
        'body': json.dumps('Success')
    }

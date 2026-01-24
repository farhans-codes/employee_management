import json
import base64
import os

postman_file = '/Volumes/Extra/projects/employee_management/docs/employee_management.postman_collection.json'
img1_path = '/Users/farhan/Downloads/Screenshot at Jan 24 17-18-07.png'
img2_path = '/Users/farhan/Downloads/Screenshot at Jan 24 17-18-33.png'

def get_base64(path):
    with open(path, 'rb') as f:
        data = f.read()
        encoded = base64.b64encode(data).decode('utf-8')
        return f"data:image/png;base64,{encoded}"

b64_img1 = get_base64(img1_path)
b64_img2 = get_base64(img2_path)

with open(postman_file, 'r') as f:
    collection = json.load(f)

# Update Images and Ensure Compact Matching for Login
for item in collection['item']:
    if item['name'] == 'Auth':
        for auth_item in item['item']:
            if auth_item['name'] == 'Login':
                # Update main request body to be compact for easier matching
                auth_item['request']['body']['raw'] = json.dumps({"employee_id": "L3T2077", "password": "password123"})
                
                # Update individual examples
                for resp in auth_item['response']:
                    if 'Success - Employee 1' in resp['name']:
                        resp['originalRequest']['body']['raw'] = json.dumps({"employee_id": "L3T2077", "password": "password123"})
                    elif 'Success - Employee 2' in resp['name']:
                        resp['originalRequest']['body']['raw'] = json.dumps({"employee_id": "L3T2088", "password": "password456"})

    if item['name'] == 'User':
        for user_item in item['item']:
            if user_item['name'] == 'Get Profile':
                for resp in user_item['response']:
                    body = json.loads(resp['body'])
                    if 'data' in body:
                        if body['data']['employee_id'] == 'L3T2077':
                            body['data']['profile_image'] = b64_img1
                        elif body['data']['employee_id'] == 'L3T2088':
                            body['data']['profile_image'] = b64_img2
                    resp['body'] = json.dumps(body, indent=4)

with open(postman_file, 'w') as f:
    json.dump(collection, f, indent=4)

print("Updated Postman collection successfully.")

import boto3

import os

from flask import Flask, render_template, request, redirect, url_for, Response

from werkzeug.utils import secure_filename

from functools import wraps



app = Flask(__name__)



s3 = boto3.client('s3')



# --- AUTHENTICATION LOGIC START ---

def check_auth(username, password):

    """Check if a username/password combination is valid."""

    # In a real app, use Hashicorp Vault or AWS Secrets Manager.

    # For this Capstone, hardcoding or using Env Vars is fine.

    return username == 'sreesai' and password == 'adminisreesai#123'



def authenticate():

    """Sends a 401 response that enables basic auth"""

    return Response(

    'Could not verify your access level for that URL.\n'

    'You have to login with proper credentials', 401,

    {'WWW-Authenticate': 'Basic realm="Login Required"'})



def requires_auth(f):

    @wraps(f)

    def decorated(*args, **kwargs):

        auth = request.authorization

        if not auth or not check_auth(auth.username, auth.password):

            return authenticate()

        return f(*args, **kwargs)

    return decorated

# --- AUTHENTICATION LOGIC END ---



def get_bucket_name():

    # Helper to find the bucket dynamically

    try:

        buckets = s3.list_buckets()

        for b in buckets['Buckets']:

            if "secure-doc-storage" in b['Name']:

                return b['Name']

    except Exception as e:

        print(f"Error accessing S3: {e}")

        return None

    return None

@app.before_request

def before_request():

    # If the request is HTTP (not HTTPS) and not running locally, Redirect.

    # AWS Load Balancers send a header 'X-Forwarded-Proto' telling us the original protocol.

    if request.headers.get('X-Forwarded-Proto') == 'http':

        url = request.url.replace('http://', 'https://', 1)

        return redirect(url, code=301)

@app.route('/', methods=['GET', 'POST'])

@requires_auth  # <--- THIS IS THE LOCK. We attached the auth check here.

def index():

    BUCKET_NAME = get_bucket_name()

    

    if not BUCKET_NAME:

        return "Error: Storage Bucket not found. Check IAM Permissions."



    if request.method == 'POST':

        if 'file' not in request.files:

            return redirect(request.url)

        file = request.files['file']

        if file.filename == '':

            return redirect(request.url)

        if file:

            filename = secure_filename(file.filename)

            s3.upload_fileobj(file, BUCKET_NAME, filename)

            return redirect(url_for('index'))



    # List Objects

    files = []

    try:

        objects = s3.list_objects_v2(Bucket=BUCKET_NAME)

        if 'Contents' in objects:

            for obj in objects['Contents']:

                url = s3.generate_presigned_url('get_object',

                                                Params={'Bucket': BUCKET_NAME,

                                                        'Key': obj['Key']},

                                                ExpiresIn=300)

                files.append({'name': obj['Key'], 'url': url, 'size': obj['Size']})

    except Exception as e:

        return f"Error listing files: {e}"



    return render_template('dashboard.html', files=files)



if __name__ == '__main__':

    app.run(host='0.0.0.0', port=5000)

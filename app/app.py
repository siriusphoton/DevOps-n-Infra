import boto3

import os

from flask import Flask, render_template, request, redirect, url_for

from werkzeug.utils import secure_filename



app = Flask(__name__)



# CONFIGURATION

# We will use the Bucket Name from an Environment Variable (Best Practice)

# or fallback to listing buckets if not set (Lazy discovery)

s3 = boto3.client('s3')



def get_bucket_name():

    # Find the bucket that starts with "secure-doc-storage"

    buckets = s3.list_buckets()

    for b in buckets['Buckets']:

        if "secure-doc-storage" in b['Name']:

            return b['Name']

    return None



BUCKET_NAME = get_bucket_name()



@app.route('/', methods=['GET', 'POST'])

def index():

    if not BUCKET_NAME:

        return "Error: Storage Bucket not found. Check Terraform setup."



    if request.method == 'POST':

        # UPLOAD LOGIC

        if 'file' not in request.files:

            return redirect(request.url)

        file = request.files['file']

        if file.filename == '':

            return redirect(request.url)

        if file:

            filename = secure_filename(file.filename)

            s3.upload_fileobj(file, BUCKET_NAME, filename)

            return redirect(url_for('index'))



    # LIST LOGIC

    # Get objects from S3

    objects = s3.list_objects_v2(Bucket=BUCKET_NAME)

    files = []

    if 'Contents' in objects:

        for obj in objects['Contents']:

            # GENERATE PRESIGNED URL (Secure View)

            url = s3.generate_presigned_url('get_object',

                                            Params={'Bucket': BUCKET_NAME,

                                                    'Key': obj['Key']},

                                            ExpiresIn=300) # Link valid for 5 mins

            files.append({'name': obj['Key'], 'url': url, 'size': obj['Size']})



    return render_template('dashboard.html', files=files)



if __name__ == '__main__':

    app.run(host='0.0.0.0', port=5000)

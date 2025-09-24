import io
from mimetypes import guess_type
import firebase_admin
from firebase_admin import credentials, firestore, storage, auth
from flask import jsonify
import requests

cred = credentials.Certificate("firebase_key.json")
firebase_admin.initialize_app(cred, {'storageBucket': 'your-firebase-address.appspot.com'})

# create the firestore client to communicate with the firestore application
db = firestore.client()

# initialize storage
bucket = storage.bucket()

# function to update an existing collection with a document
def update_document(collection_name, document_name, field_name, field_value):
    try:
        # create a reference to the document
        document_reference = db.collection(collection_name).document(document_name)

        # set the data into the document
        document_reference.set({field_name: field_value}, merge=True)

        print(f"Document {document_name} has been updated.")

    except Exception as error:  # called an error catch, VERY COMMON IN PRODUCTION
        print(f"An error has occurred: {error}")


# function to pull data out of a document
def get_document(collection_name, document_name):
    try:
        # create a reference to the document
        document_reference = db.collection(collection_name).document(document_name)

        # get the document data
        doc = document_reference.get()

        if doc.exists:
            print(f"Got data from {document_name}.")
            return doc.to_dict()
        else:
            return None
    except Exception as error:
        print(f"An error has occurred: {error}")
        return None

# Function to allow the user to create an account or sign in
def register_or_login(email, password, isRegistering=False):
    status = "signInWithPassword"  # input to Google to sign in
    if isRegistering:
        status = "signUp"  # input to Google to sign up

    try:
        url = f"https://identitytoolkit.googleapis.com/v1/accounts:{status}?key=IACCIDENTALLYLEAKEDTHISTHEFIRSTTIMELOL"
        data = {
            "email": email,
            "password": password,
            "returnSecureToken": True
        }

        response = requests.post(url, json=data)
        response_data = response.json()

        if response.status_code == 200:
            id_token = response_data.get("idToken")
            user_id = response_data.get("localId")  # This is the unique Firebase user ID
            return jsonify({"idToken": id_token, "user_id": user_id})

        return jsonify({"error": response_data.get("error", "An unknown error occurred.")}), 404

    except Exception as error:
        print(f"An error has occurred: {error}")
        return jsonify({"error": str(error)}), 404


# Function to place files into Firebase Storage
def place_file_into_storage(file_path, file):
    blob_path = f'{file_path}'  # Path in Firebase storage
    blob = bucket.blob(blob_path)  # Create blob reference
    
    blob.upload_from_file(file)  # Upload file
    print(f"File {filename} successfully uploaded to {blob_path}")

# Function to grab files out of Firebase Storage
def grab_file_from_storage(file_path):
    blob_path = f'{file_path}'  # Path of the file in storage
    blob = bucket.blob(blob_path)  # Get blob reference

    if blob.exists():  # Check if the blob exists in Firebase storage
        file_bytes = blob.download_as_bytes()  # Download file content as bytes
        print("Successfully downloaded file")
        return io.BytesIO(file_bytes)  # Return a BytesIO stream of the file content
    else:
        raise FileNotFoundError("File not found in Firebase storage.")
    
# Function to grab file options from a folder in Firebase Storage
def get_files_in_storage(folder_path):
    blob_path = f'{folder_path}/'
    blobs = bucket.list_blobs(prefix=blob_path)
    return [blob.name for blob in blobs]

# Function to generate a signed url for a file already in storage, returns url
def generate_signed_url(blob_path, days):
    try:
        # Reference the blob in Firebase Storage
        blob = bucket.blob(blob_path)

        # Generate a signed URL valid
        expiration_time = datetime.timedelta(days=days)
        signed_url = blob.generate_signed_url(expiration=expiration_time)
        return signed_url
    except Exception as error:
        print(f"Error generating signed url for blob path: {blob_path}")
        return None

if __name__ == "__main__":
    # collection_name = "users"
    # document_name = "test_user_123"
    # # update_document(collection_name, document_name, "clothes_1", "*reference_to_png_in_storage*")

    # # call the get_document function
    # data = get_document(collection_name, document_name)
    # print("Here is the document data:")
    # print(data)

    # email = "alaricasemail@gmail.com"
    # password = "superSecurePassword"
    # register_or_login(email, password)
    
    update_document("fire_cameras", "1234567", "key", "empty")

from flask import Flask, request, jsonify
from main import generate_heatmap       # import function to generate heatmaps for machine learning model
from fire_ml import load_model, predict # import functions to load up saved model and predict 
from firebase_options import register_or_login, update_document, get_document, place_file_into_storage, grab_file_from_storage, generate_signed_url  # import the firebase functions
import uuid # creating the unique keys

# create the flask server object
server = Flask(__name__)

# establish the home route
@server.route('/')
def home():
    return "Hello! Welcome to the Fire Detection Backend server!"

# establish the mainn prediction route
@server.route('/analyze', methods=['POST'])
def analyze():
    try:
        # recieve the image data
        if "image" not in request.files:
            return jsonify({"error": "No image file supplied."}), 400
        
        file = request.files["image"]
        temp_path = f"tmp_data/temp_{file.filename}"
        file.save(temp_path)    # save the image file locally into the tmp_data folder
        
        # create a heatmap of the image and replace the old image
        generate_heatmap(temp_path, "tmp_data")
        
        # load up the model from the saved path
        model = load_model("fire_model.pth")
        
        # predict with the loaded model
        result = predict(model, temp_path)
        
        return jsonify({"status": result})
    
    except Exception as error:
        return jsonify({"error": f"Error analyzing image: {error}"}), 404
    
# route for the user to sign up
@server.route("/signup", methods=["POST"])
def signup():
    try:
        # grab email and password
        email = request.json.get("email")
        password = request.json.get("password")
        
        if email is None or password is None:
            return jsonify({"error": f"Email or password is missing."}), 404
        
        # call register_or_login and return the response
        return register_or_login(email, password, isRegistering=True)
        
    except Exception as error:
        return jsonify({"error": f"Error signing up: {error}"}), 404

# route for the user to sign in
@server.route("/signin", methods=["POST"])
def signin():
    try:
        # grab email and password
        email = request.json.get("email")
        password = request.json.get("password")
        
        if email is None or password is None:
            return jsonify({"error": f"Email or password is missing."}), 404
        
        # call register_or_login and return the response
        return register_or_login(email, password, isRegistering=False)
        
    except Exception as error:
        return jsonify({"error": f"Error signing up: {error}"}), 404
    
# route for the user to check to see if a fire has been detected
@server.route("/check_fire", methods=["POST"])
def check_fire():
    try:
        # try to get the user_id, camera_id, and key
        user_id = request.json.get("user_id")
        camera_id = request.json.get("camera_id")
        key = request.json.get("key")
        
        if user_id is None or camera_id is None:
            return jsonify({"error": f"User_id or camera_id is missing."}), 404
        
        doc = get_document("fire_cameras", camera_id)
        
        # handle if there is no key
        if key is None:
            # check to see if the key is empty
            if doc["key"] == "":
                # generate a unique key
                new_key = str(uuid.uuid4())
                
                # set the new key into the database
                update_document("fire_cameras", camera_id, "key", new_key)

                # generate a signed url for the image 
                signed_url = generate_signed_url(f"fire_camera/{camera_id}/image.png", 1)
                
                # return the status and the updated key
                return jsonify({"isFire": doc["isFire"], "isGas": doc["isGas"], "key": new_key, "image_path": signed_url})
            else:
                # handle if there is a key present in the database
                return jsonify({"error": "Missing key."}), 404
        else:
            # handle if the key is present
            # check to see if the key matches
            if doc["key"] == key:
                # generate a signed url for the image 
                signed_url = generate_signed_url(f"fire_camera/{camera_id}/image.png", 1)

                return jsonify({"isFire": doc["isFire"], "isGas": doc["isGas"], "image_path": signed_url})
            else:
                # handle if the key doesn't match
                return jsonify({"error": "Incorrect key."}), 404
            
    except Exception as error:
        return jsonify({"error": f"Error checking for fire: {error}"}), 404

# route for the hardware to update whether a fire has been detected or not
@server.route("/update_fire", methods=["POST"])
def update_fire():
    try:
        # grab the camera_id and camera_key
        camera_id = request.json.get("camera_id")
        camera_key = request.json.get("camera_key")
        fire_status = request.json.get("isFire")
        gas_status = request.json.get("isGas")

        # TODO: fully implement managing image file 
        image = request.files.get("image", None)
        
        # print(f"Camera_id: {camera_id}\nCamera_key: {camera_key}\nFire_status: {fire_status}")
        
        if not camera_id or fire_status is None or gas_status is None:      # have to be specific 
            return jsonify({"error": "Missing info for updating."}), 404
        
        doc = get_document("fire_cameras", camera_id)
        
        # handle if there is no camera_key
        if camera_key is None:
            # check to see if the key is empty in the doc
            if doc["camera_key"] == "":
                # generate a unique key
                new_key = str(uuid.uuid4())
                
                # set the new camera_key in the database and update isFire and isGas
                update_document("fire_cameras", camera_id, "camera_key", new_key)
                update_document("fire_cameras", camera_id, "isFire", fire_status)
                update_document("fire_cameras", camera_id, "isGas", gas_status)

                # place image in storage if sent over 
                if image:
                    image_path = f"fire_camera/{camera_id}/image.png"
                    place_file_into_storage(image_path, file)
                    update_document("fire_cameras", camera_id, "image_path", image_path)
                
                # return the status 
                return jsonify({"status": "success", "key": new_key}) 
            else:
                return jsonify({"error": "Missing key."}), 404
        else:
            # handle if the keys match
            if camera_key == doc["camera_key"]:
                update_document("fire_cameras", camera_id, "isFire", fire_status)
                update_document("fire_cameras", camera_id, "isGas", gas_status)
                return jsonify({"status": "success"}) 
            else:
                return jsonify({"error": "Incorrect key."}), 404
        
    except Exception as error:
        return jsonify({"error": f"Error updating: {error}"}), 404

if __name__ == "__main__":
    server.run(host='0.0.0.0', port=5000)# route for the user to sign up

from picamera2 import Picamera2 # the import for the native camera library that ships in Raspbian
import RPi.GPIO as GPIO
import time
import os
import requests
import cv2
from dotenv import load_dotenv

from main import generate_heatmap
from fire_ml import load_model, predict

# will load the environment variables from the .env file
load_dotenv()

# grab the camera_id and key values from environment
camera_id = os.environ.get("CAMERA_ID")
key = os.environ.get("KEY")

# MQ2 readout pin
DO_PIN = 7

# set the GPIO mode
GPIO.setmode(GPIO.BCM) # 0 for no or 1 for yes (LOW or HIGH)
GPIO.setup(DO_PIN, GPIO.IN)

# load the saved model
model = load_model("fire_model.pth")

# initialize the camera and start it
# initializing after loading model due to timeout issue 
print("Initializing camera.")
picam = Picamera2()
picam.configure(picam.create_preview_configuration(main={"format": "RGB888", "size": (640, 480)}))
picam.start()
print("Camera started.")

# helper function to update .env without duplicates
def update_env(env_key, value, env_file='.env'):
    lines = []
    
    # read the .env file if it exists
    if os.path.exists(env_file):
        with open(env_file, 'r') as file:
            lines = file.readlines()

    # check if the env_key already exists and update it, otherwise append it
    key_found = False
    for i, line in enumerate(lines):
        if line.startswith(env_key + "="):
            lines[i] = f"{env_key}={value}\n"
            key_found = True
            break
    
    if not key_found:
        lines.append(f"{env_key}=\"{value}\"\n")
    
    # Write the updated lines back to the .env file
    with open(env_file, 'w') as file:
        file.writelines(lines)

# update firebase by requesting to /update_fire in server to update the fire status
def update_fire(isFire):
    global key
    try:
        # create data to send
        data = {
                "camera_id": camera_id,
                "camera_key": key if key != "" else None,
                "isGas": GPIO.input(DO_PIN), # read input and return True or False
                "isFire": isFire
            }
        # print(f"Data to post: {data}")
        
        # perfrom an http post request
        response = requests.post(
            "http://192.168.0.103:5000/update_fire",
            headers={"Content-Type": "application/json"},
            json = data
        )
        # print(f"Response Data: {response.json()}")
        
        # check to ensure the request was successful
        if response.status_code == 200:
            # print("Data successfully posted!")
            body = response.json()      # save response json as a dictionary
            
            # parse key and set if present
            new_key = body.get("key", None)
            if new_key:
                # update the KEY environment variable and in this instance
                update_env("KEY", new_key)
                key = new_key
                print(f"Saved new key: {new_key}")
            return True
        else:
            print(f"Issue posting data: {response.reason} {response.status_code}")
            print(response.json())
        return False
    except Exception as error:
        print(error)
        return False

# main process where the image is taken and isFire is determined
def main():
    try:
        # take picture
        frame = picam.capture_array()
        frame = cv2.cvtColor(frame, cv2.ROTATE_180) # rotate camera 
        cv2.imwrite("capture/cap.jpg", frame)
        
        # check to ensure the frame was saved
        if not os.path.isfile("capture/cap.jpg"):
            print("Issue getting frame. Frame was never saved.")
            return False
        
        # NOT GENERATING HEATMAP BECAUSE IT TENDS TO BE MORE ACCURATE!!!
        # generate_heatmap("capture/cap.jpg", "capture/")
        
        # determine isFire
        result = predict(model, "capture/cap.jpg")
        print(f"result: {result}")
        isFire = True if result == "fire" else False
        
        # update database if fire is detected
        is_set = update_fire(isFire)
        
        # remove picture file
        os.remove("capture/cap.jpg")    # remove file so next check will be accurate
        
        return True
    except Exception as error:
        print(f"Error running main: {error}")
        return False
    
if __name__ == "__main__":
    while True:
        if not main():
            break
        time.sleep(1)
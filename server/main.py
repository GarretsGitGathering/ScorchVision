import cv2  # interacting with cameras/video
import matplotlib.pyplot as plt # displaying analyzed images/video
import seaborn as sns   # library for the heatmap functionality
import os

# function to create new dataset of heatmap images
def generate_heatmap(image_path, output_folder):
    # open up an image with cv2
    image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)  # load up image and convert to grayscale

    # normalize the pixels to values 0 - 1
    normalized_image = image / 255.0

    # display the figure and create the heatmap
    plt.figure(figsize=(8,6))
    sns.heatmap(normalized_image, cmap="inferno", cbar=True)

    # remove axis
    plt.axis('off')

    # save the image
    filename = os.path.basename(image_path)
    output_path = os.path.join(output_folder, filename)
    plt.savefig(output_path)
    plt.close() # properly close image and remove from memory
    
# checks to see if this file is the active file being run
# if so, then this code will execute 
if __name__ == "__main__":
    input_folder = "fire_dataset/non_fire_images"   # input data 
    output_folder = "fire_dataset/heatmap_non_fire_images"  # output dataset
    os.makedirs(output_folder, exist_ok=True)   # create the output folder if it doesn't exist already
    
    # iterate through images in input folder
    for img in os.listdir(input_folder):
        # create the image path and generate the heatmap
        image_path = os.path.join(input_folder, img)
        generate_heatmap(image_path, output_folder)
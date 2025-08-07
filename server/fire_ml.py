import torch # machine learning library for behind the scenes processes
from torch import nn, optim # nn for neural network 
from torch.utils.data import DataLoader, random_split # DataLoader for loading data and random_split
from torchvision import models, datasets, transforms    
from PIL import Image   # the pillow library is for manipulating images

# function to create the model
def create_model():
    model = models.mobilenet_v2(pretrained=True)    # model that we will use
    model.classifier[1] = nn.Linear(model.last_channel, 2)  # specify model will be classifier, fire or no fire
    return model
    
# function to train the model
def train_model(model, dataset_path="fire_dataset", epochs=10, batch_size=32, lr=0.001):
    # epochs: the amount of times the ML model will be trained on images
    # batch_size: the amount of data the ML model will be trained on during each epoch
    # lr or learning rate: rate at which the ML model will make tweaks to become more accurate
    
    # configure gpu if available
    device = "cuda" if torch.cuda.is_available() else "cpu"
    model.to(device)    # move the model onto the gpu or cpu
    
    # process for cleansing and preparing our dataset
    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[.5], std=[.5])
    ])
    
    # load the data and transform it
    dataset = datasets.ImageFolder(root=dataset_path, transform=transform)
    # configure the test and training size
    train_size = int(.8 * len(dataset))
    test_size = len(dataset) - train_size
    print(f"Length of Dataset: {len(dataset)}\nLength of Train Size: {train_size}\nLength of Test Size: {test_size}")
    train_dataset, test_dataset = random_split(dataset, [train_size, test_size])    # split the dataset into the train and test datasets
    
    train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
    test_loader = DataLoader(test_dataset, batch_size=batch_size, shuffle=True)
    
    # configure our loss and optimizer
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=lr)
    
    # training loop
    for epoch in range(epochs):
        print(f"#### Epoch: {epoch} ####")
        model.train()   # configure and prep model for training
        loss = 0.0
        for images, labels in train_loader:
            images, labels = images.to(device), labels.to(device)   # move the images and labels onto gpu if necessary

            optimizer.zero_grad()
            output_labels = model(images) # output labels for the prediction
            image_loss = criterion(output_labels, labels) # compare the output labels to labels and also determine the loss
            image_loss.backward()
            print(f"Image Loss: {image_loss}")
            optimizer.step()    # self reflective step to actually learn
            loss += image_loss.item() 
        print(f"Epoch Loss: {loss}")
        
        # loop for testing immediately after each training loop
        model.eval()    # configure and prep the model for evaluation
        correct = 0
        total = 0
        with torch.no_grad():
            for images, labels in test_loader:
                images, labels = images.to(device), labels.to(device)
                output_labels = model(images)
                _, predicted = torch.max(output_labels, 1)
                total += 1
                correct += (predicted == labels).sum().item()
                
        accuracy = 100 * (correct / total)
        print(f"Model Accuracy: {accuracy}\n")

# function to predict with the model
def predict(model, image_path):
    # configure gpu if available
    device = torch.device("cpu") #"cuda" if torch.cuda.is_available() else "cpu")
    model.to(device)    # move the model onto the gpu or cpu
    model.eval()        # configure and prep the model for predicting
    
    #print(f"Model size: {model}")
    
    # process for cleansing and preparing our image
    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[.5], std=[.5])
    ])
    
    # load the image and transform
    image = Image.open(image_path).convert("RGB") # each pixel is a list of RGB values [Red, Green, Blue]
    image_tensor = transform(image).unsqueeze(0).to(device) # transform, unsqueeze, and move to correct device
    
    with torch.no_grad():
        result = model(image_tensor)
        prediction = torch.argmax(result, 1).item() # convert the resulting tensor to either a 0 or 1
        
    return "fire" if prediction == 0 else "no fire"

# function to save the model locally as a file
def save_model(model, path):
    torch.save(model.state_dict(), path)    # save the model to a file
    print(f"Saved model to {path}")
    
# function to load the model from the saved path
def load_model(path):
    model = create_model()  # create an empty model
    model.load_state_dict(torch.load(path, map_location=torch.device("cpu")))   # load the state into the model
    model.eval()    # evaluate model; make sure everythings good
    print(f"Model loaded from {path}")
    return model

if __name__ == "__main__":
    # create the model
    model = create_model()
    
    # train the model
    train_model(model, dataset_path="fire_dataset", epochs=1, batch_size=32)
    save_model(model, "fire_model.pth")
    
    # load up the model
    model = load_model("fire_model.pth")
    
    print("### TEST WITH FIRE IMAGE ###")
    test_image = "fire_dataset/fire_images/fire.129.png"
    result = predict(model, test_image)
    print(f"Predicted result: {result}\n")
    
    print("### TEST WITH NO FIRE IMAGE ###")
    test_image = "fire_dataset/non_fire_images/non_fire.57.png"
    result = predict(model, test_image)
    print(f"Predicted result: {result}\n")
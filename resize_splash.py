from PIL import Image

def pad_image(input_path, output_path, scale_factor=2.88):
    img = Image.open(input_path).convert("RGBA")
    
    # Calculate new canvas size
    # We use the max of width and height to ensure a square canvas if it is not square
    max_dim = max(img.width, img.height)
    new_size = int(max_dim * scale_factor)
    
    # Create new transparent image
    new_img = Image.new("RGBA", (new_size, new_size), (0, 0, 0, 0))
    
    # Calculate position to paste the original image
    x = (new_size - img.width) // 2
    y = (new_size - img.height) // 2
    
    # Paste original image
    new_img.paste(img, (x, y), img)
    
    # Save the new image
    new_img.save(output_path)
    print(f"Saved {output_path} with size {new_size}x{new_size}")

pad_image("assets/images/logo.png", "assets/images/logo_splash.png")

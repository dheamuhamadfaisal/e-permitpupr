from PIL import Image

def pad_image_with_corners(input_path, output_path, scale_factor=3.0):
    img = Image.open(input_path).convert("RGBA")
    
    # Calculate new canvas size
    max_dim = max(img.width, img.height)
    new_size = int(max_dim * scale_factor)
    
    # Create new transparent image
    new_img = Image.new("RGBA", (new_size, new_size), (0, 0, 0, 0))
    
    # Calculate position to paste the original image
    x = (new_size - img.width) // 2
    y = (new_size - img.height) // 2
    
    # Paste original image
    new_img.paste(img, (x, y), img)
    
    # Add a nearly invisible pixel at the 4 corners to prevent Android AAPT from cropping transparent padding
    corner_pixel = (255, 255, 255, 1) # White with 1/255 opacity
    new_img.putpixel((0, 0), corner_pixel)
    new_img.putpixel((new_size - 1, 0), corner_pixel)
    new_img.putpixel((0, new_size - 1), corner_pixel)
    new_img.putpixel((new_size - 1, new_size - 1), corner_pixel)
    
    # Save the new image
    new_img.save(output_path)
    print(f"Saved {output_path} with size {new_size}x{new_size} and corner pixels")

pad_image_with_corners("assets/images/logo.png", "assets/images/logo_splash.png")

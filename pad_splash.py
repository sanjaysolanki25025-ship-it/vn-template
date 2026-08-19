from PIL import Image

# Open the original image
original = Image.open('assets/images/img_app_logo.png')

# Create a new square image, 2048x2048, with a transparent background
# Actually, the splash screen will fill the background color from our config.
# So a transparent background is perfect.
new_size = 2048
new_image = Image.new('RGBA', (new_size, new_size), (0, 0, 0, 0))

# The original image is 1536 x 1024. Let's scale it down a bit so it fits well within the Android 12 circular mask.
# The Android 12 circle is about 2/3 of the total width/height.
# We want our image to fit inside a circle of diameter (2/3 * 2048) = 1365.
# Let's scale the original image so its max dimension is about 1200.
scale_factor = 1200 / max(original.size)
new_w = int(original.width * scale_factor)
new_h = int(original.height * scale_factor)

resized = original.resize((new_w, new_h), Image.Resampling.LANCZOS)

# Paste the resized image into the center of the new square image
paste_x = (new_size - new_w) // 2
paste_y = (new_size - new_h) // 2
new_image.paste(resized, (paste_x, paste_y), resized if resized.mode == 'RGBA' else None)

# Save the new image
new_image.save('assets/images/img_app_logo_splash.png')
print("Padded splash image created at assets/images/img_app_logo_splash.png")

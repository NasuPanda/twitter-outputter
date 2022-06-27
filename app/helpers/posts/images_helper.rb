module Posts::ImagesHelper
  def image_id(image)
    "image-#{image.id}"
  end
end

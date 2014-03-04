require 'RMagick'

class ImageTools
  def ImageTools.scale(source_path, target_path, max_dimension)
    img = Magick::Image::read(source_path).first
    img.auto_orient!

    if img.columns > max_dimension && img.rows > max_dimension
      preview = img.resize_to_fill(max_dimension, max_dimension)
      preview.write target_path
      target_path
    else
      img.write target_path
      target_path
    end
  end
end

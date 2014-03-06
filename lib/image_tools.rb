class ImageTools
  def ImageTools.scale(source_path, target_path, max_dimension, force_square=true)
    img = Magick::Image::read(source_path).first
    img.auto_orient!

    if img.columns > max_dimension && img.rows > max_dimension
      if force_square
        preview = img.resize_to_fill(max_dimension, max_dimension)
      else
        preview = img.resize_to_fit(max_dimension, max_dimension)
      end

      preview.write target_path
      target_path
    else
      img.write target_path
      target_path
    end
  end
end

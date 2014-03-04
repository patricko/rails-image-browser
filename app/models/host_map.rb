class HostMap
  @@host_to_root_map = nil

  def HostMap.host_to_root(host)
    if !@@host_to_root_map
      image_map_root = ENV["RAILS_IMAGE_ROOT"] || '/rails_images'

      @@host_to_root_map = {}
      Dir.foreach(image_map_root).each do |file|
        path = "#{image_map_root}/#{file}"
        if File.directory?(path) && file != '.' && file != '..'
          @@host_to_root_map[file] = path
        end
      end
    end

    return @@host_to_root_map[host] || @@host_to_root_map['default'] || 'public'
  end
end
require_dependency 'image_tools'
require 'mime/types'

class SlideFileController < ApplicationController
  def requests
    dir = HostMap.host_to_root(request.host)
    path = "#{dir}#{URI.unescape(request.path)}"

    if File.exists?(path)
      if File.directory?(path)
        @image_files = []
        @other_files = []
        @subfolders = []

        Dir.foreach(path).each do |file|
          if is_image?(file)
            @image_files << file
          elsif file[0] != '.'
            if File.directory?("#{path}/#{file}")
              @subfolders << file
            else
              @other_files << file
            end
          end
        end

        @base = "#{URI.unescape(request.path)}"
        @base = "#{@base}/" if @base.last != '/'
        render 'index', formats: :html
      else
        if is_image?(path)
          if params[:preview]
            @filename = request.path
            render 'preview', formats: :html
            return
          end
          return_image(path, params[:size])
        else
          render :text => open(path, "rb").read
        end
      end
    else
      raise ActionController::RoutingError.new("File Not Found - #{path} - #{URI.unescape(path)} -- #{params.inspect}")
    end
  end

  def preview
    raise "preview"
  end

  def file_to_minetype(file)

  end

private
  def is_image?(file_name)
    file_name =~ /\.(jpg|png|gif)$/i
  end

  def return_image(path, size)
    type = MIME::Types.type_for(path).first

    max_dim = 0
    cache_folder = nil
    force_square = false
    case size
      when 'thumb' then max_dim = 128; cache_folder = '.thumbnails'; force_square = true
      when 'preview' then max_dim = 800; cache_folder = '.previews'
    end

    if cache_folder
      target_path = build_target_path(path, cache_folder)
      ImageTools.scale(path, target_path, max_dim, force_square) unless File.exist?(target_path)
    else
      target_path = path
    end

    send_file(target_path, disposition: 'inline', type: type, x_sendfile: true)
  end

  def build_target_path(path, folder)
    if path =~ /^(.*\/)([^\/]*)$/
      FileUtils.mkdir_p("#{$1}#{folder}")
      "#{$1}#{folder}/#{$2}"
    else
      raise "invalid param #{path}"
    end
  end
end

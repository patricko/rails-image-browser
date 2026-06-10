require "test_helper"
require "tmpdir"

class SlideFileControllerTest < ActionDispatch::IntegrationTest
  setup do
    @image_root = Dir.mktmpdir("rails-image-browser")
    @host_root = File.join(@image_root, "images.example")
    FileUtils.mkdir_p(@host_root)
    ENV["RAILS_IMAGE_ROOT"] = @image_root
    reset_host_map
    host! "images.example"
  end

  teardown do
    ENV.delete("RAILS_IMAGE_ROOT")
    reset_host_map
    FileUtils.remove_entry(@image_root) if @image_root && File.exist?(@image_root)
  end

  test "renders directory contents for the current host" do
    write_image("photo.png")
    File.write(File.join(@host_root, "notes.txt"), "hello")
    File.write(File.join(@host_root, ".hidden.txt"), "secret")
    FileUtils.mkdir_p(File.join(@host_root, "nested"))

    get "/"

    assert_response :success
    assert_includes response.body, "photo.png"
    assert_includes response.body, "notes.txt"
    assert_includes response.body, "nested"
    refute_includes response.body, ".hidden.txt"
  end

  test "serves an index file instead of rendering a directory listing" do
    File.write(File.join(@host_root, "index.html"), "<h1>Custom index</h1>")
    write_image("photo.png")

    get "/"

    assert_response :success
    assert_equal "<h1>Custom index</h1>", response.body
    assert_equal "text/html", response.media_type
  end

  test "serves non-image files inline with their content type" do
    File.write(File.join(@host_root, "notes.txt"), "plain text")

    get "/notes.txt"

    assert_response :success
    assert_equal "plain text", response.body
    assert_equal "text/plain", response.media_type
  end

  test "renders image preview pages" do
    write_image("photo.png")

    get "/photo.png", params: { preview: "true", size: "preview" }

    assert_response :success
    assert_includes response.body, "/photo.png"
    assert_includes response.body, "/photo.png?size=preview"
  end

  test "generates and serves cached thumbnails" do
    write_image("photo.png", columns: 300, rows: 180)

    get "/photo.png", params: { size: "thumb" }

    assert_response :success
    assert_equal "image/png", response.media_type
    assert_path_exists File.join(@host_root, ".thumbnails", "photo.png")
  end

  test "falls back to the default root for unknown hosts" do
    default_root = File.join(@image_root, "default")
    FileUtils.mkdir_p(default_root)
    File.write(File.join(default_root, "default.txt"), "from default")
    host! "missing.example"
    reset_host_map

    get "/default.txt"

    assert_response :success
    assert_equal "from default", response.body
  end

  private

  def reset_host_map
    HostMap.class_variable_set(:@@host_to_root_map, nil)
  end

  def write_image(filename, columns: 20, rows: 20)
    image = Magick::Image.new(columns, rows) { |options| options.background_color = "red" }
    image.write(File.join(@host_root, filename))
  end
end

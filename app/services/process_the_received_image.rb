class ProcessTheReceivedImage

  def initialize attributes
    @images_base64 = attributes[:images_base64]
  end

  def split_base64 uri_str
    if uri_str.match(%r{^data:(.*?);(.*?),(.*)$})
      uri = Hash.new
      uri[:type] = $1 # "image/gif"
      uri[:encoder] = $2 # "base64"
      uri[:data] = $3 # data string
      uri[:extension] = $1.split('/')[1] # "gif"
      return uri
    else
      return nil
    end
  end

  def call
    {
      citizen_id: convert_data_uri_to_upload_1(@images_base64[:citizen_id]),
      p_address: convert_data_uri_to_upload_2(@images_base64[:p_address])
    }
  end

  def convert_data_uri_to_upload_1 citizen_id
    citizen_id.try(:match, %r{^data:(.*?);(.*?),(.*)$})
    image_data = split_base64(citizen_id)
    image_data_string = image_data[:data]
    image_data_binary = Base64.decode64(image_data_string)
    temp_img_file = Tempfile.new("")
    temp_img_file.binmode
    temp_img_file << image_data_binary
    temp_img_file.rewind

    img_params = {:filename => "image.#{image_data[:extension]}",
                  :type => image_data[:type], :tempfile => temp_img_file}
    uploaded_file = ActionDispatch::Http::UploadedFile.new(img_params)
    citizen_id= uploaded_file
  end

  def convert_data_uri_to_upload_2 p_address
    p_address.try(:match, %r{^data:(.*?);(.*?),(.*)$})
    image_data = split_base64(p_address)
    image_data_string = image_data[:data]
    image_data_binary = Base64.decode64(image_data_string)
    temp_img_file = Tempfile.new("")
    temp_img_file.binmode
    temp_img_file << image_data_binary
    temp_img_file.rewind

    content_type = `file --mime -b #{temp_img_file.path}`.split(";")[0]

    filename = "citizen_id.#{image_data[:extension]}"

    uploaded_file=  ActionDispatch::Http::UploadedFile.new({
        tempfile: temp_img_file,
        type: content_type,
        filename: filename
      })
    p_address = uploaded_file
  end

end

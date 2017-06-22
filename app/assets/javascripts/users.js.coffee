$ ->
  $(".img_dropzone").on "dragover", (e) ->
    e.preventDefault()

  $(".img_dropzone").on "drop", (_e) ->
    e = _e
    if(_e.originalEvent)
      e = _e.originalEvent;
    e.preventDefault()
     # ドロップされたファイルのfilesプロパティを参照
    files = e.dataTransfer.files
    if(files.length == 1)
      alert(files[0].name + ":" + files[0].size)
      file_upload(files[0])

  file_upload = (f) ->
    formData = new FormData
    formData.append("file", f)
    $.ajax "upload_image",
      type: "POST"
      dataType: "text"
      contentType: false
      processData: false
      data: formData
      success: (data) ->
        alert data
        return
    return

  $("").ondragstart
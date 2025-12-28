import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("-- connected imageUploadController --");
  }

  valid(event) {
    console.log("-- valid --");
    const image_upload = event.target
    if (image_upload && image_upload.files.length > 0) { 
      const size_in_megabytes = image_upload.files[0].size/1024/1024;
      if (size_in_megabytes > 5) {
        alert("Maximum file size is 5MB. Please choose a smaller file.");
        image_upload.value = "";
      }
    }
  }
}
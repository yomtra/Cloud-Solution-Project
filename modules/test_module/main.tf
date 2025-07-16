# Test module to verify repository permissions
# This is a simple test module that can be safely removed

resource "null_resource" "test" {
  provisioner "local-exec" {
    command = "echo 'Test module created successfully'"
  }
}

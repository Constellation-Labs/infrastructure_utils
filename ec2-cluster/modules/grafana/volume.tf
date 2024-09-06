resource "aws_ebs_volume" "grafana_volume" {
  availability_zone = var.volume_az
  size = "100"
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = var.volume_device_name
  volume_id   = aws_ebs_volume.grafana_volume.id
  instance_id = aws_instance.grafana.id
}

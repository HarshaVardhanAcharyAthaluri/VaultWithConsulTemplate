vault {
  address = "http://localhost:8200"
  token="hvs.1wYTvtf3esDZ5hsQ7uFm5hSf"
  unwrap_token = false
  renew_token = false
}
template {
contents="{{ with secret \"pki_root_CA/issue/role_root_ca\" \"common_name=localhost\" }}{{ .Data.certificate }}{{ end }}"
destination="./localhost.cert"
}
template {
  contents="{{ with secret \"pki_root_CA/issue/role_root_ca\" \"common_name=localhost\" }}{{ .Data.private_key }}{{ end }}"
  destination="./localhost.key"
}
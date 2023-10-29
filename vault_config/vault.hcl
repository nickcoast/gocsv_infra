storage "{{ vault_storage_type }}" {
  path = "{{ vault_data_dir }}"
}

listener "tcp" {
  address     = "{{ vault_listener_address }}"
  tls_disable = "{{ vault_tls_disable }}"
}

ui = true
disable_mlock = false

api_addr	=	"https://0.0.0.0:8200"

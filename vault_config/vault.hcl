storage "file" {
  path = "/home/nick/vault/data"
}

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = "true"
}

ui = true
disable_mlock = false

api_addr	=	"https://0.0.0.0:8200"

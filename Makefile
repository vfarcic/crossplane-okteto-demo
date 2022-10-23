.PHONY: start
start:
	go run server.go

.PHONY: debug
debug:
	dlv debug --headless --listen=:2345 --log --api-version=2
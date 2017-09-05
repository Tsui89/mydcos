curl https://downloads.dcos.io/binaries/cli/linux/x86-64/dcos-1.9/dcos -o dcos && 
sudo mv dcos /usr/local/bin && 
sudo chmod +x /usr/local/bin/dcos && 
dcos config set core.dcos_url http://192.168.131.1 && 
dcos auth login && 
dcos

bash dcos_generate_config.sh --genconf
docker run -d -p 9000:80 -v $PWD/genconf/serve:/usr/share/nginx/html:ro nginx:1.10.0-alpine

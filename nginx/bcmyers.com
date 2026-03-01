server {
	listen 80       default_server;
	listen [::]:80  default_server;

	server_name     bcmyers.com www.bcmyers.com;

	return 301 https://$host$request_uri;
}

server {
	listen 443			        ssl;
	listen [::]:443	            ssl;

	server_name			        bcmyers.com www.bcmyers.com;

	ssl_certificate			    /etc/letsencrypt/live/bcmyers.com/fullchain.pem;
	ssl_certificate_key		    /etc/letsencrypt/live/bcmyers.com/privkey.pem;
	ssl_protocols			    TLSv1.3;
	ssl_prefer_server_ciphers	on;
	ssl_dhparam			        /home/bcmyers/certs/dhparam.pem;
    ssl_ciphers			        EECDH+AESGCM:EDH+AESGCM;
	ssl_ecdh_curve			    secp384r1;
	ssl_session_timeout		    10m;
	ssl_session_cache		    shared:SSL:10m;
	ssl_session_tickets		    off;
	ssl_stapling			    on;
	ssl_stapling_verify		    on;
	resolver			        1.1.1.1 1.0.0.1 valid=300s;
	resolver_timeout		    5s;
	add_header			        X-Frame-Options DENY;
	add_header			        X-Content-Type-Options nosniff;
	add_header			        X-XSS-Protection "1; mode=block";

	location / {
		proxy_pass		        http://127.0.0.1:5000;
		proxy_http_version	    1.1;
		proxy_pass_header	    Server;
	}

    location /calendar/ {
        proxy_pass              http://127.0.0.1:5232/;
        proxy_set_header        X-Script-Name /calendar;
        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass_header       Authorization;
    }
}

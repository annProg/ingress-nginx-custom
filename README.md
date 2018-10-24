# ingress-nginx-custom
add module for ingress-nginx(0.20.0)

* ngx_http_reqstat_module from tengine

## http-snippet
configmap http-snippet添加以下内容

```
	req_status_zone letvapp "$service_name" 2M;
	req_status letvapp;
	req_status_lazy on;
	server {
		listen 8000;
		allow 10.0.0.0/8;
		allow 127.0.0.0/8;
		deny all;
		location /reqstat {
			req_status_show letvapp;
		}
	}
```

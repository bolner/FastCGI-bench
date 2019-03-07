# FastCGI-Bench - NodeJS vs C#

This project provides an automated way to setup a test environment for comparing the performances of a NodeJS and a C# fastCGI client.

*Note: Currently the C# setup doesn't seem to be fully supporting parallel execution, because it hangs if the concurrency is more than 4. I will search for a fully async library.*

FastCGI libraries used:
- NodeJS: https://github.com/fbbdev/node-fastcgi
- C#: https://github.com/LukasBoersma/FastCGI

## Installation

- Create the docker image:

        docker/build_image.sh

- Create and start a container. The parameter is the public http port.

        docker/create_container.sh 8080

- Log in into the docker container:

        docker/login.sh

## The setup

4 NodeJS and 4 C# processes accept FastCGI request on different ports.

        fcgiben+    21     1  1 00:17 ?        00:00:00   node /var/fcgibench/nodejs/index.js 8080
        fcgiben+    29     1  1 00:17 ?        00:00:00   node /var/fcgibench/nodejs/index.js 8081
        fcgiben+    38     1  1 00:17 ?        00:00:00   node /var/fcgibench/nodejs/index.js 8082
        fcgiben+    47     1  1 00:17 ?        00:00:00   node /var/fcgibench/nodejs/index.js 8083
        fcgiben+    56     1  5 00:17 ?        00:00:00   mono /var/fcgibench/csharp/fcgi.exe 9090
        fcgiben+    62     1  5 00:17 ?        00:00:00   mono /var/fcgibench/csharp/fcgi.exe 9091
        fcgiben+    67     1  5 00:17 ?        00:00:00   mono /var/fcgibench/csharp/fcgi.exe 9092
        fcgiben+    71     1  5 00:17 ?        00:00:00   mono /var/fcgibench/csharp/fcgi.exe 9093
        root        89     1  0 00:17 ?        00:00:00   nginx: master process /usr/sbin/nginx
        www-data    91    89  0 00:17 ?        00:00:00     nginx: worker process
        www-data    92    89  0 00:17 ?        00:00:00     nginx: worker process
        www-data    94    89  0 00:17 ?        00:00:00     nginx: worker process
        www-data    95    89  0 00:17 ?        00:00:00     nginx: worker process
        www-data    96    89  0 00:17 ?        00:00:00     nginx: worker process
        www-data    97    89  0 00:17 ?        00:00:00     nginx: worker process
        www-data    98    89  0 00:17 ?        00:00:00     nginx: worker process
        www-data    99    89  0 00:17 ?        00:00:00     nginx: worker process

### Nginx config

        upstream fastcgi_backend_nodejs {
                server 127.0.0.1:8080;
                server 127.0.0.1:8081;
                server 127.0.0.1:8082;
                server 127.0.0.1:8083;

                keepalive 8;
        }

        upstream fastcgi_backend_csharp {
                server 127.0.0.1:9090;
                server 127.0.0.1:9091;
                server 127.0.0.1:9092;
                server 127.0.0.1:9093;

                keepalive 8;
        }

        server {
                listen 80 default_server;
                listen [::]:80 default_server;

                root /var/www/html;
                server_name _;

                location / {
                        try_files $uri $uri/ =404;
                }

                location /nodejs {
                        include /etc/nginx/fastcgi_params;
                        fastcgi_pass fastcgi_backend_nodejs;
                }

                location /csharp {
                        include /etc/nginx/fastcgi_params;
                        fastcgi_pass fastcgi_backend_csharp;
                }
        }

## Benchmark

The measuring is done with the Apache Benchmark tool.

        docker/login.sh
        ab -c 400 -n 200000 127.0.0.1/nodejs
        ab -c 400 -n 200000 127.0.0.1/csharp

(Outside the docker you have to use the port, which was passed to the `create_container.sh` script.)

### NodeJS results

        Concurrency Level:      400
        Time taken for tests:   9.561 seconds
        Complete requests:      200000
        Failed requests:        0
        Total transferred:      28800000 bytes
        HTML transferred:       2400000 bytes
        Requests per second:    20918.01 [#/sec] (mean)
        Time per request:       19.122 [ms] (mean)
        Time per request:       0.048 [ms] (mean, across all concurrent requests)
        Transfer rate:          2941.60 [Kbytes/sec] received

### C# results

No suitable async library found yet.

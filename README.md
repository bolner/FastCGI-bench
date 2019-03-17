# FastCGI-Bench - NodeJS vs .NET Core

The goal of this project to demonstrate that a `.NET Core` web application can reach the performance of a `NodeJS` one, if it uses only async techniques for handling input/output. Since I was unable to find a fully async FastCGI client library for .NET Core, I've developed one: [AsyncFastCGI.NET](https://github.com/bolner/AsyncFastCGI.NET).

These are the tested FastCGI libraries:

| Project name | Github page | Framework | Language |
| --- | --- | --- | --- |
| AsyncFastCGI&period;NET | https://github.com/bolner/AsyncFastCGI.NET | .NET Core | C# |
| node-fastcgi | https://github.com/fbbdev/node-fastcgi| NodeJS | Javascript |
| LukasBoersma/FastCGI | https://github.com/LukasBoersma/FastCGI | .NET Core | C# |

## Benchmark results

The ApacheBench tool was used to measure the performance. As you can see, the non-async library fails during higher concurrency.

### Concurrency: **20** simultanous connections / 20'000 requests

| Library          | Req. /sec | Req. Time | Conc. R.T. | Longest R. | Failed |
|------------------|-----------|-----------|------------|------------|--------|
| AsyncFastCGI.NET | 19494.64  | 1.026 ms  | 0.051 ms   | 18 ms      | 0      |
| NodeJS           | 19453.72  | 1.028 ms  | 0.051 ms   | 13 ms      | 0      |
| LB FastCGI       | 4249.07   | 4.707     | 0.235      | 3040 ms    | 0      |

*Req. Time: mean | Conc. R.T.: mean, across all concurrent requests*

### Concurrency: **400** simultaneous connections / 200'000 requests

| Library          | Req. /sec | Req. Time | Conc. R.T. | Longest R. | Failed |
|------------------|-----------|-----------|------------|------------|--------|
| AsyncFastCGI.NET | 19893.88  | 20.107 ms | 0.050 ms   | 2044 ms    | 0      |
| NodeJS           | 21411.16  | 18.682 ms | 0.047 ms   | 1062 ms    | 0      |
| LB FastCGI       | fails     | fails     | fails      | fails      | fails  |

*Req. Time: mean | Conc. R.T.: mean, across all concurrent requests*

Conclusions:
- The `.NET Core` applications can compete with the `NodeJS` ones regarding performance of I/O operations.
- Using FastCGI clients can be an alternative to the traditional ways of implementing web applications for `.NET`, which force too many constraints on the developers. The later being the biggest reason for their unpopularity.

## Installation

A docker file is provided for setting up the test environment for comparing the performances of `NodeJS` and `.NET Core` FastCGI clients, using an Nginx webserver.

- Create the docker image:

        docker/build_image.sh

- Create and start a container. The parameter is the public http port.

        docker/create_container.sh 8080

- Log in into the docker container:

        docker/login.sh
        or
        docker/root_login.sh

## Nginx config

4 NodeJS and 2x4 C# processes accept FastCGI request on different ports.

        upstream fastcgi_backend_asyncfcgi {
                server 127.0.0.1:8080;
                server 127.0.0.1:8081;
                server 127.0.0.1:8082;
                server 127.0.0.1:8083;
        }

        upstream fastcgi_backend_nodejs {
                server 127.0.0.1:7070;
                server 127.0.0.1:7071;
                server 127.0.0.1:7072;
                server 127.0.0.1:7073;
        }

        upstream fastcgi_backend_lbfastcgi {
                server 127.0.0.1:9090;
                server 127.0.0.1:9091;
                server 127.0.0.1:9092;
                server 127.0.0.1:9093;
        }

        server {
                listen 80 default_server;
                listen [::]:80 default_server;

                root /var/www/html;
                server_name _;

                location / {
                        try_files $uri $uri/ =404;
                }

                fastcgi_keep_conn off;
                fastcgi_request_buffering off;

                location /asyncfastcgi {
                        include /etc/nginx/fastcgi_params;
                        fastcgi_pass fastcgi_backend_asyncfcgi;
                }

                location /nodejs {
                        include /etc/nginx/fastcgi_params;
                        fastcgi_pass fastcgi_backend_nodejs;
                }

                location /lbfastcgi {
                        include /etc/nginx/fastcgi_params;
                        fastcgi_pass fastcgi_backend_lbfastcgi;
                }
        }

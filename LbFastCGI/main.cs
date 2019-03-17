using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using FastCGI;

namespace FastCGI.Demo
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length != 1) {
                Console.WriteLine("Please specify a port.");
                Environment.Exit(1);
            }

            // Create a new FCGIApplication, will accept FastCGI requests
            var app = new FCGIApplication();

            // Handle requests by responding with a 'Hello World' message
            app.OnRequestReceived += (sender, request) =>
            {
                var responseString =
                      "HTTP/1.1 200 OK\n"
                    + "Content-Type:text/html\n"
                    + "\n"
                    + "<!DOCTYPE html><html><body><h1>Hello World!</h1></body></html>";

                request.WriteResponseASCII(responseString);
                request.Close();
            };

            app.Run(Int32.Parse(args[0]));
        }
    }
}
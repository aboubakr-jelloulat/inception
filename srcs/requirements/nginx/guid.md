1. What is Nginx?
At its core, Nginx is a high-performance Web Server and Reverse Proxy. In the context of your Inception project, its primary jobs are:

Handling HTTPS: It acts as the "TLS Terminator," meaning it handles the encryption/decryption of data so your backend (like WordPress) doesn't have to.

Serving Static Files: It's incredibly fast at handing out HTML, CSS, and images.

Routing: It listens for requests and forwards them to the correct service (usually via the FastCGI protocol for PHP).


2. Why Docker copies to conf.d/

You wrote:

COPY conf/nginx.conf /etc/nginx/conf.d/nginx.conf
Why this is done:

Because:

👉 The base /etc/nginx/nginx.conf already exists
👉 It already includes conf.d/*.conf

3. What would happen if you overwrite /etc/nginx/nginx.conf?

If you did:

COPY nginx.conf /etc/nginx/nginx.conf

Then you would:

❌ Replace full Nginx system config
❌ Risk breaking:

event loop
logging
MIME types
includes
performance settings

Basically: you take control of the entire server config.

4. Why conf.d is safer (and standard)

Using /etc/nginx/conf.d/ means:

✔ modular configuration
✔ multiple apps supported
✔ no risk of breaking core Nginx
✔ easier Docker reuse


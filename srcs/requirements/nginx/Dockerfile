FROM debian:bullseye

EXPOSE 443

# SSL certificate environment variables
ARG CERT_FOLDER
ARG CERTIFICATE
ARG KEY
ARG COUNTRY
ARG STATE
ARG LOCALITY
ARG ORGANIZATION
ARG UNIT
ARG COMMON_NAME

# Install Nginx and OpenSSL, then clean up
RUN apt-get update && \
	apt-get install -y nginx openssl && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# Generate a self-signed SSL certificate with provided details
RUN mkdir -p ${CERT_FOLDER} && \
	openssl req -x509 -nodes -newkey rsa:4096 -sha256 -days 365 \
	-keyout ${KEY} \
	-out ${CERTIFICATE} \
	-subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${UNIT}/CN=${COMMON_NAME}"

# Copy main and server-specific Nginx configuration
COPY conf/nginx.conf /etc/nginx/
COPY conf/server.conf /etc/nginx/conf.d/

# Prepare web root and set permissions for www-data user
RUN mkdir -p /var/www/
RUN chown -R www-data:www-data /var/www/

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]

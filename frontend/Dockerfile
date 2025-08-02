# Use a minimal Nginx image to serve static content
FROM nginx:1.21-alpine

# Copy the frontend application files into the Nginx public directory
COPY public/ /usr/share/nginx/html

# Expose port 80 for the Nginx web server
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
# Use the official Node.js image as the base image
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy the application source code into the working directory
COPY app.js .

# Expose port 3000 where the app runs
EXPOSE 3000

# Run the application
CMD ["node", "app.js"]
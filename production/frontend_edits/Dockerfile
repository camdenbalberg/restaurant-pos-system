# /Dockerfile
# Version of Vue.js app
FROM node:20.18 AS frontend-build

# Set working directory
WORKDIR /app/frontend


# Install dependencies
COPY ./panda-web-app-frontend/package*.json ./
RUN npm install

# Copy app source code and build it
COPY ./panda-web-app-frontend/ ./
RUN npm run build

# Expose the port for the Vite development server
# Typically, Vite runs on port 5173 for development, so exposing 5173
EXPOSE 5173

# Build Vite
CMD ["npm", "run", "start"]

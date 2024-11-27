# Build React app
FROM node:20 AS build
WORKDIR /app
COPY ../../Simple-MERN-App/client/package.json ../../Simple-MERN-App/client/package-lock.json ./
RUN npm install
COPY ../../Simple-MERN-App/client ./ 
RUN npm run build

# Serve React app using Nginx
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY modules/ecs-frontend/frontend.sh /frontend.sh
RUN chmod +x /frontend.sh

EXPOSE 80
ENTRYPOINT ["/frontend.sh"]
CMD ["nginx", "-g", "daemon off;"]

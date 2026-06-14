version: '3.8'

services:
  jasperserver:
    image: retriever/jasperserver:7.5.0
    container_name: jasperserver
    ports:
      - 8081:8080  # Explícito para todas interfaces
    environment:
      - DB_HOST=postgresql  # Use o nome do serviço como host
      - DB_PORT=5432        # Use a porta interna do container PostgreSQL
      - DB_NAME=jasperserver
      - DB_USER=postgres
      - DB_PASSWORD=password
      - JRS_HTTPS_ONLY=false
    depends_on:
      - postgresql
    volumes:
      - jasperreports_data:/usr/local/tomcat/webapps/jasperserver
    restart: unless-stopped
    networks:
      - jasper-network

  postgresql:
    image: postgres:13
    container_name: jasper_postgres
    environment:
      - POSTGRES_DB=jasperserver
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5434:5432"  # Host:5434 -> Container:5432
    restart: unless-stopped
    networks:
      - jasper-network

volumes:
  jasperreports_data:
  postgres_data:

networks:
  jasper-network:
    driver: bridge

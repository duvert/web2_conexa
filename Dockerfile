# Usa una imagen oficial de Python como base
FROM python:3.12-slim AS builder

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# 1. Declara el argumento para que Docker lo reconozca
ARG SECRET_KEY

# 2. Asigna el valor del argumento a una variable de entorno
ENV SECRET_KEY=$SECRET_KEY

# Establece el directorio de trabajo
WORKDIR /app

# Instalación de dependencias del sistema y de Python
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libpq-dev


RUN pip install --upgrade pip
COPY requirements.txt .
RUN pip wheel --no-cache-dir --wheel-dir /app/wheels -r requirements.txt gunicorn psycopg2-binary

# --- Etapa 2: Final ---
# Esta es la imagen final, mucho más ligera y segura.
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Creación de usuario no-root y directorio de trabajo
RUN useradd --create-home appuser
WORKDIR /home/appuser/app

# Instalación de dependencias de sistema mínimas (solo las de runtime)
RUN apt-get update && \
    apt-get install -y --no-install-recommends libpq-dev postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Copia las dependencias pre-compiladas de la etapa 'builder' y las instala
COPY --from=builder /app/wheels /wheels
RUN pip install --no-cache /wheels/*

# Copia el código de la aplicación y el entrypoint
COPY . .
# COPY --chown=appuser:appuser
# entrypoint.sh .
# RUN chmod +x entrypoint.sh

# Asignación de permisos y cambio a usuario no-root
RUN chown -R appuser:appuser /home/appuser/app
USER appuser


# Recolección de archivos estáticos
# RUN python manage.py collectstatic --noinput

EXPOSE 8000

# ENTRYPOINT ["/home/appuser/app/entrypoint.sh"]
CMD ["gunicorn", "web2_conexa.wsgi:application", "--bind", "0.0.0.0:8000"]
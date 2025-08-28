# Usa una imagen oficial de Python como base
FROM python:3.12-slim

# Establece el directorio de trabajo
WORKDIR /app

# Copia los archivos del proyecto
COPY . /app

# Instala las dependencias
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Expone el puerto 8000
EXPOSE 8000

# Comando para ejecutar la aplicación con Easypanel (gunicorn recomendado)
CMD ["gunicorn", "web2_coneca.wsgi:application", "--bind", "0.0.0.0:8000"]
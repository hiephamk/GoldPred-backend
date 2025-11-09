FROM python:3.12-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DJANGO_SETTINGS_MODULE=main.settings.production

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project code
COPY . .

# Collect static files **during build** (not runtime)
RUN python3 manage.py collectstatic --noinput

# Expose is optional (Render ignores it)
# EXPOSE 8000

# Start command: migrate + gunicorn on $PORT
CMD python3 manage.py migrate && \
    gunicorn main.wsgi:application --bind 0.0.0.0:$PORT --workers 3 --log-level=info


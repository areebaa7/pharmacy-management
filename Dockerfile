FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements first (Docker layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy the entire project (including manage.py and the pharm folder)
COPY . .

# Run collectstatic from the root (where manage.py is)
RUN python manage.py collectstatic --noinput

EXPOSE 8000

# Tell Gunicorn to look inside 'pharm' to find 'wsgi.py'
CMD ["gunicorn", "pharm.wsgi:application", \
     "--bind", "0.0.0.0:8000", \
     "--workers", "3", \
     "--timeout", "120"]

FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements first
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy everything into /app
COPY . .

# CHANGE: Move into the folder where wsgi.py and manage.py actually live
# Based on your screenshot, this is the 'pharm' directory
WORKDIR /app/pharm

# Run collectstatic from inside the 'pharm' folder
RUN python manage.py collectstatic --noinput

EXPOSE 8000

# Now Gunicorn can find 'wsgi.py' directly in the current directory
CMD ["gunicorn", "wsgi:application", \
     "--bind", "0.0.0.0:8000", \
     "--workers", "3", \
     "--timeout", "120"]

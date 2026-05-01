FROM python:3.10-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    HOME=/data \
    PHOTO_SEGREGATOR_DATA_DIR=/data \
    PHOTO_SEGREGATOR_INPUT_DIR=/data/photos \
    PHOTO_SEGREGATOR_OUTPUT_DIR=/data/output \
    PHOTO_SEGREGATOR_CONFIG=/data/config.yaml \
    FLASK_HOST=0.0.0.0 \
    FLASK_PORT=5000

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        libgl1 \
        libglib2.0-0 \
        libgomp1 \
        libsm6 \
        libxext6 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip setuptools wheel \
    && pip install --no-cache-dir cython "numpy<2.0.0" \
    && pip install --no-cache-dir -r requirements.txt

COPY . .

RUN mkdir -p /data/photos /data/output

EXPOSE 5000
VOLUME ["/data"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/api/status', timeout=3)"

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--worker-class", "gthread", "--threads", "8", "--timeout", "0", "app:app"]

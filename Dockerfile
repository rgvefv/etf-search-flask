FROM python:3.10-slim

# 安裝基本套件和 Chrome
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    gnupg \
    fonts-liberation \
    libnss3 \
    libxss1 \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    ca-certificates \
    chromium \
    chromium-driver && \
    rm -rf /var/lib/apt/lists/*

ENV CHROME_BIN=/usr/bin/chromium
ENV CHROMEDRIVER_BIN=/usr/bin/chromedriver
ENV PATH=$PATH:/usr/bin

WORKDIR /app
COPY . /app

RUN pip install --no-cache-dir -r requirements.txt

# 啟動 Flask app 前
EXPOSE 5000

CMD ["python", "etf_search_server.py"]


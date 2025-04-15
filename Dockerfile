# 使用官方 Python 基礎映像檔
FROM python:3.10-slim

# 安裝 Chrome、ChromeDriver 和 headless 所需的套件
RUN apt-get update && apt-get install -y \
    chromium \
    chromium-driver \
    curl \
    unzip \
    gnupg \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libgdk-pixbuf2.0-0 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libxss1 \
    libxtst6 \
    xdg-utils \
    libu2f-udev \
    libvulkan1 \
    libgbm1 \
    && rm -rf /var/lib/apt/lists/*

# 設定 Chrome 與 ChromeDriver 路徑
ENV CHROME_BIN=/usr/bin/chromium
ENV CHROMEDRIVER_BIN=/usr/bin/chromedriver
ENV PATH=$PATH:/usr/bin

# 建立 app 目錄並複製檔案
WORKDIR /app
COPY . /app

# 安裝 Python 套件
RUN pip install --no-cache-dir -r requirements.txt

# 啟動 Flask app
CMD ["python", "etf_search_server.py"]

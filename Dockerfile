# 使用官方 Python 基礎映像檔
FROM python:3.10-slim

# 安裝 Chrome 與 ChromeDriver 以及必需工具
RUN apt-get update && apt-get install -y \
    chromium \
    chromium-driver \
    curl \
    unzip \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# 環境變數（給 selenium 指 Chrome 位置）
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

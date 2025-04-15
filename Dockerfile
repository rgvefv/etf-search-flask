# 使用輕量版 Python 映像檔
FROM python:3.10-slim

# 安裝 Chrome、ChromeDriver、以及必需工具
RUN apt-get update && apt-get install -y \
    chromium \
    chromium-driver \
    curl \
    unzip \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# 環境變數（告訴 selenium chrome 的位置）
ENV CHROME_BIN=/usr/bin/chromium
ENV CHROMEDRIVER_BIN=/usr/bin/chromedriver
ENV PATH=$PATH:/usr/bin

# 設定工作目錄
WORKDIR /app

# 複製專案檔案
COPY . /app

# 安裝 Python 套件
RUN pip install --no-cache-dir -r requirements.txt

# 開放 port（Railway 用）
EXPOSE 5000

# 使用 gunicorn 執行 Flask app
CMD ["gunicorn", "-b", "0.0.0.0:5000", "etf_search_server:app"]

